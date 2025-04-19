//------------------------------------------------------------------------------
module riscv_dp
//------------------------------------------------------------------------------
#(
  parameter MP_DATA_WIDTH = 32,
  parameter MP_ADDR_WIDTH = 32
)
(
  input wire          iclk,
  input wire          irst,

  input wire  [2:0]   iresult_src_w,
  input wire          ipc_src_e,
  input wire          iriscv_dp_alu_src_e,
  input wire          ireg_wr_w,
  input wire  [2:0]   iimm_src_d,
  input wire  [3:0]   iriscv_dp_alu_ctrl_e,
  input wire          ipc_result_src_e,

  input wire  [1:0]   iforward_ae,
  input wire  [1:0]   iforward_be,
  input wire          istall_f,
  input wire          istall_d,
  input wire          iflush_d,
  input wire          iflush_e,

  output wire [4:0]   ors1_d,
  output wire [4:0]   ors2_d,
  output reg  [4:0]   ors1_e,
  output reg  [4:0]   ors2_e,
  output reg  [4:0]   ord_e,
  output reg  [4:0]   ord_m,
  output reg  [4:0]   ord_w,

  // ALU flags
  output wire         oriscv_dp_alu_zero_e,
  output wire         oriscv_dp_alu_ovfl_e,
  output wire         oriscv_dp_alu_carry_e,
  output wire         oriscv_dp_alu_neg_e,

  output reg  [31:0]  opc_f,
  input wire  [31:0]  iinstr_f,
  output reg  [31:0]  oinstr_d,
  output reg  [MP_DATA_WIDTH-1:0]  oriscv_dp_alu_result_m,
  output reg  [MP_DATA_WIDTH-1:0]  owdata_m,
  input wire  [MP_DATA_WIDTH-1:0]  imem_data_m,
  output wire [1 :0]  oinstr2b_m    //last 2 bits to be used on dmem
);
//------------------------------------------------------------------------------

  wire [MP_DATA_WIDTH-1:0] wrdata_m;
  wire [31:0] wpc_next_f;
  wire [31:0] wpc_target_e;
  wire [31:0] wpc_result_e; // result of mux ALUResult and PCTarget

  reg  [31:0] wsrc_a_e;
  wire [31:0] wsrc_b_e;

  reg  [MP_DATA_WIDTH-1:0] wresult_w;

  // pipeline Fetch - Decode
  wire [31:0] wpc_plus4_f;
  reg  [31:0] rpc_plus4_d;
  reg  [31:0] rpc_d;

  // pipeline Decode - Execute
  wire [MP_DATA_WIDTH-1:0] wrd1_d;
  wire [MP_DATA_WIDTH-1:0] wrd2_d;
  wire [4:0]  wrd_d;
  wire [31:0] wimm_ext_d;
  reg  [2:0]  rinstr_e;
  reg  [MP_DATA_WIDTH-1:0] rrd1_e;
  reg  [MP_DATA_WIDTH-1:0] rrd2_e;
  reg  [31:0] rpc_e;
  reg  [31:0] rimm_ext_e;
  reg  [31:0] rpc_plus4_e;

  // pipeline Execute - Memory
  reg  [MP_DATA_WIDTH-1:0] wwdata_e;
  wire [31:0] wriscv_dp_alu_result_e;
  reg  [2:0]  rinstr_m;
  reg  [31:0] rimm_ext_m;
  reg  [31:0] rpc_result_m;
  reg  [31:0] rpc_plus4_m;

  // pipeline Memory - Writeback
  reg  [31:0] rimm_ext_w;
  reg  [31:0] rriscv_dp_alu_result_w;
  reg  [MP_DATA_WIDTH-1:0] rrdata_w;
  reg  [31:0] rpc_result_w;
  reg  [31:0] rpc_plus4_w;

