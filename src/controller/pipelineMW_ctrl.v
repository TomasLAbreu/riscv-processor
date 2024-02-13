module pipelineMW_ctrl(
	input clk,
	input reset,

	input RegWriteM,
	input [2:0] ResultSrcM,

	output RegWriteW,
	output [2:0] ResultSrcW
);

flopr #(1) regwritereg(
	clk,
	reset,
	RegWriteM,
	RegWriteW
);

flopr #(3) resultsrcreg(
	clk,
	reset,
	ResultSrcM,
	ResultSrcW
);

endmodule
