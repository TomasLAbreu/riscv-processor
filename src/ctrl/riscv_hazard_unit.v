//------------------------------------------------------------------------------
module riscv_hazard_unit
//------------------------------------------------------------------------------
#(
	parameter MP_REGFILE_ADDR_WIDTH = 5
)
(
	input wire															ipc_src,
	input wire															ilw_ongoing, // high if load word in the execute stage

	// Regfile wires
	input wire	[MP_REGFILE_ADDR_WIDTH-1:0]	irs1,
	input wire	[MP_REGFILE_ADDR_WIDTH-1:0]	irs1_1d,
	input wire	[MP_REGFILE_ADDR_WIDTH-1:0]	irs2,
	input wire	[MP_REGFILE_ADDR_WIDTH-1:0]	irs2_1d,
	input wire															ird_wr_en_1d,
	input wire															ird_wr_en_2d,
	input wire	[MP_REGFILE_ADDR_WIDTH-1:0]	ird_1d,
	input wire	[MP_REGFILE_ADDR_WIDTH-1:0]	ird_2d,
	input wire	[MP_REGFILE_ADDR_WIDTH-1:0]	ird_3d,

	output reg	[1:0]												oforward_alu_src_a,
	output reg	[1:0]												oforward_alu_src_b,
	output wire															ostall_f,
	output wire															ostall_d,
	output wire															oflush_d,
	output wire															oflush_e
);
//------------------------------------------------------------------------------

	wire wstall_lw;

	// load word stalls
	assign wstall_lw = ilw_ongoing && ((irs1 == ird_1d) || (irs2 == ird_1d));

	// ---------------
	// control hazards

	// branch control hazard
	assign oflush_d = ipc_src;
	assign oflush_e = wstall_lw || ipc_src;

	// ---------------
	// data hazards

	assign ostall_f = wstall_lw;
	assign ostall_d = wstall_lw;

	// `define CHECK(_rs_, _rd_, _wr_en_) ((_rs_ == _rd_) & (_rs_ != 0) & _wr_en_)
	// assign oforward_alu_src_a[1] = `CHECK(irs1_1d, ird_2d, ird_wr_en_1d);
	// assign oforward_alu_src_a[0] = `CHECK(irs1_1d, ird_3d, ird_wr_en_2d);
	// assign oforward_alu_src_b[1] = `CHECK(irs_ex, ird_2d, ird_wr_en_1d);
	// assign oforward_alu_src_b[0] = `CHECK(irs_ex, ird_3d, ird_wr_en_2d);

	always @(*) begin : cproc_forward_alu_src_a
		if (((irs1_1d == ird_2d) && ird_wr_en_1d) && (irs1_1d != 0)) begin
			// Forward from memory stage
			oforward_alu_src_a = 2'b10;
		end else begin
			if (((irs1_1d == ird_3d) && ird_wr_en_2d) && (irs1_1d != 0)) begin
				// Forward from writeback stage
				oforward_alu_src_a = 2'b01;
			end else begin
				// No forwarding
				oforward_alu_src_a = 2'b00;
			end
		end
	end

	always @(*) begin : cproc_forward_alu_src_b
		if (((irs2_1d == ird_2d) && ird_wr_en_1d) && (irs2_1d != 0)) begin
			// Forward from memory stage
			oforward_alu_src_b = 2'b10;
		end else begin
			if (((irs2_1d == ird_3d) && ird_wr_en_2d) && (irs2_1d != 0)) begin
				// Forward from writeback stage
				oforward_alu_src_b = 2'b01;
			end else begin
				// No forwarding
				oforward_alu_src_b = 2'b00;
			end
		end
	end

endmodule : riscv_hazard_unit