//------------------------------------------------------------------------------
// pipelines
//------------------------------------------------------------------------------

  always @(posedge iclk) begin : sproc_pipeline_fet_dec
    if (irst | iflush_d) begin
      oinstr_d    <= {32{1'b0}};
      rpc_d       <= {32{1'b0}};
      rpc_plus4_d <= {32{1'b0}};
    end else begin
      if (~istall_d) begin
        oinstr_d    <= iinstr_f;
        rpc_d       <= opc_f;
        rpc_plus4_d <= wpc_plus4_f;
      end
    end
  end

  always @(posedge iclk) begin
    if (irst) begin
      rinstr_e    <= {3{1'b0}};
    end else begin
      rinstr_e    <= oinstr_d[14:12];
    end
  end

  always @(posedge iclk) begin : sproc_pipeline_dec_exec
    if (irst | iflush_e) begin
    // if (irst) begin
      // rinstr_e    <= {3{1'b0}};
      rrd1_e      <= {MP_DATA_WIDTH{1'b0}};
      rrd2_e      <= {MP_DATA_WIDTH{1'b0}};
      rpc_e       <= {32{1'b0}};
      ors1_e      <= {MP_DATA_WIDTH{1'b0}};
      ors2_e      <= {MP_DATA_WIDTH{1'b0}};
      ord_e       <= {5{1'b0}};
      rimm_ext_e  <= {32{1'b0}};
      rpc_plus4_e <= {32{1'b0}};
    end else begin
      // rinstr_e    <= oinstr_d[14:12];
      rrd1_e      <= wrd1_d;
      rrd2_e      <= wrd2_d;
      rpc_e       <= rpc_d;
      ors1_e      <= ors1_d;
      ors2_e      <= ors2_d;
      ord_e       <= wrd_d;
      rimm_ext_e  <= wimm_ext_d;
      rpc_plus4_e <= rpc_plus4_d;
    end
  end

  always @(posedge iclk) begin : sproc_pipeline_exec_mem
    if (irst) begin
      rinstr_m      <= {3{1'b0}};
      oriscv_dp_alu_result_m <= {MP_DATA_WIDTH{1'b0}};
      owdata_m      <= {MP_DATA_WIDTH{1'b0}};
      rimm_ext_m    <= {32{1'b0}};
      ord_m         <= {5{1'b0}};
      rpc_result_m  <= {32{1'b0}};
      rpc_plus4_m   <= {32{1'b0}};
    end else begin
      rinstr_m      <= rinstr_e;
      oriscv_dp_alu_result_m <= wriscv_dp_alu_result_e;
      owdata_m      <= wwdata_e;
      rimm_ext_m    <= rimm_ext_e;
      ord_m         <= ord_e;
      rpc_result_m  <= wpc_result_e;
      rpc_plus4_m   <= rpc_plus4_e;
    end
  end

  always @(posedge iclk) begin : sproc_pipeline_mem_writ
    if (irst) begin
      rriscv_dp_alu_result_w <= {MP_DATA_WIDTH{1'b0}};
      rrdata_w      <= {MP_DATA_WIDTH{1'b0}};
      rimm_ext_w    <= {32{1'b0}};
      ord_w         <= {5{1'b0}};
      rpc_result_w  <= {32{1'b0}};
      rpc_plus4_w   <= {32{1'b0}};
    end else begin
      rriscv_dp_alu_result_w <= oriscv_dp_alu_result_m;
      rrdata_w      <= wrdata_m;
      rimm_ext_w    <= rimm_ext_m;
      ord_w         <= ord_m;
      rpc_result_w  <= rpc_result_m;
      rpc_plus4_w   <= rpc_plus4_m;
    end
  end

//------------------------------------------------------------------------------
// hazard unit muxes
//------------------------------------------------------------------------------

  always @(*) begin : cproc_src_ae
    case (iforward_ae)
      2'b00:   wsrc_a_e = rrd1_e;
      2'b01:   wsrc_a_e = wresult_w;
      2'b10:   wsrc_a_e = oriscv_dp_alu_result_m;
      default: wsrc_a_e = wsrc_a_e;
    endcase
  end

  always @(*) begin : cproc_wdata_e
    case (iforward_be)
      2'b00:   wwdata_e = rrd2_e;
      2'b01:   wwdata_e = wresult_w;
      2'b10:   wwdata_e = oriscv_dp_alu_result_m;
      default: wwdata_e = wwdata_e;
    endcase
  end

//------------------------------------------------------------------------------
// riscv_dp
//------------------------------------------------------------------------------

  assign ors1_d = oinstr_d[19:15];
  assign ors2_d = oinstr_d[24:20];
  assign wrd_d  = oinstr_d[11:7];

  assign oinstr2b_m = rinstr_m[1:0];

  always @(posedge iclk or posedge irst) begin : sproc_pc_reg
    if (irst) begin
      opc_f <= {32{1'b0}};
    end else begin
      if (~istall_f) begin
        opc_f <= wpc_next_f;
      end
    end
  end

  assign wpc_plus4_f = opc_f + 32'd4;
  assign wpc_target_e = rpc_e + rimm_ext_e;

  assign wpc_result_e = ipc_result_src_e ? wriscv_dp_alu_result_e : wpc_target_e;
  assign wpc_next_f = ipc_src_e ? wpc_result_e : wpc_plus4_f;

  assign wsrc_b_e = iriscv_dp_alu_src_e ? rimm_ext_e : wwdata_e;

//------------------------------------------------------------------------------
// block instantiation
//------------------------------------------------------------------------------

  riscv_dp_regfile #(
    .MP_DATA_WIDTH (MP_DATA_WIDTH),
    .MP_ADDR_WIDTH (MP_ADDR_WIDTH)
  ) u_riscv_dp_regfile (
    .iclk    (~iclk),
    .iwen3   (ireg_wr_w),
    .ia1     (ors1_d),
    .ia2     (ors2_d),
    .ia3     (ord_w),
    .iwdata3 (wresult_w),
    .ordata1 (wrd1_d),
    .ordata2 (wrd2_d)
  );

  riscv_dp_extend_imm extImm(
    .iinstr (oinstr_d[31:7]),
    .isrc   (iimm_src_d),
    .oext   (wimm_ext_d)
  );

  riscv_dp_alu #(
    .MP_DATA_WIDTH (MP_DATA_WIDTH)
  ) u_riscv_dp_alu (
    .ictrl     (iriscv_dp_alu_ctrl_e),
    .isrc_a    (wsrc_a_e),
    .isrc_b    (wsrc_b_e),
    .oresult   (wriscv_dp_alu_result_e),
    .ozero     (oriscv_dp_alu_zero_e),
    .ooverflow (oriscv_dp_alu_ovfl_e),
    .ocarry    (oriscv_dp_alu_carry_e),
    .onegative (oriscv_dp_alu_neg_e)
  );

  riscv_dp_loaddec #(
    .MP_DATA_WIDTH (MP_DATA_WIDTH)
  ) u_riscv_dp_loaddec (
    .imem_data (imem_data_m),
    .ifunct3   (rinstr_m),
    .iop       (oriscv_dp_alu_result_m[1:0]),
    .ordata    (wrdata_m)
  );

//------------------------------------------------------------------------------

  always @(*) begin
    case(iresult_src_w)
      3'b000: wresult_w = rriscv_dp_alu_result_w;
      3'b111: wresult_w = rriscv_dp_alu_result_w;
      3'b001: wresult_w = rrdata_w;
      3'b010: wresult_w = rpc_plus4_w;
      3'b101: wresult_w = rpc_result_w;
      3'b011: wresult_w = rimm_ext_w;
      default: wresult_w = {32{1'bx}};
    endcase
  end

endmodule
