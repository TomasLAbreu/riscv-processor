module extendImm (
  input wire  [31:7]  instr,
  input wire  [2:0]   immsrc,
  output reg  [31:0]  immext
);

  localparam [2:0]
    LP_I_TYPE = 3'b000,
    LP_S_TYPE = 3'b001,
    LP_B_TYPE = 3'b010,
    LP_J_TYPE = 3'b011,
    LP_U_TYPE = 3'b100;

  always @(*) begin
    case (immsrc)
      LP_I_TYPE: immext = {{20{instr[31]}}, instr[31:20]};
      LP_S_TYPE: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
      LP_B_TYPE: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
      LP_J_TYPE: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
      LP_U_TYPE: immext = {instr[31:12], {12 {1'b0}}};
      default: immext = {32{1'bx}};
    endcase
  end

endmodule
