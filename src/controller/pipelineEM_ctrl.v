module pipelineEM_ctrl(
	input clk,
	input reset,

	input RegWriteE,
	input [2:0] ResultSrcE,
	input MemWriteE,

	output RegWriteM,
	output [2:0] ResultSrcM,
	output MemWriteM
);

flopr #(1) regwritereg(
	clk,
	reset,
	RegWriteE,
	RegWriteM
);

flopr #(3) resultsrcreg(
	clk,
	reset,
	ResultSrcE,
	ResultSrcM
);

flopr #(1) memwritereg(
	clk,
	reset,
	MemWriteE,
	MemWriteM
);

endmodule
