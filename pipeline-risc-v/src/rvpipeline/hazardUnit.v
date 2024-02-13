//------------------------------------------------------------------------------
module hazard_unit
//------------------------------------------------------------------------------
(
	input wire	[4:0]	irs1_decod,
	input wire	[4:0]	irs2_decod,

	input wire	[4:0]	irs1_exect,
	input wire	[4:0]	irs2_exect,
	input wire	[4:0]	ird_exect,
	input wire				ipc_src_exect,
	input wire				iresult_src_b0_exect,

	input wire	[4:0]	ird_mem,
	input wire	[4:0]	ird_wrt,
	input wire				ireg_wr_mem,
	input wire				ireg_wr_wrt,

	output reg	[1:0]	oforward_ae,
	output reg	[1:0]	oforward_be,

	output wire				ostall_fetch,
	output wire				ostall_decod,
	output wire				oflush_decod,
	output wire				oflush_exect
);
//------------------------------------------------------------------------------

	wire wstall_lw;

	// ---------------
	// control hazards

	// branch control hazard
	assign oflush_decod = ipc_src_exect;
	assign oflush_exect = wstall_lw | ipc_src_exect;

	// ---------------
	// data hazards

	// load word stalls
	assign wstall_lw = iresult_src_b0_exect & ((irs1_decod == ird_exect) | (irs2_decod == ird_exect));
	assign ostall_fetch = wstall_lw;
	assign ostall_decod = wstall_lw;

	always @(*) begin : cproc_forward_ae
		if (((irs1_exect == ird_mem) & ireg_wr_mem) & (irs1_exect != 0)) begin
			oforward_ae = 2'b10;
		end else begin
			if (((irs1_exect == ird_wrt) & ireg_wr_wrt) & (irs1_exect != 0)) begin
				oforward_ae = 2'b01;
			end else begin
				oforward_ae = 2'b00;
			end
		end
	end

	always @(*) begin : cproc_forward_be
		if (((irs2_exect == ird_mem) & ireg_wr_mem) & (irs2_exect != 0)) begin
			oforward_be = 2'b10;
		end else begin
			if (((irs2_exect == ird_wrt) & ireg_wr_wrt) & (irs2_exect != 0)) begin
				oforward_be = 2'b01;
			end else begin
				oforward_be = 2'b00;
			end
		end
	end

endmodule : hazard_unit
