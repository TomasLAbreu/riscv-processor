//------------------------------------------------------------------------------
module riscv_hazard_unit
//------------------------------------------------------------------------------
// TODO: add parameters for rs* size
// TODO: reorder inputs/outputs
// TODO: rename waux*
(
	input wire	[4:0]	irs1_id,
	input wire	[4:0]	irs2_id,

	input wire	[4:0]	irs1_ex,
	input wire	[4:0]	irs2_ex,

	input wire	[4:0]	ird_ex,
	input wire				ipc_src_ex,
	input wire				iresult_src_ex_b0,

	input wire	[4:0]	ird_mem,
	input wire	[4:0]	ird_wb,
	input wire				ireg_wr_mem,
	input wire				ireg_wr_wb,

	output reg 	[1:0]	oforward_ae,
	output reg	[1:0]	oforward_be,

	output wire				ostall_if,
	output wire				ostall_id,
	output wire				oflush_id,
	output wire				oflush_ex
);
//------------------------------------------------------------------------------

	wire wstall_lw;
	wire waux1;
	wire waux2;

	// ---------------
	// control hazards

	// branch control hazard
	assign oflush_id = ipc_src_ex;
	assign oflush_ex = wstall_lw | ipc_src_ex;

	// ---------------
	// data hazards

	// load word stalls
	assign waux1 = (irs1_id == ird_ex);
	assign waux2 = (irs2_id == ird_ex);
	assign wstall_lw = iresult_src_ex_b0 & (waux1 | waux2);

	assign ostall_if = wstall_lw;
	assign ostall_id = wstall_lw;

	`define CHECK(_rs_, _rd_, _wr_en_) ((_rs_ == _rd_) & (_rs_ != 0) & _wr_en_)

	// assign oforward_ae[1] = `CHECK(irs1_ex, ird_mem, ireg_wr_mem);
	// assign oforward_ae[0] = `CHECK(irs1_ex, ird_wb, ireg_wr_wb);

	// assign oforward_be[1] = `CHECK(irs_ex, ird_mem, ireg_wr_mem);
	// assign oforward_be[0] = `CHECK(irs_ex, ird_wb, ireg_wr_wb);

	always @(*) begin : cproc_forward_ae
		if (((irs1_ex == ird_mem) & ireg_wr_mem) & (irs1_ex != 0)) begin
			oforward_ae = 2'b10;
		end else begin
			if (((irs1_ex == ird_wb) & ireg_wr_wb) & (irs1_ex != 0)) begin
				oforward_ae = 2'b01;
			end else begin
				oforward_ae = 2'b00;
			end
		end
	end

	always @(*) begin : cproc_forward_be
		if (((irs2_ex == ird_mem) & ireg_wr_mem) & (irs2_ex != 0)) begin
			oforward_be = 2'b10;
		end else begin
			if (((irs2_ex == ird_wb) & ireg_wr_wb) & (irs2_ex != 0)) begin
				oforward_be = 2'b01;
			end else begin
				oforward_be = 2'b00;
			end
		end
	end

endmodule : riscv_hazard_unit
