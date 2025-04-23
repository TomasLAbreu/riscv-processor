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
  input wire          iclk,
  input wire          irst,

  // Instruction wires
  input wire  [31:0]            iinstr_nxt,
  output wire [31:0]            oinstr,
  output reg  [MP_PC_WIDTH-1:0] opc,
  input wire                    ipc_src,
  input wire                    ipc_result_src,

  input wire  [2:0]   iimm_src,
  input wire  [2:0]   iresult_src,

  // Hazard Unit wires
  input wire  [1:0]   iforward_ae,
  input wire  [1:0]   iforward_be,
  input wire          istall_f,
  input wire          istall_d,
  input wire          iflush_d,
  input wire          iflush_e,

  // Regfile wires
  output wire [MP_REGFILE_ADDR_WIDTH-1:0] oregfile_addr1,
  output wire [MP_REGFILE_ADDR_WIDTH-1:0] oregfile_addr2,
  output reg  [MP_REGFILE_ADDR_WIDTH-1:0] oregfile_addr1_1d,// TODO: move this to hazard unit?
  output reg  [MP_REGFILE_ADDR_WIDTH-1:0] oregfile_addr2_1d,
  input wire                              iregfile_wr_en3,
  output reg  [MP_REGFILE_ADDR_WIDTH-1:0] oregfile_addr3,
  output reg  [MP_REGFILE_ADDR_WIDTH-1:0] ord_e,
  output reg  [MP_REGFILE_ADDR_WIDTH-1:0] ord_m,

  // ALU wires
  input wire  [3:0]               ialu_ctrl,
  input wire                      ialu_src,
  output wire [MP_DATA_WIDTH-1:0] oalu_result,
  output wire                     oalu_zero,
  output wire                     oalu_ovfl,
  output wire                     oalu_carry,
  output wire                     oalu_neg,


  input wire  [MP_DATA_WIDTH-1:0] idmem_rd_data,
  output reg  [MP_DATA_WIDTH-1:0] odmem_wr_data,
  output wire [1 :0]              odmem_wr_be
);
//------------------------------------------------------------------------------

  // iimm_src operation types
  localparam [2:0]
    LP_I_TYPE = 3'b000,
    LP_S_TYPE = 3'b001,
    LP_B_TYPE = 3'b010,
    LP_J_TYPE = 3'b011,
    LP_U_TYPE = 3'b100;

  reg [31:0] rinstr;

  wire [MP_DATA_WIDTH-1:0] wrd_data_dec;
  wire [MP_PC_WIDTH-1:0] wpc_nxt;
  wire [MP_PC_WIDTH-1:0] wpc_target_nxt;
  wire [MP_PC_WIDTH-1:0] wpc_result_nxt; // result of mux ALUResult and PCTarget

  reg  [MP_DATA_WIDTH-1:0] walu_src_a;
  wire [MP_DATA_WIDTH-1:0] walu_src_b;

  reg  [MP_DATA_WIDTH-1:0] wresult_w;

  // pipeline Fetch - Decode
  wire [MP_PC_WIDTH-1:0] wpc_plus4_nxt;
  reg  [MP_PC_WIDTH-1:0] rpc_plus4;
  reg  [MP_PC_WIDTH-1:0] rpc_1d;

  // pipeline Decode - Execute
  wire [MP_DATA_WIDTH-1:0] wregfile_rd_data1;
  wire [MP_DATA_WIDTH-1:0] wregfile_rd_data2;
  wire [MP_REGFILE_ADDR_WIDTH-1:0]  wrd_d;
  reg  [MP_DATA_WIDTH-1:0] wimm_ext;
  reg  [2:0]  rfunct3;
  reg  [MP_DATA_WIDTH-1:0] rrd1_e;
  reg  [MP_DATA_WIDTH-1:0] rrd2_e;
  reg  [MP_DATA_WIDTH-1:0] rimm_ext;
  reg  [MP_PC_WIDTH-1:0] rpc_2d;
  reg  [MP_PC_WIDTH-1:0] rpc_plus4_1d;

  // pipeline Execute - Memory
  reg  [MP_DATA_WIDTH-1:0] wwr_data_nxt;
  wire [MP_DATA_WIDTH-1:0] walu_result_nxt;
  reg  [MP_DATA_WIDTH-1:0] ralu_result;
  reg  [2:0]  rfunct3_1d;
  reg  [MP_DATA_WIDTH-1:0] rimm_ext_1d;
  reg  [MP_PC_WIDTH-1:0] rpc_result;
  reg  [MP_PC_WIDTH-1:0] rpc_plus4_2d;

  // pipeline Memory - Writeback
  reg  [MP_DATA_WIDTH-1:0] rimm_ext_2d;
  reg  [MP_DATA_WIDTH-1:0] ralu_result_1d;
  reg  [MP_DATA_WIDTH-1:0] rrd_data_dec;
  reg  [MP_PC_WIDTH-1:0] rpc_result_1d;
  reg  [MP_PC_WIDTH-1:0] rpc_plus4_3d;

