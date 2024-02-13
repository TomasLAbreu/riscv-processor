module pipelineEM_dp(
	input clk,
	input reset,
	
	// inputs
	input wire [2:0] InstrE,
	input wire [31:0] ALUResultE,
	input wire [31:0] WriteDataE,
	input wire [31:0] ImmExtE,
	input wire [4:0] RdE,
	input wire [31:0] PCResultE,
	input wire [31:0] PCPlus4E,

	// outputs
	output wire [2:0] InstrM,
	output wire [31:0] ALUResultM,
	output wire [31:0] WriteDataM,
	output wire [31:0] ImmExtM,
	output wire [4:0] RdM,
	output wire [31:0] PCResultM,
	output wire [31:0] PCPlus4M
);

flopr #(3) instrreg(
	clk,
	reset,
	InstrE,
	InstrM
);

flopr #(32) aluresultreg(
	clk,
	reset,
	ALUResultE,
	ALUResultM
);

flopr #(32) writedatareg(
	clk,
	reset,
	WriteDataE,
	WriteDataM
);

flopr #(32) immextreg(
	clk,
	reset,
	ImmExtE,
	ImmExtM
);

flopr #(5) rdreg(
	clk,
	reset,
	RdE,
	RdM
);

flopr #(32) pcresultreg(
	clk,
	reset,
	PCResultE,
	PCResultM
);

flopr #(32) pcplusreg(
	clk,
	reset,
	PCPlus4E,
	PCPlus4M
);

endmodule
