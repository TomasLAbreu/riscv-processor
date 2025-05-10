`include "riscv_constants.vh"
`include "riscv_if.sv"
`include "uvm_pkg.sv"

module test_top;
	reg rrefclk;

	import uvm_pkg::*;

	`include "riscv_pkt.sv"
	`include "riscv_refmodel.sv"
	`include "riscv_driver.sv"
	`include "riscv_monitor.sv"
	`include "riscv_agent.sv"
	`include "riscv_config.sv"
	`include "riscv_coverage.sv"
	`include "riscv_scoreboard.sv"
	`include "riscv_env.sv"

	riscv_if dut_if(rrefclk);

	always #5 rrefclk = ~rrefclk;

	initial begin
		rrefclk = 1'b0;
		$timeformat(-9, 1, "ns", 10);
		// $fsdbDumpvars;
	end

	initial begin
		$display("\n------------------------------");
		$display(" Starting simulation...");
		$display("------------------------------\n");
		uvm_config_db #(virtual riscv_if)::set(null, "uvm_test_top.env.riscv_agt.*", "vif", dut_if);
		run_test();
	end

	final begin
		$display("\n------------------------------");
		$display(" Ending simulation...");
		$display("------------------------------\n");
	end

	riscv #(
		.MP_DATA_WIDTH (`RISCV_DATA_WIDTH),
		.MP_ADDR_WIDTH (`RISCV_ADDR_WIDTH)
	) dut (
		.iclk          (rrefclk),
		.irst_n        (dut_if.rst_n),
		.iinstr        (dut_if.instr),
		.opc           (dut_if.pc),
		.odmem_addr    (dut_if.dmem_addr),
		.odmem_wr_be   (dut_if.dmem_wr_be),
		.odmem_wr_en   (dut_if.dmem_wr_en),
		.odmem_wr_data (dut_if.dmem_wr_data),
		.idmem_rd_data (dut_if.dmem_rd_data)
	);

endmodule
