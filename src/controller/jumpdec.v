//------------------------------------------------------------------------------
module jumpdec
//------------------------------------------------------------------------------
(
  input wire  [6:0] iop,
  input wire  [2:0] ifunct3,

  input wire        izero,
  input wire        ioverflow,
  input wire        icarry,
  input wire        inegative,

  output reg        opc_src
);
//------------------------------------------------------------------------------

  localparam [6:0]
    LP_OP_B    = 7'b110_0011, // branch ops
    LP_OP_JALR = 7'b110_0111,
    LP_OP_JAL  = 7'b110_1111;

  localparam [2:0]
    LP_OP_BEQ  = 3'b000, // equal
    LP_OP_BNE  = 3'b001, // not equal
    LP_OP_BLT  = 3'b100, // less then
    LP_OP_BGE  = 3'b101, // bigger or equal
    LP_OP_BLTU = 3'b110, // less then (unsigned)
    LP_OP_BGEU = 3'b111; // bigger or equal (unsigned)

  always @(*) begin : cproc_jumpdec
    case (iop)
      LP_OP_B:
        case (ifunct3)
          LP_OP_BEQ:  opc_src = izero;
          LP_OP_BNE:  opc_src = ~izero;
          LP_OP_BLT:  opc_src = inegative ^ ioverflow;
          LP_OP_BGE:  opc_src = ~izero & ~(inegative ^ ioverflow);
          LP_OP_BLTU: opc_src = ~icarry;
          LP_OP_BGEU: opc_src = icarry;
        endcase

      LP_OP_JALR: opc_src = 1;
      LP_OP_JAL:  opc_src = 1;
      default:    opc_src = 0;
    endcase
  end

endmodule : jumpdec
