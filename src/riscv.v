
// ============================================================================
// riscv pipeline processor
// ============================================================================
//
// follows 5 cycle stages through a pipeline:
//    if    instruction fetch
//    id    instruction decode
//    ex    execute
//    mem   access data memory
//    wb    writeback
//
// ============================================================================

//------------------------------------------------------------------------------
module riscv
//------------------------------------------------------------------------------
#(
  parameter MP_DATA_WIDTH = 32,
  parameter MP_ADDR_WIDTH = 5,
  parameter MP_ENDIANESS = `RISCV_BIG_ENDIAN
)
(
	//TODO: parameterize instr* and PC
	//TODO: change rst to rstn
  input wire                        iclk,
  input wire                        irst,

  // Instruction memory
  input  wire [31:0]                iinstr, // Instruction
  output wire [31:0]                opc,    // Program counter

  // Data memory
  output wire [31:0]                odmem_addr,
  output wire [1:0]                 odmem_wr_be,
  output wire                       odmem_wr_en,
  output wire [MP_DATA_WIDTH-1 : 0] odmem_wr_data,
  input  wire [MP_DATA_WIDTH-1 : 0] idmem_rd_data
);
//------------------------------------------------------------------------------

  // ------ controler outputs
  wire [2:0] wresult_src;
  wire walu_src;

  wire wregfile_wr_en3;
  wire wreg_wr_mem;

  wire wpc_result_src;
  wire [2:0] wimm_src;
  wire [3:0] walu_ctrl;
  wire wresult_src_ex_b0;

  // ------ datapath outputs
  wire [4:0] wregfile_addr1;
  wire [4:0] wregfile_addr2;
  wire [4:0] wregfile_addr1_1d;
  wire [4:0] wregfile_addr2_1d;
  wire [4:0] wrd_ex;
  wire wpc_src;

  wire [4:0] wrd_mem;
  wire [4:0] wregfile_addr3;

  wire [31:0] winstr;

  // ALU flags
  wire walu_zero;
  wire walu_ovfl;
  wire walu_carry;
  wire walu_neg;

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

  assign wop_d = winstr[6:0];
  assign wfunct3_d = winstr[14:12];
  assign wfunct7b5_d = winstr[30];

  riscv_ctrl u_ctrl (
    .iclk             (iclk),
    .irst             (irst),
    .iflush_e         (whazard_flush_ex),
    .iop_d            (wop_d),
    .ifunct3_d        (wfunct3_d),
    .ifunct7b5_d      (wfunct7b5_d),

    .oalu_src         (walu_src),
    .oalu_ctrl        (walu_ctrl),
    .ialu_zero        (walu_zero),
    .ialu_ovfl        (walu_ovfl),
    .ialu_carry       (walu_carry),
    .ialu_neg         (walu_neg),
    .oresult_src      (wresult_src),

    .odmem_wr_en      (odmem_wr_en),
    .opc_src          (wpc_src),
    .oreg_write_w     (wregfile_wr_en3),
    .oreg_write_m     (wreg_wr_mem),
    .opc_result_src   (wpc_result_src),
    .oimm_src         (wimm_src),
    .oresult_srcb0_e  (wresult_src_ex_b0)
  );

  riscv_dp #(
    .MP_DATA_WIDTH (MP_DATA_WIDTH),
    .MP_ADDR_WIDTH (MP_ADDR_WIDTH),
    .MP_ENDIANESS  (MP_ENDIANESS),
  ) u_datapath (
    .iclk             (iclk),
    .irst             (irst),
    .iresult_src      (wresult_src),
    .iimm_src         (wimm_src),
    .ipc_src          (wpc_src),
    .ipc_result_src   (wpc_result_src),
    .iforward_ae      (whazard_forward_ae),
    .iforward_be      (whazard_forward_be),
    .istall_f         (whazard_stall_if),
    .istall_d         (whazard_stall_id),
    .iflush_d         (whazard_flush_id),
    .iflush_e         (whazard_flush_ex),
    .oregfile_addr1    (wregfile_addr1),
    .oregfile_addr2    (wregfile_addr2),
    .oregfile_addr1_1d (wregfile_addr1_1d),
    .oregfile_addr2_1d (wregfile_addr2_1d),
    .iregfile_wr_en3   (wregfile_wr_en3),
    .oregfile_addr3    (wregfile_addr3),
    .ord_e            (wrd_ex),
    .ord_m            (wrd_mem),
    .ialu_ctrl        (walu_ctrl),
    .ialu_src         (walu_src),
    .oalu_result      (odmem_addr),
    .oalu_zero        (walu_zero),
    .oalu_ovfl        (walu_ovfl),
    .oalu_carry       (walu_carry),
    .oalu_neg         (walu_neg),
    .opc              (opc),
    //
    .iinstr_nxt       (iinstr),
    .oinstr           (winstr),
    .odmem_wr_data    (odmem_wr_data),
    .idmem_rd_data    (idmem_rd_data),
    .odmem_wr_be      (odmem_wr_be)
  );

	riscv_hazard_unit u_hazard_unit (
		.irs1_id           (wregfile_addr1),
		.irs2_id           (wregfile_addr2),
		.irs1_ex           (wregfile_addr1_1d),
		.irs2_ex           (wregfile_addr2_1d),
		.ird_ex            (wrd_ex),
		.ipc_src_ex        (wpc_src),
		.iresult_src_ex_b0 (wresult_src_ex_b0),
		.ird_mem           (wrd_mem),
		.ird_wb            (wregfile_addr3),
		.ireg_wr_mem       (wreg_wr_mem),
		.ireg_wr_wb        (wregfile_wr_en3),
		.oforward_ae       (whazard_forward_ae),
		.oforward_be       (whazard_forward_be),
		.ostall_if         (whazard_stall_if),
		.ostall_id         (whazard_stall_id),
		.oflush_id         (whazard_flush_id),
		.oflush_ex         (whazard_flush_ex)
	);

endmodule
