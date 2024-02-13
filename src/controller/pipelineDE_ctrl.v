module pipelineDE_ctrl(
	input clk,
	input reset,

	input [6:0] opD,
	input [2:0] funct3D,
	input RegWriteD,
	input [2:0] ResultSrcD,
	input MemWriteD,
	input [3:0] ALUControlD,
	input ALUSrcD,
	input PCResultSrcD,

	output [6:0] opE,
	output [2:0] funct3E,
	output RegWriteE,
	output [2:0] ResultSrcE,
	output MemWriteE,
	output [3:0] ALUControlE,
	output ALUSrcE,
	output PCResultSrcE
);

flopr #(7) opreg(
	clk,
	reset,
	opD,
	opE
);

flopr #(3) funct3reg(
	clk,
	reset,
	funct3D,
	funct3E
);

flopr #(1) regwritereg(
	clk,
	reset,
	RegWriteD,
	RegWriteE
);

flopr #(3) resultsrcreg(
	clk,
	reset,
	ResultSrcD,
	ResultSrcE
);

flopr #(1) memwritereg(
	clk,
	reset,
	MemWriteD,
	MemWriteE
);

flopr #(4) alucontrolreg(
	clk,
	reset,
	ALUControlD,
	ALUControlE
);

flopr #(1) alusrcreg(
	clk,
	reset,
	ALUSrcD,
	ALUSrcE
);

flopr #(1) pcresultreg(
	clk,
	reset,
	PCResultSrcD,
	PCResultSrcE
);

endmodule
