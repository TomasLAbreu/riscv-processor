`include "riscv_constants.vh"

//------------------------------------------------------------------------------
module riscv_dp_alu
//------------------------------------------------------------------------------
#(
  parameter MP_DATA_WIDTH = 32,
  parameter MP_ENDIANESS = `RISCV_BIG_ENDIAN
)
(
  input wire        [3:0]                 ictrl,
  input wire signed [MP_DATA_WIDTH-1 : 0] isrc_a,
  input wire        [MP_DATA_WIDTH-1 : 0] isrc_b,
  // ALU flags
  output wire                             ozero,
  output wire                             ooverflow,
  output wire                             ocarry,
  output wire                             onegative,
  output reg        [MP_DATA_WIDTH-1 : 0] oresult
);
//------------------------------------------------------------------------------

  // assume little endian as default
  localparam LP_LSB = (MP_ENDIANESS == `RISCV_BIG_ENDIAN) ? (MP_DATA_WIDTH-1) : 0;

  wire [MP_DATA_WIDTH-1 : 0] wsum;
  wire [MP_DATA_WIDTH-1 : 0] winv_result;
  wire wcarry_out;
  wire waux1; // rename this -> find out what it means
  wire waux2;

  // auxiliar wires
  assign winv_result = ictrl[0] ? (~isrc_b + 1) : isrc_b;
  assign {wcarry_out, wsum} = isrc_a + winv_result;
  assign waux1 = ~(ictrl[0] ^ isrc_a[LP_LSB] ^ isrc_b[LP_LSB]);
  assign waux2 = (isrc_a[LP_LSB] ^ wsum[LP_LSB]);

  // ALU flags
  assign ozero     = (oresult == {MP_DATA_WIDTH{1'b0}});
  assign onegative = oresult[LP_LSB];
  assign ocarry    = ~ictrl[1] & wcarry_out;
  assign ooverflow = ~ictrl[1] & waux1 & waux2;

  always @(*) begin : cproc_riscv_dp_alu
    case (ictrl)
      `RISCV_ALU_ADD_OP : oresult = wsum;
      `RISCV_ALU_SUB_OP : oresult = wsum;
      `RISCV_ALU_AND_OP : oresult = isrc_a & isrc_b;
      `RISCV_ALU_OR_OP  : oresult = isrc_a | isrc_b;
      `RISCV_ALU_SLT_OP : oresult = {{MP_DATA_WIDTH-1{1'b0}}, ooverflow ^ wsum[LP_LSB]};
      `RISCV_ALU_SLTU_OP: oresult = {{MP_DATA_WIDTH-1{1'b0}}, ~ocarry};
      `RISCV_ALU_XOR_OP : oresult = isrc_a ^ isrc_b;
      `RISCV_ALU_SL_OP  : oresult = isrc_a << isrc_b[4:0];// TODO: why 4:0 - not paramaeterizable
      `RISCV_ALU_SR_OP  : oresult = isrc_a >> isrc_b[4:0];
      `RISCV_ALU_SRA_OP : oresult = isrc_a >>> isrc_b[4:0];
      default:  oresult = oresult;
    endcase
  end

endmodule : riscv_dp_alu
