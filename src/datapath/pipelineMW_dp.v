module pipelineMW_dp(
	input clk,
	input reset,
	
	// inputs
	input [31:0] ALUResultM,
	input [31:0] ReadDataM,
	input [31:0] ImmExtM,
	input [4:0] RdM,
	input [31:0] PCResultM,
	input [31:0] PCPlus4M,

	// outputs
	output [31:0] ALUResultW,
	output [31:0] ReadDataW,
	output [31:0] ImmExtW,
	output [4:0] RdW,
	output [31:0] PCResultW,
	output [31:0] PCPlus4W
);

flopr #(32) aluresultreg(
	clk,
	reset,
	ALUResultM,
	ALUResultW
);

flopr #(32) memdatareg(
	clk,
	reset,
	ReadDataM,
	ReadDataW
);

flopr #(32) immextreg(
	clk,
	reset,
	ImmExtM,
	ImmExtW
);

flopr #(5) rdreg(
	clk,
	reset,
	RdM,
	RdW
);

flopr #(32) pcresultreg(
	clk,
	reset,
	PCResultM,
	PCResultW
);

flopr #(32) pcplusreg(
	clk,
	reset,
	PCPlus4M,
	PCPlus4W
);

endmodule
