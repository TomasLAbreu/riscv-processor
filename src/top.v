module top #(
	parameter MP_DATA_WIDTH = 32,
	parameter MP_ADDR_WIDTH = 5
)
(
	input wire												iclk,
	input wire												irst_n,

	output wire	[31:0]								opc,
	output wire	[31:0]								oinstr,
	output wire												odmem_wr_en,
	output wire	[31:0]								odmem_addr,
	output wire	[MP_DATA_WIDTH-1 : 0]	odmem_wr_data,
	output wire	[MP_DATA_WIDTH-1 : 0]	odmem_rd_data
);

	wire [1:0] wdmem_wr_be;

	riscv #(
		.MP_DATA_WIDTH (MP_DATA_WIDTH),
		.MP_ADDR_WIDTH (MP_ADDR_WIDTH)
	) u_riscvp (
		.iclk          (iclk),
		.irst_n        (irst_n),
		.iinstr        (oinstr),
		.opc           (opc),
		.odmem_addr    (odmem_addr),
		.odmem_wr_be   (wdmem_wr_be),
		.odmem_wr_en   (odmem_wr_en),
		.odmem_wr_data (odmem_wr_data),
		.idmem_rd_data (odmem_rd_data)
	);

	instr_mem #(
		.MP_DATA_WIDTH (MP_DATA_WIDTH),
		.MP_ADDR_WIDTH (8)
	) u_imem (
		.iaddr  (opc),
		.ordata (oinstr)
	);

	// TODO: this should receive data+addr params only...
	data_mem #(
		.MP_DATA_WIDTH (MP_DATA_WIDTH),
		.MP_ADDR_WIDTH (8)
	) u_dmem (
		.iclk   (iclk),
		.iaddr  (odmem_addr[7:0]), // TODO: check this out
		.iwen   (odmem_wr_en),
		.ibe    (wdmem_wr_be),
		.iwdata (odmem_wr_data),
		.ordata (odmem_rd_data)
	);

endmodule
