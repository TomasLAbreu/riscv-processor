module riscv_ctrl (
  input             iclk,
  input             irst,

  input             iflush_e,
  input wire  [6:0] iop_d,
  input wire  [2:0] ifunct3_d,
  input wire        ifunct7b5_d,

  // ALU flags
  output reg        oalu_src,
  output reg  [3:0] oalu_ctrl,
  input wire        ialu_zero,
  input wire        ialu_ovfl,
  input wire        ialu_carry,
  input wire        ialu_neg,

  output reg  [2:0] oresult_src,

  output reg        odmem_wr_en,
  output wire       opc_src,
  output reg        oreg_write_w,
  output reg        oreg_write_m,
  output reg        opc_result_src,
  output wire [2:0] oimm_src,
  output wire       oresult_srcb0_e
);

  wire [1:0] walu_op_d;

  // ============================================================================
  // pipeline Decode - Execute
  // ============================================================================
  wire        wreg_write_d;
  wire  [2:0] wresult_src_d;
  wire        wmem_write_d;
  wire  [3:0] walu_ctrl_d;
  wire        walu_src_d;
  wire        wpc_result_src_d;

  reg [6:0] rop_e;
  reg [2:0] rfunct3_e;
  reg       rreg_write_e;
  reg [2:0] rresult_src_e;
  reg       rmem_write_e;

  // ============================================================================
  // pipeline Execute - Memory
  // ============================================================================
  reg  [2:0] rresult_src_m;

  // ============================================================================
  // pipelines
  // ============================================================================

  always @(posedge iclk) begin : sproc_pipeline_dec_exec
    if (irst || iflush_e) begin
      rop_e            <= {7{1'b0}};
      rfunct3_e        <= {3{1'b0}};
      rreg_write_e     <= 1'b0;
      rresult_src_e    <= {3{1'b0}};
      rmem_write_e     <= 1'b0;
      oalu_ctrl      <= {4{1'b0}};
      oalu_src       <= 1'b0;
      opc_result_src <= 1'b0;
    end else begin
      rop_e            <= iop_d;
      rfunct3_e        <= ifunct3_d;
      rreg_write_e     <= wreg_write_d;
      rresult_src_e    <= wresult_src_d;
      rmem_write_e     <= wmem_write_d;
      oalu_ctrl      <= walu_ctrl_d;
      oalu_src       <= walu_src_d;
      opc_result_src <= wpc_result_src_d;
    end
  end

  always @(posedge iclk) begin : sproc_pipeline_exec_mem
    if (irst) begin
      oreg_write_m  <= 1'b0;
      odmem_wr_en  <= 1'b0;
      rresult_src_m <= {3{1'b0}};
    end else begin
      oreg_write_m  <= rreg_write_e;
      odmem_wr_en  <= rmem_write_e;
      rresult_src_m <= rresult_src_e;
    end
  end

  always @(posedge iclk) begin : sproc_pipeline_mem_wr
    if (irst) begin
      oreg_write_w  <= 1'b0;
      oresult_src <= {3{1'b0}};
    end else begin
      oreg_write_w  <= oreg_write_m;
      oresult_src <= rresult_src_m;
    end
  end

  // ============================================================================
  // riscv_ctrl
  // ============================================================================
  assign oresult_srcb0_e = rresult_src_e[0];

  riscv_ctrl_jumpdec u_jumpdec (
    .iop       (rop_e),
    .ifunct3   (rfunct3_e),
    .izero     (ialu_zero),
    .ioverflow (ialu_ovfl),
    .icarry    (ialu_carry),
    .inegative (ialu_neg),
    .opc_src   (opc_src)
  );

  riscv_ctrl_maindec u_maindec (
    .iop            (iop_d),
    .oresult_src    (wresult_src_d),
    .omem_wr        (wmem_write_d),
    .oalu_src       (walu_src_d),
    .oreg_wr        (wreg_write_d),
    .opc_result_src (wpc_result_src_d),
    .oimm_src       (oimm_src),
    .oalu_op        (walu_op_d)
  );

  riscv_ctrl_aludec u_aludec (
    .iop_b5     (iop_d[5]),
    .ifunct3    (ifunct3_d),
    .ifunct7_b5 (ifunct7b5_d),
    .iop        (walu_op_d),
    .octrl      (walu_ctrl_d)
  );

endmodule
