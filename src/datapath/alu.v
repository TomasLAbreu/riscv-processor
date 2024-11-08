`include "alu_constants.vh"

//------------------------------------------------------------------------------
module alu
//------------------------------------------------------------------------------
#(
  parameter MP_DATA_WIDTH = 32
)
(
  input wire signed [3:0]                  ictrl,

  input wire signed [MP_DATA_WIDTH-1 : 0]  isrc_a,
  input wire        [MP_DATA_WIDTH-1 : 0]  isrc_b,

  output wire                              ozero,
  output wire                              ooverflow,
  output wire                              ocarry,
  output wire                              onegative,
  output reg        [MP_DATA_WIDTH-1 : 0]  oresult
);
//------------------------------------------------------------------------------

  localparam LP_LSB = MP_DATA_WIDTH-1;

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
  assign ozero     = (oresult == {32{1'b0}});
  assign onegative = oresult[LP_LSB];
  assign ocarry    = ~ictrl[1] & wcarry_out;
  assign ooverflow = ~ictrl[1] & waux1 & waux2;

  always @(*) begin : cproc_alu
    case (ictrl)
      `ADD_OP : oresult = wsum;
      `SUB_OP : oresult = wsum;
      `AND_OP : oresult = isrc_a & isrc_b;
      `OR_OP  : oresult = isrc_a | isrc_b;
      `SLT_OP : oresult = {{MP_DATA_WIDTH-1{1'b0}}, ooverflow ^ wsum[LP_LSB]};
      `SLTU_OP: oresult = {{MP_DATA_WIDTH-1{1'b0}}, ~ocarry};
      `XOR_OP : oresult = isrc_a ^ isrc_b;
      `SL_OP  : oresult = isrc_a << isrc_b[4:0];
      `SR_OP  : oresult = isrc_a >> isrc_b[4:0];
      `SRA_OP : oresult = isrc_a >>> isrc_b[4:0];
      default:  oresult = oresult;
    endcase
   end

endmodule : alu
