`include "alu_constants.vh"

//------------------------------------------------------------------------------
module aludec
//------------------------------------------------------------------------------
(
  input wire        iop_b5,
  input wire  [2:0] ifunct3,
  input wire        ifunct7_b5,
  input wire  [1:0] iop,
  output reg  [3:0] octrl
);
//------------------------------------------------------------------------------

  wire wrtype_sub;

  localparam [1:0]
    LP_ALUOP_TYPE_I   = 2'b00,
    LP_ALUOP_TYPE_BEQ = 2'b01;

  localparam [2:0]
    LP_ALUOP_ADD  = 3'b000,
    LP_ALUOP_SL   = 3'b001, // shift left logical
    LP_ALUOP_SLT  = 3'b010, // set less than signed
    LP_ALUOP_SLTU = 3'b011, // set less than unsigned
    LP_ALUOP_XOR  = 3'b100,
    LP_ALUOP_SR   = 3'b101, // shift right arithmetic/logic
    LP_ALUOP_OR   = 3'b110,
    LP_ALUOP_AND  = 3'b111;

  assign wrtype_sub = ifunct7_b5 & iop_b5;

  always @(*) begin : cproc_aludec
    case (iop)
      LP_ALUOP_TYPE_I:   octrl = `ADD_OP;
      LP_ALUOP_TYPE_BEQ: octrl = `SUB_OP;
      default: begin
        case (ifunct3)
          LP_ALUOP_ADD:  octrl = wrtype_sub ? `SUB_OP : `ADD_OP;
          LP_ALUOP_SL:   octrl = `SL_OP;
          LP_ALUOP_SLT:  octrl = `SLT_OP;
          LP_ALUOP_SLTU: octrl = `SLTU_OP;
          LP_ALUOP_XOR:  octrl = `XOR_OP;
          LP_ALUOP_SR:   octrl = ifunct7_b5 ? `SRA_OP : `SR_OP;
          LP_ALUOP_OR:   octrl = `OR_OP;
          LP_ALUOP_AND:  octrl = `AND_OP;
          default:       octrl = `NOP_OP;
        endcase
      end
    endcase
  end

endmodule : aludec
