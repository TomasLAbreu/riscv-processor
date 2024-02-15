module top #(
	parameter MP_DATA_WIDTH = 32
)
(
	input wire					iclk,
	input wire					irst,
	output wire	[31:0]	opcf,
	output wire	[31:0]	oinstr_f,
	output wire					omem_wr_m,
	output wire	[31:0]	odata_addr_m,
	output wire	[31:0]	owdata_m,
	output wire	[31:0]	ordata_m
);

	wire [1:0] winstr_m;

	riscvpipeline rvpipeline(
		iclk,
		irst,

		opcf,
		oinstr_f,
		winstr_m,
		omem_wr_m,
		odata_addr_m,
		owdata_m,
		ordata_m
	);

	instr_mem #(
		.MP_WIDTH (MP_DATA_WIDTH),
		.MP_DEPTH (256)
	) imem (
		.ipos   (opcf),
		.ordata (oinstr_f)
	);

	data_mem #(
		.MP_WIDTH (MP_DATA_WIDTH),
		.MP_DEPTH (256)
	) dmem (
		.iclk   (iclk),
		.ipos   (odata_addr_m),
		.iwen   (omem_wr_m),
		.ibe    (winstr_m),
		.iwdata (owdata_m),
		.ordata (ordata_m)
	);

endmodule
