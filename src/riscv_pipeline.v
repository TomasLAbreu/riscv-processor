//------------------------------------------------------------------------------
module riscv_pipeline
//------------------------------------------------------------------------------
#(
  parameter MP_DATA_WIDTH = 32,
  parameter MP_ADDR_WIDTH = 5
)
(
  input wire                        iclk,
  input wire                        irst,

  input wire  [31:0]                iinstr_f,
  output wire [31:0]                opcf,
  output wire [1:0]                 oinstr_m,
  output wire                       omem_write_m,
  output wire [MP_DATA_WIDTH-1 : 0] oalu_result_m,

  input wire  [MP_DATA_WIDTH-1 : 0] irdata_m
  output wire [MP_DATA_WIDTH-1 : 0] owdata_m,
);
//------------------------------------------------------------------------------

  // ------ controler outputs
  wire [2:0] wresult_src_w;
  wire walu_src_e;

  wire wreg_wr_w;
  wire wreg_wr_m;

  wire wpc_result_src_e;
  wire [2:0] wimm_src_d;
  wire [3:0] walu_ctrl_e;
  wire wresult_srcb0_e;

  // ------ datapath outputs
  wire [4:0] wrs1_d;
  wire [4:0] wrs2_d;
  wire [4:0] wrs1_e;
  wire [4:0] wrs2_e;
  wire [4:0] wrd_e;
  wire wpc_src_e;

  wire [4:0] wrd_m;
  wire [4:0] wrd_w;

  wire [31:0] winstr_d;

  // ALU flags
  wire walu_zero_e;
  wire walu_overflow_e;
  wire walu_carry_e;
  wire walu_negative_e;

  // ------ hazard unit flags
  wire [1:0] whazard_forward_ae;
  wire [1:0] whazard_forward_be;
  wire whazard_stall_f;
  wire whazard_stall_d;
  wire whazard_flush_d;
  wire whazard_flush_e;

  wire [6:0] wop_d;
  wire [2:0] wfunct3_d;
  wire wfunct7b5_d;

  // ============================================================================
  // riscv pipeline processor
  // ============================================================================

  assign wop_d = winstr_d[6:0];
  assign wfunct3_d = winstr_d[14:12];
  assign wfunct7b5_d = winstr_d[30];

  controller u_ctrl (
    .iclk             (iclk),
    .irst             (irst),
    .iflush_e         (whazard_flush_e),
    .iop_d            (wop_d),
    .ifunct3_d        (wfunct3_d),
    .ifunct7b5_d      (wfunct7b5_d),
    .izero_e          (walu_zero_e),
    .ioverflow_e      (walu_overflow_e),
    .icarry_e         (walu_carry_e),
    .inegative_e      (walu_negative_e),
    .oresult_src_w    (wresult_src_w),
    .omem_write_m     (omem_write_m),
    .opc_src_e        (wpc_src_e),
    .oalu_src_e       (walu_src_e),
    .oreg_write_w     (wreg_wr_w),
    .oreg_write_m     (wreg_wr_m),
    .opc_result_src_e (wpc_result_src_e),
    .oimm_src_d       (wimm_src_d),
    .oalu_ctrl_e      (walu_ctrl_e),
    .oresult_srcb0_e  (wresult_srcb0_e)
  );

  datapath #(
    .MP_DATA_WIDTH (MP_DATA_WIDTH),
    .MP_ADDR_WIDTH (MP_ADDR_WIDTH)
  ) u_datapath (
    .iclk             (iclk),
    .irst             (irst),
    .iresult_src_w    (wresult_src_w),
    .ipc_src_e        (wpc_src_e),
    .ialu_src_e       (walu_src_e),
    .ireg_wr_w        (wreg_wr_w),
    .iimm_src_d       (wimm_src_d),
    .ialu_ctrl_e      (walu_ctrl_e),
    .ipc_result_src_e (wpc_result_src_e),
    .iforward_ae      (whazard_forward_ae),
    .iforward_be      (whazard_forward_be),
    .istall_f         (whazard_stall_f),
    .istall_d         (whazard_stall_d),
    .iflush_d         (whazard_flush_d),
    .iflush_e         (whazard_flush_e),
    .ors1_d           (wrs1_d),
    .ors2_d           (wrs2_d),
    .ors1_e           (wrs1_e),
    .ors2_e           (wrs2_e),
    .ord_e            (wrd_e),
    .ord_m            (wrd_m),
    .ord_w            (wrd_w),
    .oalu_zero_e      (walu_zero_e),
    .oalu_ovfl_e      (walu_overflow_e),
    .oalu_carry_e     (walu_carry_e),
    .oalu_neg_e       (walu_negative_e),
    .opc_f            (opcf),
    .iinstr_f         (iinstr_f),
    .oinstr_d         (winstr_d),
    .oalu_result_m    (oalu_result_m),
    .owdata_m         (owdata_m),
    .imem_data_m      (irdata_m),
    .oinstr2b_m       (oinstr_m)
  );

  hazard_unit u_hazard_unit (
    .irs1_decod           (wrs1_d),
    .irs2_decod           (wrs2_d),
    .irs1_exect           (wrs1_e),
    .irs2_exect           (wrs2_e),
    .ird_exect            (wrd_e),
    .ipc_src_exect        (wpc_src_e),
    .iresult_src_b0_exect (wresult_srcb0_e),
    .ird_mem              (wrd_m),
    .ird_wrt              (wrd_w),
    .ireg_wr_mem          (wreg_wr_m),
    .ireg_wr_wrt          (wreg_wr_w),
    .oforward_ae          (whazard_forward_ae),
    .oforward_be          (whazard_forward_be),
    .ostall_fetch         (whazard_stall_f),
    .ostall_decod         (whazard_stall_d),
    .oflush_decod         (whazard_flush_d),
    .oflush_exect         (whazard_flush_e)
  );

endmodule
