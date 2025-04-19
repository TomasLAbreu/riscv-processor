module riscv_dp_extend_imm (
  input wire  [31:7]  iinstr,
  input wire  [2:0]   isrc,
  output reg  [31:0]  oext
);

  localparam [2:0]
    LP_I_TYPE = 3'b000,
    LP_S_TYPE = 3'b001,
    LP_B_TYPE = 3'b010,
    LP_J_TYPE = 3'b011,
    LP_U_TYPE = 3'b100;

  always @(*) begin
    case (isrc)
      LP_I_TYPE: oext = {{20{iinstr[31]}}, iinstr[31:20]};
      LP_S_TYPE: oext = {{20{iinstr[31]}}, iinstr[31:25], iinstr[11:7]};
      LP_B_TYPE: oext = {{20{iinstr[31]}}, iinstr[7], iinstr[30:25], iinstr[11:8], 1'b0};
      LP_J_TYPE: oext = {{12{iinstr[31]}}, iinstr[19:12], iinstr[20], iinstr[30:21], 1'b0};
      LP_U_TYPE: oext = {iinstr[31:12], {12 {1'b0}}};
      default: oext = {32{1'bx}};
    endcase
  end

endmodule
