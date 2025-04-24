module riscv_ctrl (
  input             iclk,
  input             irst,
  input             iflush_e,

  input wire  [6:0] iop,
  input wire  [2:0] ifunct3,
  input wire        ifunct7b5,

  // ALU flags
  input wire        ialu_zero,
  input wire        ialu_ovfl,
  input wire        ialu_carry,
  input wire        ialu_neg,
  output reg        oalu_src,
  output reg  [3:0] oalu_ctrl,

  output reg  [2:0] oresult_src_2d,
  output wire       oresult_srcb0,

  output reg        odmem_wr_en,
  output reg        oreg_write_1d,
  output reg        oreg_write,
  output wire       opc_src,
  output reg        opc_result_src,
  output wire [2:0] oimm_src
);

  wire [1:0] walu_op;

  // ============================================================================
  // pipeline Decode - Execute
  // ============================================================================
  wire        wreg_write_nxt;
  wire  [2:0] wresult_src_nxt;
  wire        wdmem_wr_en_nxt;
  wire  [3:0] walu_ctrl_nxt;
  wire        walu_src_nxt;
  wire        wpc_result_src_nxt;

  reg [6:0] rop_e;
  reg [2:0] rfunct3;
  reg       rreg_write;
  reg [2:0] rresult_src;
  reg       rdmem_wr_en;

  // ============================================================================
  // pipeline Execute - Memory
  // ============================================================================
  reg  [2:0] rresult_src_1d;

  // ============================================================================
  // pipelines
  // ============================================================================

  always @(posedge iclk) begin : sproc_pipeline_dec_exec
    if (irst || iflush_e) begin
      rop_e          <= {7{1'b0}};
      rfunct3        <= {3{1'b0}};
      rreg_write     <= 1'b0;
      rresult_src    <= {3{1'b0}};
      rdmem_wr_en    <= 1'b0;
      oalu_ctrl      <= {4{1'b0}};
      oalu_src       <= 1'b0;
      opc_result_src <= 1'b0;
    end else begin
      rop_e          <= iop;
      rfunct3        <= ifunct3;
      rreg_write     <= wreg_write_nxt;
      rresult_src    <= wresult_src_nxt;
      rdmem_wr_en    <= wdmem_wr_en_nxt;
      oalu_ctrl      <= walu_ctrl_nxt;
      oalu_src       <= walu_src_nxt;
      opc_result_src <= wpc_result_src_nxt;
    end
  end

  always @(posedge iclk) begin : sproc_pipeline_exec_mem
    if (irst) begin
      oreg_write     <= 1'b0;
      odmem_wr_en    <= 1'b0;
      rresult_src_1d <= {3{1'b0}};
    end else begin
      oreg_write     <= rreg_write;
      odmem_wr_en    <= rdmem_wr_en;
      rresult_src_1d <= rresult_src;
    end
  end

  always @(posedge iclk) begin : sproc_pipeline_mem_wr
    if (irst) begin
      oreg_write_1d  <= 1'b0;
      oresult_src_2d <= {3{1'b0}};
    end else begin
      oreg_write_1d  <= oreg_write;
      oresult_src_2d <= rresult_src_1d;
    end
  end

  // ============================================================================
  // riscv_ctrl
  // ============================================================================
  assign oresult_srcb0 = rresult_src[0];

  riscv_ctrl_maindec u_maindec (
    .iop            (iop),
    .oresult_src    (wresult_src_nxt),
    .odmem_wr_en    (wdmem_wr_en_nxt),
    .oalu_src       (walu_src_nxt),
    .oreg_wr        (wreg_write_nxt),
    .opc_result_src (wpc_result_src_nxt),
    .oimm_src       (oimm_src),
    .oalu_op        (walu_op)
  );

  riscv_ctrl_aludec u_aludec (
    .ialu_op    (walu_op),
    .iop_b5     (iop[5]),
    .ifunct3    (ifunct3),
    .ifunct7_b5 (ifunct7b5),
    .oalu_ctrl  (walu_ctrl_nxt)
  );

  riscv_ctrl_jumpdec u_jumpdec (
    .iop        (rop_e),
    .ifunct3    (rfunct3),
    .ialu_zero  (ialu_zero),
    .ialu_ovfl  (ialu_ovfl),
    .ialu_carry (ialu_carry),
    .ialu_neg   (ialu_neg),
    .opc_src    (opc_src)
  );

endmodule
