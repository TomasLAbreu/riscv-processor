//------------------------------------------------------------------------------
module riscv
//------------------------------------------------------------------------------
#(
  parameter MP_DATA_WIDTH = 32,
  parameter MP_ADDR_WIDTH = 5
)
(
	//TODO: parameterize instr* and PC
	//TODO: change rst to rstn
  input wire                        iclk,
  input wire                        irst,

  input wire  [31:0]                iinstr_f,
  output wire [31:0]                opcf,
  output wire [1:0]                 oinstr_m,
  output wire                       omem_write_m,
  output wire [MP_DATA_WIDTH-1 : 0] oalu_result_m,

  input wire  [MP_DATA_WIDTH-1 : 0] irdata_m,
  output wire [MP_DATA_WIDTH-1 : 0] owdata_m
);
//------------------------------------------------------------------------------

  // ------ controler outputs
  wire [2:0] wresult_src_w;
  wire walu_src_e;

  wire wreg_wr_wb;
  wire wreg_wr_mem;

  wire wpc_result_src_e;
  wire [2:0] wimm_src_d;
  wire [3:0] walu_ctrl_e;
  wire wresult_src_ex_b0;

  // ------ datapath outputs
  wire [4:0] wrs1_id;
  wire [4:0] wrs2_id;
  wire [4:0] wrs1_ex;
  wire [4:0] wrs2_ex;
  wire [4:0] wrd_ex;
  wire wpc_src_ex;

  wire [4:0] wrd_mem;
  wire [4:0] wrd_wb;

  wire [31:0] winstr_d;

  // ALU flags
  wire walu_zero_e;
  wire walu_overflow_e;
  wire walu_carry_e;
  wire walu_negative_e;

  // ------ hazard unit flags
  wire [1:0] whazard_forward_ae;
  wire [1:0] whazard_forward_be;
  wire whazard_stall_if;
  wire whazard_stall_id;
  wire whazard_flush_id;
  wire whazard_flush_ex;

  wire [6:0] wop_d;
  wire [2:0] wfunct3_d;
  wire wfunct7b5_d;

  // ============================================================================
  // riscv pipeline processor
  // ============================================================================
  //
  // follows 5 cycle stages through a pipeline:
  // 		if   	instruction fetch
  // 		id   	instruction decode
  // 		ex   	execute
  // 		mem  	access data memory
  // 		wb 		writeback
  //
  // ============================================================================

  assign wop_d = winstr_d[6:0];
  assign wfunct3_d = winstr_d[14:12];
  assign wfunct7b5_d = winstr_d[30];

  controller u_ctrl (
    .iclk             (iclk),
    .irst             (irst),
    .iflush_e         (whazard_flush_ex),
    .iop_d            (wop_d),
    .ifunct3_d        (wfunct3_d),
    .ifunct7b5_d      (wfunct7b5_d),
    .izero_e          (walu_zero_e),
    .ioverflow_e      (walu_overflow_e),
    .icarry_e         (walu_carry_e),
    .inegative_e      (walu_negative_e),
    .oresult_src_w    (wresult_src_w),
    .omem_write_m     (omem_write_m),
    .opc_src_e        (wpc_src_ex),
    .oalu_src_e       (walu_src_e),
    .oreg_write_w     (wreg_wr_wb),
    .oreg_write_m     (wreg_wr_mem),
    .opc_result_src_e (wpc_result_src_e),
    .oimm_src_d       (wimm_src_d),
    .oalu_ctrl_e      (walu_ctrl_e),
    .oresult_srcb0_e  (wresult_src_ex_b0)
  );

  datapath #(
    .MP_DATA_WIDTH (MP_DATA_WIDTH),
    .MP_ADDR_WIDTH (MP_ADDR_WIDTH)
  ) u_datapath (
    .iclk             (iclk),
    .irst             (irst),
    .iresult_src_w    (wresult_src_w),
    .ipc_src_e        (wpc_src_ex),
    .ialu_src_e       (walu_src_e),
    .ireg_wr_w        (wreg_wr_wb),
    .iimm_src_d       (wimm_src_d),
    .ialu_ctrl_e      (walu_ctrl_e),
    .ipc_result_src_e (wpc_result_src_e),
    .iforward_ae      (whazard_forward_ae),
    .iforward_be      (whazard_forward_be),
    .istall_f         (whazard_stall_if),
    .istall_d         (whazard_stall_id),
    .iflush_d         (whazard_flush_id),
    .iflush_e         (whazard_flush_ex),
    .ors1_d           (wrs1_id),
    .ors2_d           (wrs2_id),
    .ors1_e           (wrs1_ex),
    .ors2_e           (wrs2_ex),
    .ord_e            (wrd_ex),
    .ord_m            (wrd_mem),
    .ord_w            (wrd_wb),
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
		.irs1_id           (wrs1_id),
		.irs2_id           (wrs2_id),
		.irs1_ex           (wrs1_ex),
		.irs2_ex           (wrs2_ex),
		.ird_ex            (wrd_ex),
		.ipc_src_ex        (wpc_src_ex),
		.iresult_src_ex_b0 (wresult_src_ex_b0),
		.ird_mem           (wrd_mem),
		.ird_wb            (wrd_wb),
		.ireg_wr_mem       (wreg_wr_mem),
		.ireg_wr_wb        (wreg_wr_wb),
		.oforward_ae       (whazard_forward_ae),
		.oforward_be       (whazard_forward_be),
		.ostall_if         (whazard_stall_if),
		.ostall_id         (whazard_stall_id),
		.oflush_id         (whazard_flush_id),
		.oflush_ex         (whazard_flush_ex)
	);


endmodule
