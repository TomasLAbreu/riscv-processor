module top (
	clk,
	reset,

	PCF,
	InstrF,
	MemWriteM,
	DataAdrM,
	WriteDataM,
	ReadDataM
);
	input wire clk;
	input wire reset;
	
	output [31:0] PCF; 
	output wire [31:0] InstrF;

	output wire MemWriteM;
	output wire [31:0] DataAdrM;
	output wire [31:0] WriteDataM;
	output wire [31:0] ReadDataM;

	wire [1:0] InstrM;

	riscvpipeline rvpipeline(
		clk,
		reset,

		PCF,
		InstrF,
		InstrM,
		MemWriteM,
		DataAdrM, // ALUresult signal
		WriteDataM,
		ReadDataM
	);
	
	imem imem(
		.a(PCF),
		.rd(InstrF)
	);
	
	dmem dmem(
		.clk(clk),
		.we(MemWriteM),
		.a(DataAdrM),
		.wd(WriteDataM),
		.be(InstrM),
		.rd(ReadDataM)
	);
endmodule
