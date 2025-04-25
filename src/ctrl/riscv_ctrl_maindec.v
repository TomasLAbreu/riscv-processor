//------------------------------------------------------------------------------
module riscv_ctrl_maindec
//------------------------------------------------------------------------------
(
  input wire  [6:0] iop,

  output wire [2:0] oresult_src, // selects result for regfile addr3
  output wire       odmem_wr_en,
  output wire       oalu_src,
  output wire       ord_wr_en,

  output wire       opc_result_src, // selects between ALUResult and (PC+ImmExt)
  output wire [2:0] oimm_src,
  output wire [1:0] oalu_op
);
//------------------------------------------------------------------------------

  localparam [6:0]
    LP_OP_LOAD     = 7'b000_0011,
    LP_OP_STORE    = 7'b010_0011,
    LP_OP_R        = 7'b011_0011,
    LP_OP_BRANCH   = 7'b110_0011,
    LP_OP_I        = 7'b001_0011,
    LP_OP_JUMPLINK = 7'b110_1111,
    LP_OP_AUIPC    = 7'b001_0111,
    LP_OP_LUI      = 7'b011_0111,
    LP_OP_JALR     = 7'b110_0111;

  localparam [11:0]
    // 3: load - lx, rd, imm(rs1)
    LP_OP_CTRL_LOAD     = 12'b1_000_1_0_001_00_0,
    // 0x23 = 35: store - sx, rs2, imm(rs1)
    LP_OP_CTRL_STORE    = 12'b0_001_1_1_111_00_0,
    // 0x33 = 51: Type R - xxx, rd, rs1, rs2
    LP_OP_CTRL_R        = 12'b1_000_0_0_000_10_0,
    // 0x63 = 99: branch - bxx, rs1, rs2, label
    LP_OP_CTRL_BRANCH   = 12'b0_010_0_0_000_01_0,
    // 0x13 = 19: Type I - xxxi, rd, rs1, imm
    LP_OP_CTRL_I        = 12'b1_000_1_0_000_10_0,
    // 0x6F = 111: jump and link - jal, rd, label
    LP_OP_CTRL_JUMPLINK = 12'b1_011_0_0_010_00_0,
    // 23: auipc rd, upimm (U)
    LP_OP_CTRL_AUIPC    = 12'b1_100_0_0_101_00_0,
    // 55: lui rd, upimm (U)
    LP_OP_CTRL_LUI      = 12'b1_100_0_0_011_00_0,
    // 103: jalr rd, rs1, imm (I)
    LP_OP_CTRL_JALR     = 12'b1_000_1_0_010_10_1;

  reg [11:0] wctrls;

  assign {ord_wr_en,oimm_src,oalu_src,odmem_wr_en,oresult_src,oalu_op,opc_result_src} = wctrls;

  always @(*) begin : cproc_maindec
    case (iop)
      LP_OP_LOAD:     wctrls = LP_OP_CTRL_LOAD;
      LP_OP_STORE:    wctrls = LP_OP_CTRL_STORE;
      LP_OP_R:        wctrls = LP_OP_CTRL_R;
      LP_OP_BRANCH:   wctrls = LP_OP_CTRL_BRANCH;
      LP_OP_I:        wctrls = LP_OP_CTRL_I;
      LP_OP_JUMPLINK: wctrls = LP_OP_CTRL_JUMPLINK;
      LP_OP_AUIPC:    wctrls = LP_OP_CTRL_AUIPC;
      LP_OP_LUI:      wctrls = LP_OP_CTRL_LUI;
      LP_OP_JALR:     wctrls = LP_OP_CTRL_JALR;
      default: wctrls = {12{1'b0}};
    endcase
  end

endmodule : riscv_ctrl_maindec