//------------------------------------------------------------------------------
// pipelines
//------------------------------------------------------------------------------

  assign oalu_result = ralu_result;
  assign oinstr = rinstr;

  always @(posedge iclk) begin : sproc_pipeline_fet_dec
    if (irst || iflush_d) begin
      rinstr    <= {32{1'b0}};
      rpc_1d    <= {MP_PC_WIDTH{1'b0}};
      rpc_plus4 <= {MP_PC_WIDTH{1'b0}};
    end else begin
      if (~istall_d) begin
        rinstr    <= iinstr_nxt;
        rpc_1d    <= opc;
        rpc_plus4 <= wpc_plus4_nxt;
      end
    end
  end

  always @(posedge iclk) begin
    if (irst) begin
      rfunct3 <= {3{1'b0}};
    end else begin
      rfunct3 <= rinstr[14:12];
    end
  end

  always @(posedge iclk) begin : sproc_pipeline_dec_exec
    if (irst || iflush_e) begin
      rrd1_e            <= {MP_DATA_WIDTH{1'b0}};
      rrd2_e            <= {MP_DATA_WIDTH{1'b0}};
      rpc_2d            <= {MP_PC_WIDTH{1'b0}};
      oregfile_addr1_1d <= {MP_REGFILE_ADDR_WIDTH{1'b0}};
      oregfile_addr2_1d <= {MP_REGFILE_ADDR_WIDTH{1'b0}};
      ord_e             <= {MP_REGFILE_ADDR_WIDTH{1'b0}};
      rimm_ext          <= {MP_DATA_WIDTH{1'b0}};
      rpc_plus4_1d      <= {MP_PC_WIDTH{1'b0}};
    end else begin
      rrd1_e            <= wregfile_rd_data1;
      rrd2_e            <= wregfile_rd_data2;
      rpc_2d            <= rpc_1d;
      oregfile_addr1_1d <= oregfile_addr1;
      oregfile_addr2_1d <= oregfile_addr2;
      ord_e             <= wrd_d;
      rimm_ext          <= wimm_ext;
      rpc_plus4_1d      <= rpc_plus4;
    end
  end

  always @(posedge iclk) begin : sproc_pipeline_exec_mem
    if (irst) begin
      rfunct3_1d   <= {3{1'b0}};
      ralu_result  <= {MP_DATA_WIDTH{1'b0}};
      odmem_wr_data     <= {MP_DATA_WIDTH{1'b0}};
      rimm_ext_1d  <= {MP_DATA_WIDTH{1'b0}};
      ord_m        <= {MP_REGFILE_ADDR_WIDTH{1'b0}};
      rpc_result   <= {MP_PC_WIDTH{1'b0}};
      rpc_plus4_2d <= {MP_PC_WIDTH{1'b0}};
    end else begin
      rfunct3_1d   <= rfunct3;
      ralu_result  <= walu_result_nxt;
      odmem_wr_data     <= wwr_data_nxt;
      rimm_ext_1d  <= rimm_ext;
      ord_m        <= ord_e;
      rpc_result   <= wpc_result_nxt;
      rpc_plus4_2d <= rpc_plus4_1d;
    end
  end

  always @(posedge iclk) begin : sproc_pipeline_mem_writ
    if (irst) begin
      ralu_result_1d <= {MP_DATA_WIDTH{1'b0}};
      rrd_data_dec   <= {MP_DATA_WIDTH{1'b0}};
      rimm_ext_2d    <= {MP_DATA_WIDTH{1'b0}};
      oregfile_addr3 <= {MP_REGFILE_ADDR_WIDTH{1'b0}};
      rpc_result_1d  <= {MP_PC_WIDTH{1'b0}};
      rpc_plus4_3d   <= {MP_PC_WIDTH{1'b0}};
    end else begin
      ralu_result_1d <= ralu_result;
      rrd_data_dec   <= wrd_data_dec;
      rimm_ext_2d    <= rimm_ext_1d;
      oregfile_addr3 <= ord_m;
      rpc_result_1d  <= rpc_result;
      rpc_plus4_3d   <= rpc_plus4_2d;
    end
  end

//------------------------------------------------------------------------------
// dp
//------------------------------------------------------------------------------

  always @(*) begin : cproc_src_ae
    case (iforward_ae)
      2'b00:   walu_src_a = rrd1_e;
      2'b01:   walu_src_a = wresult_w;
      2'b10:   walu_src_a = ralu_result;
      default: walu_src_a = walu_src_a;
    endcase
  end

  assign walu_src_b = ialu_src ? rimm_ext : wwr_data_nxt;

  always @(*) begin : cproc_wdata_e
    case (iforward_be)
      2'b00:   wwr_data_nxt = rrd2_e;
      2'b01:   wwr_data_nxt = wresult_w;
      2'b10:   wwr_data_nxt = ralu_result;
      default: wwr_data_nxt = wwr_data_nxt;
    endcase
  end

  assign oregfile_addr1 = rinstr[19:15];
  assign oregfile_addr2 = rinstr[24:20];
  assign wrd_d  = rinstr[11:7];

  assign odmem_wr_be = rfunct3_1d[1:0];

  always @(posedge iclk or posedge irst) begin : sproc_pc_reg
    if (irst) begin
      opc <= {MP_PC_WIDTH{1'b0}};
    end else begin
      if (~istall_f) begin
        opc <= wpc_nxt;
      end
    end
  end

  assign wpc_plus4_nxt = opc + 'd4;
  assign wpc_target_nxt = rpc_2d + rimm_ext;

  assign wpc_result_nxt = ipc_result_src ? walu_result_nxt : wpc_target_nxt;
  assign wpc_nxt = ipc_src ? wpc_result_nxt : wpc_plus4_nxt;

//------------------------------------------------------------------------------
// block instantiation
//------------------------------------------------------------------------------

  riscv_dp_regfile #(
    .MP_DATA_WIDTH (MP_DATA_WIDTH),
    .MP_ADDR_WIDTH (MP_REGFILE_ADDR_WIDTH)
  ) u_regfile (
    .iclk      (~iclk),
    .iaddr1    (oregfile_addr1),
    .ord_data1 (wregfile_rd_data1),
    .iaddr2    (oregfile_addr2),
    .ord_data2 (wregfile_rd_data2),
    .iaddr3    (oregfile_addr3),
    .iwr_en3   (iregfile_wr_en3),
    .iwr_data3 (wresult_w)
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

  riscv_dp_loaddec #(
    .MP_DATA_WIDTH (32)
  ) u_loaddec (
    .idata     (idmem_rd_data),
    .ifunct3   (rfunct3_1d),
    .iop       (ralu_result[1:0]),
    .odata_dec (wrd_data_dec)
  );

//------------------------------------------------------------------------------

  always @(*) begin
    case(iresult_src)
      3'b000: wresult_w = ralu_result_1d;
      3'b111: wresult_w = ralu_result_1d;
      3'b001: wresult_w = rrd_data_dec;
      3'b010: wresult_w = rpc_plus4_3d;
      3'b101: wresult_w = rpc_result_1d;
      3'b011: wresult_w = rimm_ext_2d;
      default: wresult_w = {32{1'bx}}; // TODO: usage of dontcare
    endcase
  end

endmodule
