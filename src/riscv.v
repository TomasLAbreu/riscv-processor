
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
  wire [2:0] wctrl_result_src;
  wire wctrl_alu_src;

  wire wctrl_regfile_wr_en3;
  wire wctrl_reg_wr_mem;

  wire wctrl_pc_result_src;
  wire [2:0] wctrl_imm_src;
  wire [3:0] wctrl_alu_ctrl;
  wire wctrl_result_srcb0;

  // ------ datapath outputs
  wire [4:0] wdp_regfile_addr1;
  wire [4:0] wdp_regfile_addr2;
  wire [4:0] wdp_regfile_addr1_1d;
  wire [4:0] wdp_regfile_addr2_1d;
  wire [4:0] wdp_rd_ex;
  wire wctrl_pc_src;

  wire [4:0] wdp_rd_mem;
  wire [4:0] wdp_regfile_addr3;

  wire [31:0] wdp_instr;

  // ALU flags
  wire wdp_alu_zero;
  wire wdp_alu_ovfl;
  wire wdp_alu_carry;
  wire wdp_alu_neg;

  // ------ hazard unit flags
  wire [1:0] whazard_forward_ae;
  wire [1:0] whazard_forward_be;
  wire whazard_stall_if;
  wire whazard_stall_id;
  wire whazard_flush_id;
  wire whazard_flush_ex;

  wire [6:0] wop;
  wire [2:0] wfunct3;
  wire wfunct7b5;

  assign wop = wdp_instr[6:0];
  assign wfunct3 = wdp_instr[14:12];
  assign wfunct7b5 = wdp_instr[30];

  riscv_ctrl u_ctrl (
    .iclk             (iclk),
    .irst             (irst),
    .iflush_e         (whazard_flush_ex),
    .iop              (wop),
    .ifunct3          (wfunct3),
    .ifunct7b5        (wfunct7b5),
    .oalu_src         (wctrl_alu_src),
    .oalu_ctrl        (wctrl_alu_ctrl),
    .ialu_zero        (wdp_alu_zero),
    .ialu_ovfl        (wdp_alu_ovfl),
    .ialu_carry       (wdp_alu_carry),
    .ialu_neg         (wdp_alu_neg),
    .oresult_src_2d   (wctrl_result_src),
    .oresult_srcb0    (wctrl_result_srcb0),
    .odmem_wr_en      (odmem_wr_en),
    .oreg_write       (wctrl_reg_wr_mem),
    .oreg_write_1d    (wctrl_regfile_wr_en3),
    .opc_src          (wctrl_pc_src),
    .opc_result_src   (wctrl_pc_result_src),
    .oimm_src         (wctrl_imm_src)
  );

  riscv_dp #(
    .MP_DATA_WIDTH (MP_DATA_WIDTH),
    .MP_ADDR_WIDTH (MP_ADDR_WIDTH),
    .MP_ENDIANESS  (MP_ENDIANESS)
  ) u_datapath (
    .iclk              (iclk),
    .irst              (irst),
    .iforward_ae       (whazard_forward_ae),
    .iforward_be       (whazard_forward_be),
    .istall_f          (whazard_stall_if),
    .istall_d          (whazard_stall_id),
    .iflush_d          (whazard_flush_id),
    .iflush_e          (whazard_flush_ex),
    .iinstr_nxt        (iinstr),
    .oinstr            (wdp_instr),
    .ipc_src           (wctrl_pc_src),
    .ipc_result_src    (wctrl_pc_result_src),
    .opc               (opc),
    .iimm_src          (wctrl_imm_src),
    .oregfile_addr1    (wdp_regfile_addr1),
    .oregfile_addr2    (wdp_regfile_addr2),
    .oregfile_addr1_1d (wdp_regfile_addr1_1d),
    .oregfile_addr2_1d (wdp_regfile_addr2_1d),
    .iregfile_wr_en3   (wctrl_regfile_wr_en3),
    .iresult_src       (wctrl_result_src),
    .oregfile_addr3    (wdp_regfile_addr3),
    .ord_e             (wdp_rd_ex),
    .ord_m             (wdp_rd_mem),
    .ialu_ctrl         (wctrl_alu_ctrl),
    .ialu_src          (wctrl_alu_src),
    .oalu_result       (odmem_addr),
    .oalu_zero         (wdp_alu_zero),
    .oalu_ovfl         (wdp_alu_ovfl),
    .oalu_carry        (wdp_alu_carry),
    .oalu_neg          (wdp_alu_neg),
    .odmem_wr_data     (odmem_wr_data),
    .idmem_rd_data     (idmem_rd_data),
    .odmem_wr_be       (odmem_wr_be)
  );

	riscv_hazard_unit u_hazard_unit (
		.irs1_id           (wdp_regfile_addr1),
		.irs2_id           (wdp_regfile_addr2),
		.irs1_ex           (wdp_regfile_addr1_1d),
		.irs2_ex           (wdp_regfile_addr2_1d),
		.ird_ex            (wdp_rd_ex),
		.ipc_src_ex        (wctrl_pc_src),
		.iresult_src_ex_b0 (wctrl_result_srcb0),
		.ird_mem           (wdp_rd_mem),
		.ird_wb            (wdp_regfile_addr3),
		.ireg_wr_mem       (wctrl_reg_wr_mem),
		.ireg_wr_wb        (wctrl_regfile_wr_en3),
		.oforward_ae       (whazard_forward_ae),
		.oforward_be       (whazard_forward_be),
		.ostall_if         (whazard_stall_if),
		.ostall_id         (whazard_stall_id),
		.oflush_id         (whazard_flush_id),
		.oflush_ex         (whazard_flush_ex)
	);

endmodule
