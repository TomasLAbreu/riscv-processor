module pipelineDE_dp(
	input clk,
	input reset,
	input FlushE,

	// inputs
	input wire [2:0] InstrD,
	input wire [31:0] RD1D,
	input wire [31:0] RD2D,
	input wire [31:0] PCD,
	input wire [4:0] Rs1D,
	input wire [4:0] Rs2D,
	input wire [4:0] RdD,
	input wire [31:0] ImmExtD,
	input wire [31:0] PCPlus4D,

	// outputs
	output wire [2:0] InstrE,
	output wire [31:0] RD1E,
	output wire [31:0] RD2E,
	output wire [31:0] PCE,
	output wire [4:0] Rs1E,
	output wire [4:0] Rs2E,
	output wire [4:0] RdE,
	output wire [31:0] ImmExtE,
	output wire [31:0] PCPlus4E
);

wire clear = reset | FlushE;

flopr #(3) instrreg(
	clk,
	reset,
	InstrD,
	InstrE
);

flopr #(32) rd1reg(
	clk,
	clear,
	RD1D,
	RD1E
);

flopr #(32) rd2reg(
	clk,
	clear,
	RD2D,
	RD2E
);

flopr #(32) pcreg(
	clk,
	clear,
	PCD,
	PCE
);

flopr #(5) rs1reg(
	clk,
	clear,
	Rs1D,
	Rs1E
);

flopr #(5) rs2reg(
	clk,
	clear,
	Rs2D,
	Rs2E
);

flopr #(5) rdreg(
	clk,
	clear,
	RdD,
	RdE
);

flopr #(32) immextreg(
	clk,
	clear,
	ImmExtD,
	ImmExtE
);

flopr #(32) pcplusreg(
	clk,
	clear,
	PCPlus4D,
	PCPlus4E
);

endmodule
