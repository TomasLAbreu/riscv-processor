//------------------------------------------------------------------------------
module riscv_ctrl_jumpdec
//------------------------------------------------------------------------------
(
  input wire  [6:0] iop,
  input wire  [2:0] ifunct3,

  // ALU flags
  input wire        ialu_zero,
  input wire        ialu_ovfl,
  input wire        ialu_carry,
  input wire        ialu_neg,

  output reg        opc_src // selects between PC Result (1) or PC+4
);
//------------------------------------------------------------------------------

  localparam [6:0]
    LP_OP_B    = 7'b110_0011, // branch ops
    LP_OP_JALR = 7'b110_0111,
    LP_OP_JAL  = 7'b110_1111;

  localparam [2:0]
    LP_OP_BEQ  = 3'b000, // branch if equal
    LP_OP_BNE  = 3'b001, // branch if not equal
    LP_OP_BLT  = 3'b100, // branch if less then
    LP_OP_BGE  = 3'b101, // branch if bigger or equal
    LP_OP_BLTU = 3'b110, // branch if less then (unsigned)
    LP_OP_BGEU = 3'b111; // branch if bigger or equal (unsigned)

  always @(*) begin : cproc_jumpdec
    case (iop)
      LP_OP_B:
        case (ifunct3)
          LP_OP_BEQ:  opc_src = ialu_zero;
          LP_OP_BNE:  opc_src = ~ialu_zero;
          LP_OP_BLT:  opc_src = ialu_neg ^ ialu_ovfl;
          LP_OP_BGE:  opc_src = ~ialu_zero & ~(ialu_neg ^ ialu_ovfl);
          LP_OP_BLTU: opc_src = ~ialu_carry;
          LP_OP_BGEU: opc_src = ialu_carry;
        endcase

      LP_OP_JALR: opc_src = 1'b1;
      LP_OP_JAL:  opc_src = 1'b1;
      default:    opc_src = 1'b0;
    endcase
  end

endmodule : riscv_ctrl_jumpdec
