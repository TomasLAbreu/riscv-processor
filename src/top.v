module top #(
	parameter MP_DATA_WIDTH = 32,
	parameter MP_ADDR_WIDTH = 5
)
(
	input wire												iclk,
	input wire												irst,

	output wire	[31:0]								opcf,
	output wire	[31:0]								oinstr_f,
	output wire												omem_wr_m,
	output wire	[31:0]								odata_addr_m,
	output wire	[MP_DATA_WIDTH-1 : 0]	owdata_m,
	output wire	[MP_DATA_WIDTH-1 : 0]	ordata_m
);

	wire [1:0] winstr_m;

	riscv_pipeline #(
		.MP_DATA_WIDTH (MP_DATA_WIDTH),
		.MP_ADDR_WIDTH (MP_ADDR_WIDTH)
	) inst_riscvpipeline (
		.iclk          (iclk),
		.irst          (irst),
		.opcf          (opcf),
		.iinstr_f      (oinstr_f),
		.oinstr_m      (winstr_m),
		.omem_write_m  (omem_wr_m),
		.oalu_result_m (odata_addr_m),
		.owdata_m      (owdata_m),
		.irdata_m      (ordata_m)
	);
//OK
	instr_mem #(
		.MP_WIDTH (MP_DATA_WIDTH),
		.MP_DEPTH (256)
	) u_imem (
		.ipos   (opcf),
		.ordata (oinstr_f)
	);
//OK
	data_mem #(
		.MP_WIDTH (MP_DATA_WIDTH),
		.MP_DEPTH (256)
	) u_dmem (
		.iclk   (iclk),
		.ipos   (odata_addr_m),
		.iwen   (omem_wr_m),
		.ibe    (winstr_m),
		.iwdata (owdata_m),
		.ordata (ordata_m)
	);

endmodule
