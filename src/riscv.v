
// ============================================================================
// RISCV pipeline processor
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
  parameter MP_DATA_WIDTH         = 32,
  parameter MP_ADDR_WIDTH         = 5,
  parameter MP_PC_WIDTH           = 32,
  parameter MP_REGFILE_ADDR_WIDTH = 5,
  parameter MP_ENDIANESS          = `RISCV_BIG_ENDIAN
)
(
  input wire                        iclk,
  input wire                        irst_n,
  // TODO: add interrupt request? stalls everything?
  // Instruction memory
  input  wire [31:0]                iinstr,
  output wire [MP_PC_WIDTH-1:0]     opc,

  // Data memory
  output wire [31:0]                odmem_addr,
  output wire [1:0]                 odmem_wr_be,
  output wire                       odmem_wr_en,
  output wire [MP_DATA_WIDTH-1 : 0] odmem_wr_data,
  input  wire [MP_DATA_WIDTH-1 : 0] idmem_rd_data
);
//------------------------------------------------------------------------------

  // ------ controler outputs
  wire [2:0] wctrl_rd_wr_data_src;
  wire wctrl_alu_src;

  wire wctrl_rd_wr_en_2d;
  wire wctrl_rd_wr_en_1d;

  wire wctrl_pc_result_src;
  wire [2:0] wctrl_imm_src;
  wire [3:0] wctrl_alu_ctrl;
  wire wctrl_rd_wr_data_srcb0;

  // ------ datapath outputs
  wire [4:0] wdp_rs1;
  wire [4:0] wdp_rs2;
  wire [4:0] wdp_rs1_1d;
  wire [4:0] wdp_rs2_1d;
  wire [4:0] wdp_rd_1d;
  wire wctrl_pc_src;

  wire [4:0] wdp_rd_2d;
  wire [4:0] wdp_rd_3d;

  wire [31:0] wdp_instr;

  // ALU flags
  wire wdp_alu_zero;
  wire wdp_alu_ovfl;
  wire wdp_alu_carry;
  wire wdp_alu_neg;

  // ------ hazard unit flags
  wire [1:0] whazard_forward_alu_src_a;
  wire [1:0] whazard_forward_alu_src_b;
  wire whazard_stall_f;
  wire whazard_stall_d;
  wire whazard_flush_d;
  wire whazard_flush_e;

  wire [6:0] wop;
  wire [2:0] wfunct3;
  wire wfunct7b5;

  assign wop = wdp_instr[6:0];
  assign wfunct3 = wdp_instr[14:12];
  assign wfunct7b5 = wdp_instr[30];

  riscv_ctrl u_ctrl (
    .iclk               (iclk),
    .irst_n             (irst_n),
    .iflush_e           (whazard_flush_e),
    .iop                (wop),
    .ifunct3            (wfunct3),
    .ifunct7b5          (wfunct7b5),
    .oalu_src           (wctrl_alu_src),
    .oalu_ctrl          (wctrl_alu_ctrl),
    .ialu_zero          (wdp_alu_zero),
    .ialu_ovfl          (wdp_alu_ovfl),
    .ialu_carry         (wdp_alu_carry),
    .ialu_neg           (wdp_alu_neg),
    .ord_wr_data_src_2d (wctrl_rd_wr_data_src),
    .ord_wr_data_srcb0  (wctrl_rd_wr_data_srcb0),
    .odmem_wr_en_1d     (odmem_wr_en),
    .ord_wr_en_1d       (wctrl_rd_wr_en_1d),
    .ord_wr_en_2d       (wctrl_rd_wr_en_2d),
    .opc_src            (wctrl_pc_src),
    .opc_result_src     (wctrl_pc_result_src),
    .oimm_src           (wctrl_imm_src)
  );

  riscv_dp #(
    .MP_DATA_WIDTH         (MP_DATA_WIDTH),
    .MP_ADDR_WIDTH         (MP_ADDR_WIDTH),
    .MP_REGFILE_ADDR_WIDTH (MP_REGFILE_ADDR_WIDTH),
    .MP_ENDIANESS          (MP_ENDIANESS)
  ) u_datapath (
    .iclk               (iclk),
    .irst_n             (irst_n),
    .iforward_alu_src_a (whazard_forward_alu_src_a),
    .iforward_alu_src_b (whazard_forward_alu_src_b),
    .istall_f           (whazard_stall_f),
    .istall_d           (whazard_stall_d),
    .iflush_d           (whazard_flush_d),
    .iflush_e           (whazard_flush_e),
    .iinstr_nxt         (iinstr),
    .oinstr             (wdp_instr),
    .ipc_src            (wctrl_pc_src),
    .ipc_result_src     (wctrl_pc_result_src),
    .opc                (opc),
    .iimm_src           (wctrl_imm_src),
    .ors1               (wdp_rs1),
    .ors1_1d            (wdp_rs1_1d),
    .ors2               (wdp_rs2),
    .ors2_1d            (wdp_rs2_1d),
    .ird_wr_en          (wctrl_rd_wr_en_2d),
    .ird_wr_data_src    (wctrl_rd_wr_data_src),
    .ord_1d             (wdp_rd_1d),
    .ord_2d             (wdp_rd_2d),
    .ord_3d             (wdp_rd_3d),
    .ialu_ctrl          (wctrl_alu_ctrl),
    .ialu_src           (wctrl_alu_src),
    .oalu_result        (odmem_addr),
    .oalu_zero          (wdp_alu_zero),
    .oalu_ovfl          (wdp_alu_ovfl),
    .oalu_carry         (wdp_alu_carry),
    .oalu_neg           (wdp_alu_neg),
    .odmem_wr_data      (odmem_wr_data),
    .idmem_rd_data      (idmem_rd_data),
    .odmem_wr_be        (odmem_wr_be)
  );

	riscv_hazard_unit #(
    .MP_REGFILE_ADDR_WIDTH (MP_REGFILE_ADDR_WIDTH)
  ) u_hazard_unit (
    .ipc_src            (wctrl_pc_src),
    .ilw_ongoing        (wctrl_rd_wr_data_srcb0),
    .irs1               (wdp_rs1),
    .irs1_1d            (wdp_rs1_1d),
    .irs2               (wdp_rs2),
    .irs2_1d            (wdp_rs2_1d),
    .ird_1d             (wdp_rd_1d),
    .ird_2d             (wdp_rd_2d),
    .ird_3d             (wdp_rd_3d),
    .ird_wr_en_1d       (wctrl_rd_wr_en_1d),
    .ird_wr_en_2d       (wctrl_rd_wr_en_2d),
    .oforward_alu_src_a (whazard_forward_alu_src_a),
    .oforward_alu_src_b (whazard_forward_alu_src_b),
    .ostall_f           (whazard_stall_f),
    .ostall_d           (whazard_stall_d),
    .oflush_d           (whazard_flush_d),
    .oflush_e           (whazard_flush_e)
	);

endmodule
