//------------------------------------------------------------------------------
module riscv_dp
//------------------------------------------------------------------------------
#(
  parameter MP_DATA_WIDTH = 32,
  parameter MP_ADDR_WIDTH = 32,
  parameter MP_PC_WIDTH = 32,
  parameter MP_REGFILE_ADDR_WIDTH = 5,
  parameter MP_ENDIANESS = `RISCV_BIG_ENDIAN
)
(
  input wire                              iclk,
  input wire                              irst,

  // Instruction wires
  input wire  [31:0]                      iinstr_nxt,
  output wire [31:0]                      oinstr,
  output wire [MP_PC_WIDTH-1:0]           opc,
  input wire                              ipc_src,
  input wire                              ipc_result_src,
  input wire  [2:0]                       iimm_src,

  // Hazard Unit wires
  input wire  [1:0]                       iforward_alu_src_a,
  input wire  [1:0]                       iforward_alu_src_b,
  input wire                              istall_f,
  input wire                              istall_d,
  input wire                              iflush_d,
  input wire                              iflush_e,

  // Regfile wires
  output wire [MP_REGFILE_ADDR_WIDTH-1:0] ors1, // addr source register 1
  output wire [MP_REGFILE_ADDR_WIDTH-1:0] ors2, // addr source register 2
  output reg  [MP_REGFILE_ADDR_WIDTH-1:0] ors1_1d,
  output reg  [MP_REGFILE_ADDR_WIDTH-1:0] ors2_1d,
  input wire                              ird_wr_en,
  input wire  [2:0]                       ird_wr_data_src,
  output reg  [MP_REGFILE_ADDR_WIDTH-1:0] ord_1d, // destination register
  output reg  [MP_REGFILE_ADDR_WIDTH-1:0] ord_2d,
  output reg  [MP_REGFILE_ADDR_WIDTH-1:0] ord_3d,

  // ALU wires
  input wire  [3:0]                       ialu_ctrl,
  input wire                              ialu_src,
  output wire [MP_DATA_WIDTH-1:0]         oalu_result,
  output wire                             oalu_zero,
  output wire                             oalu_ovfl,
  output wire                             oalu_carry,
  output wire                             oalu_neg,

  input wire  [MP_DATA_WIDTH-1:0]         idmem_rd_data,
  output reg  [MP_DATA_WIDTH-1:0]         odmem_wr_data,
  output wire [1 :0]                      odmem_wr_be
);
//----------------------------------------------------------------------------

  // iimm_src operation types
  localparam [2:0]
    LP_I_TYPE = 3'b000,
    LP_S_TYPE = 3'b001,
    LP_B_TYPE = 3'b010,
    LP_J_TYPE = 3'b011,
    LP_U_TYPE = 3'b100;

  reg [31:0] rinstr;
  reg [MP_PC_WIDTH-1:0]     rpc;
  wire  [2:0]               wfunct3_1d_nxt;

  wire  [MP_DATA_WIDTH-1:0] wdmem_rd_data_nxt;
  wire  [MP_PC_WIDTH-1:0]   wpc_nxt;
  wire [MP_PC_WIDTH-1:0] wpc_target_nxt;
  wire [MP_PC_WIDTH-1:0] wpc_result_nxt; // result of mux ALUResult and PCTarget

  reg  [MP_DATA_WIDTH-1:0] walu_src_a;
  wire [MP_DATA_WIDTH-1:0] walu_src_b;

  reg  [MP_DATA_WIDTH-1:0] wrd_wr_data;

  // pipeline Fetch - Decode
  wire [MP_PC_WIDTH-1:0] wpc_plus4_nxt;
  reg  [MP_PC_WIDTH-1:0] rpc_plus4;
  reg  [MP_PC_WIDTH-1:0] rpc_1d;

  // pipeline Decode - Execute
  wire [MP_DATA_WIDTH-1:0] wrs1_rd_data_nxt;
  wire [MP_DATA_WIDTH-1:0] wrs2_rd_data_nxt;
  wire [MP_REGFILE_ADDR_WIDTH-1:0]  wrd_1d_nxt;
  reg  [MP_DATA_WIDTH-1:0] wimm_ext;
  reg  [2:0]  rfunct3_1d;
  reg  [MP_DATA_WIDTH-1:0] rrs1_rd_data;
  reg  [MP_DATA_WIDTH-1:0] rrs2_rd_data;
  reg  [MP_DATA_WIDTH-1:0] rimm_ext;
  reg  [MP_PC_WIDTH-1:0] rpc_2d;
  reg  [MP_PC_WIDTH-1:0] rpc_plus4_1d;

  // pipeline Execute - Memory
  reg  [MP_DATA_WIDTH-1:0] wdmem_wr_data_nxt;
  wire [MP_DATA_WIDTH-1:0] walu_result_nxt;
  reg  [MP_DATA_WIDTH-1:0] ralu_result;
  reg  [2:0]  rfunct3_2d;
  reg  [MP_DATA_WIDTH-1:0] rimm_ext_1d;
  reg  [MP_PC_WIDTH-1:0] rpc_result;
  reg  [MP_PC_WIDTH-1:0] rpc_plus4_2d;

  // pipeline Memory - Writeback
  reg  [MP_DATA_WIDTH-1:0] rimm_ext_2d;
  reg  [MP_DATA_WIDTH-1:0] ralu_result_1d;
  reg  [MP_DATA_WIDTH-1:0] rdmem_rd_data;
  reg  [MP_PC_WIDTH-1:0] rpc_result_1d;
  reg  [MP_PC_WIDTH-1:0] rpc_plus4_3d;

  //----------------------------------------------------------------------------
  // stage fetch
  //----------------------------------------------------------------------------

  always @(posedge iclk or posedge irst) begin : sproc_pc_reg
    if (irst) begin
      rpc <= {MP_PC_WIDTH{1'b0}};
    end else begin
      if (~istall_f) begin
        rpc <= wpc_nxt;
      end
    end
  end

  assign opc = rpc;

  assign wpc_plus4_nxt = rpc + 'd4;
  assign wpc_nxt = ipc_src ? wpc_result_nxt : wpc_plus4_nxt;

  //----------------------------------------------------------------------------
  // pipeline fetch-decode
  //----------------------------------------------------------------------------

  always @(posedge iclk) begin : sproc_stage_decode
    if (irst || iflush_d) begin
      rinstr    <= {32{1'b0}};
      rpc_1d    <= {MP_PC_WIDTH{1'b0}};
      rpc_plus4 <= {MP_PC_WIDTH{1'b0}};
    end else begin
      if (~istall_d) begin
        rinstr    <= iinstr_nxt;
        rpc_1d    <= rpc;
        rpc_plus4 <= wpc_plus4_nxt;
      end
    end
  end

  assign oinstr         = rinstr;
  assign wfunct3_1d_nxt = rinstr[14:12];
  assign wrd_1d_nxt     = rinstr[11:7];  // destination register
  assign ors1           = rinstr[19:15]; // source register 1
  assign ors2           = rinstr[24:20]; // source register 2

  riscv_dp_regfile #(
    .MP_DATA_WIDTH (MP_DATA_WIDTH),
    .MP_ADDR_WIDTH (MP_REGFILE_ADDR_WIDTH)
  ) u_regfile (
    .iclk      (~iclk),
    .iaddr1    (ors1),
    .ord_data1 (wrs1_rd_data_nxt),
    .iaddr2    (ors2),
    .ord_data2 (wrs2_rd_data_nxt),
    .iaddr3    (ord_3d),
    .iwr_en3   (ird_wr_en),
    .iwr_data3 (wrd_wr_data)
  );

  // immediate extend
  always @(*) begin : cproc_imm_extend
    case (iimm_src)
      LP_I_TYPE: wimm_ext = {{MP_DATA_WIDTH-12{rinstr[31]}}, rinstr[31:20]};
      LP_S_TYPE: wimm_ext = {{MP_DATA_WIDTH-12{rinstr[31]}}, rinstr[31:25], rinstr[11:7]};
      LP_B_TYPE: wimm_ext = {{MP_DATA_WIDTH-12{rinstr[31]}}, rinstr[7], rinstr[30:25], rinstr[11:8], 1'b0};
      LP_J_TYPE: wimm_ext = {{MP_DATA_WIDTH-20{rinstr[31]}}, rinstr[19:12], rinstr[20], rinstr[30:21], 1'b0};
      LP_U_TYPE: wimm_ext = {rinstr[31:12], {MP_DATA_WIDTH-20{1'b0}}};
      default: wimm_ext = {MP_DATA_WIDTH{1'bx}}; // TODO: check dontcare
    endcase
  end

  //----------------------------------------------------------------------------
  // pipeline decode-execute
  //----------------------------------------------------------------------------

  always @(posedge iclk) begin : sproc_stage_execute_noflush
    if (irst) begin
      rfunct3_1d <= {3{1'b0}};
    end else begin
      rfunct3_1d <= wfunct3_1d_nxt;
    end
  end

  always @(posedge iclk) begin : sproc_stage_execute
    if (irst || iflush_e) begin
      rrs1_rd_data <= {MP_DATA_WIDTH{1'b0}};
      rrs2_rd_data <= {MP_DATA_WIDTH{1'b0}};
      rpc_2d       <= {MP_PC_WIDTH{1'b0}};
      ors1_1d      <= {MP_REGFILE_ADDR_WIDTH{1'b0}};
      ors2_1d      <= {MP_REGFILE_ADDR_WIDTH{1'b0}};
      ord_1d       <= {MP_REGFILE_ADDR_WIDTH{1'b0}};
      rimm_ext     <= {MP_DATA_WIDTH{1'b0}};
      rpc_plus4_1d <= {MP_PC_WIDTH{1'b0}};
    end else begin
      rrs1_rd_data <= wrs1_rd_data_nxt;
      rrs2_rd_data <= wrs2_rd_data_nxt;
      rpc_2d       <= rpc_1d;
      ors1_1d      <= ors1;
      ors2_1d      <= ors2;
      ord_1d       <= wrd_1d_nxt;
      rimm_ext     <= wimm_ext;
      rpc_plus4_1d <= rpc_plus4;
    end
  end

  always @(*) begin : cproc_alu_src_a
    case (iforward_alu_src_a)
      2'b00:   walu_src_a = rrs1_rd_data;
      2'b01:   walu_src_a = wrd_wr_data;
      2'b10:   walu_src_a = ralu_result;
      default: walu_src_a = walu_src_a;
    endcase
  end

  always @(*) begin : cproc_dmem_wr_data
    case (iforward_alu_src_b)
      2'b00:   wdmem_wr_data_nxt = rrs2_rd_data;
      2'b01:   wdmem_wr_data_nxt = wrd_wr_data;
      2'b10:   wdmem_wr_data_nxt = ralu_result;
      default: wdmem_wr_data_nxt = wdmem_wr_data_nxt;
    endcase
  end

  assign walu_src_b = ialu_src ? rimm_ext : wdmem_wr_data_nxt;

  riscv_dp_alu #(
    .MP_DATA_WIDTH (MP_DATA_WIDTH),
    .MP_ENDIANESS  (MP_ENDIANESS)
  ) u_alu (
    .ictrl     (ialu_ctrl),
    .isrc_a    (walu_src_a),
    .isrc_b    (walu_src_b),
    .oresult   (walu_result_nxt),
    .ozero     (oalu_zero),
    .ooverflow (oalu_ovfl),
    .ocarry    (oalu_carry),
    .onegative (oalu_neg)
  );

  assign wpc_target_nxt = rpc_2d + rimm_ext;
  assign wpc_result_nxt = ipc_result_src ? walu_result_nxt : wpc_target_nxt;

  //----------------------------------------------------------------------------
  // pipeline execute-memory
  //----------------------------------------------------------------------------

  always @(posedge iclk) begin : sproc_stage_memory
    if (irst) begin
      rfunct3_2d    <= {3{1'b0}};
      ralu_result   <= {MP_DATA_WIDTH{1'b0}};
      odmem_wr_data <= {MP_DATA_WIDTH{1'b0}};
      rimm_ext_1d   <= {MP_DATA_WIDTH{1'b0}};
      ord_2d        <= {MP_REGFILE_ADDR_WIDTH{1'b0}};
      rpc_result    <= {MP_PC_WIDTH{1'b0}};
      rpc_plus4_2d  <= {MP_PC_WIDTH{1'b0}};
    end else begin
      rfunct3_2d    <= rfunct3_1d;
      ralu_result   <= walu_result_nxt;
      odmem_wr_data <= wdmem_wr_data_nxt;
      rimm_ext_1d   <= rimm_ext;
      ord_2d        <= ord_1d;
      rpc_result    <= wpc_result_nxt;
      rpc_plus4_2d  <= rpc_plus4_1d;
    end
  end

  assign odmem_wr_be = rfunct3_2d[1:0];
  assign oalu_result = ralu_result;

  riscv_dp_loaddec #(
    .MP_DATA_WIDTH (MP_DATA_WIDTH)
  ) u_loaddec (
    .iop       (ralu_result[1:0]),
    .ifunct3   (rfunct3_2d),
    .idata     (idmem_rd_data),
    .odata_dec (wdmem_rd_data_nxt)
  );

  //----------------------------------------------------------------------------
  // pipeline memory-writeback
  //----------------------------------------------------------------------------

  always @(posedge iclk) begin : sproc_stage_writeback
    if (irst) begin
      ralu_result_1d <= {MP_DATA_WIDTH{1'b0}};
      rdmem_rd_data  <= {MP_DATA_WIDTH{1'b0}};
      rimm_ext_2d    <= {MP_DATA_WIDTH{1'b0}};
      ord_3d         <= {MP_REGFILE_ADDR_WIDTH{1'b0}};
      rpc_result_1d  <= {MP_PC_WIDTH{1'b0}};
      rpc_plus4_3d   <= {MP_PC_WIDTH{1'b0}};
    end else begin
      ralu_result_1d <= ralu_result;
      rdmem_rd_data  <= wdmem_rd_data_nxt;
      rimm_ext_2d    <= rimm_ext_1d;
      ord_3d         <= ord_2d;
      rpc_result_1d  <= rpc_result;
      rpc_plus4_3d   <= rpc_plus4_2d;
    end
  end

  always @(*) begin : cproc_rd_wr_data
    case(ird_wr_data_src)
      3'b000: wrd_wr_data = ralu_result_1d;
      3'b111: wrd_wr_data = ralu_result_1d;
      3'b001: wrd_wr_data = rdmem_rd_data;
      3'b010: wrd_wr_data = rpc_plus4_3d;
      3'b101: wrd_wr_data = rpc_result_1d;
      3'b011: wrd_wr_data = rimm_ext_2d;
      default: wrd_wr_data = {32{1'bx}}; // TODO: usage of dontcare
    endcase
  end

endmodule
