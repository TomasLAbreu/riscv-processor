module extendImm (
	instr,
	immsrc,
	immext
);
	input wire [31:7] instr;
	input wire [2:0] immsrc;
	output reg [31:0] immext;
	
	always @(*)
		case (immsrc)
			// I type
			3'b000: immext = {{20 {instr[31]}}, instr[31:20]};
			
			// S type
			3'b001: immext = {{20 {instr[31]}}, instr[31:25], instr[11:7]};
			
			// B type
			3'b010: immext = {{20 {instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
			
			// J type
			3'b011: immext = {{12 {instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
			
			// U type
			3'b100: immext = {instr[31:12], {12 {1'b0}}};
			
			default: immext = {32{1'bx}};
		endcase
endmodule
