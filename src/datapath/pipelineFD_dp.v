module pipelineFD_dp(
	input clk,
	input reset,
	input enable,

	// inputs
	input wire [31:0] InstrF,
	input wire [31:0] PCF,
	input wire [31:0] PCPlus4F,

	// outputs
	output wire [31:0] InstrD,
	output wire [31:0] PCD,
	output wire [31:0] PCPlus4D
);

flopenr #(32) instrreg(
	clk,
	reset,
	enable,
	InstrF,
	InstrD
);

flopenr #(32) pcreg(
	clk,
	reset,
	enable,
	PCF,
	PCD
);

flopenr #(32) pcplusreg(
	clk,
	reset,
	enable,
	PCPlus4F,
	PCPlus4D
);

endmodule