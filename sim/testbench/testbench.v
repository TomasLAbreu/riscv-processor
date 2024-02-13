
`define printOK(INSTR, COUNT) begin \
$display("%10s OK", INSTR); \
COUNT = COUNT + 1; \
end \

`define printOK_NC(INSTR, COUNT) begin \
$display("%10s OK", INSTR); \
COUNT = COUNT; \
end \

// ===========================================================================
module testbench;

reg clk;
reg reset;

wire [31:0] PCF; 
wire [31:0] InstrF;
wire MemWriteM;
wire [31:0] DataAdr;
wire [31:0] WriteData;
wire [31:0] ReadData;

top dut(
		clk,
	reset,

	PCF,
	InstrF,
	MemWrite,
	DataAdr,
	WriteData,
	ReadData
);

initial begin
	reset <= 1;
	#(22)
		;
	reset <= 0;
end

always begin
	clk <= 1;
	#(5)
		;
	clk <= 0;
	#(5)
		;
end

integer count = 0;

always @(negedge clk) begin
	if (MemWrite) begin
		if ((DataAdr == 100) & (WriteData == 25)) begin
			`printOK("lw", count)
			`printOK("addi", count)
			`printOK("sw", count)
			`printOK("add", count)
			`printOK("sub", count)
			`printOK("or", count)
			`printOK("and", count)
			`printOK("jal", count)
		end

		else if ((DataAdr == 104) & (WriteData == 4096)) 	`printOK("lui",count)
		else if ((DataAdr == 108) & (WriteData == 4184)) 	`printOK("auipc",count)
		else if ((DataAdr == 112) & (WriteData == 104)) 	`printOK("jalr",count)
		else if ((DataAdr == 116) & (WriteData == 1)) 		`printOK("slt",count)
		else if ((DataAdr == 120) & (WriteData == 0)) 		`printOK("sltu",count)

		// branch type
		else if ((DataAdr == 124) & (WriteData == 9)) 		`printOK("beq",count)
		else if ((DataAdr == 128) & (WriteData == 9)) 		`printOK("bne",count)
		else if ((DataAdr == 132) & (WriteData == -1)) 		`printOK("blt",count)
		else if ((DataAdr == 136) & (WriteData == 1)) 		`printOK("bge",count)
		else if ((DataAdr == 140) & (WriteData == 1)) 		`printOK("bltu",count)
		else if ((DataAdr == 144) & (WriteData == -1)) 		`printOK("bgeu",count)
		else if ((DataAdr == 144) & (WriteData == -1)) 		`printOK("blt",count)
		
		else if ((DataAdr == 148) & (WriteData == 254)) 	`printOK("xor",count)
		else if ((DataAdr == 152) & (WriteData == 190)) 	`printOK("xori",count)
		else if ((DataAdr == 156) & (WriteData == 250)) 	`printOK("ori",count)
		else if ((DataAdr == 160) & (WriteData == 8)) 		`printOK("andi",count)

		else if ((DataAdr == 164) & (WriteData == 0)) 		`printOK("slti",count)
		else if ((DataAdr == 172) & (WriteData == 1)) 		`printOK("sltiu",count)
		
		else if ((DataAdr == 100) & (WriteData == -154)) 		`printOK("slli",count)
		else if ((DataAdr == 104) & (WriteData == 2147483609)) 	`printOK("srli",count)
		else if ((DataAdr == 108) & (WriteData == -39)) 		`printOK("srai",count)
		else if ((DataAdr == 112) & (WriteData == -154)) 		`printOK("sll",count)
		else if ((DataAdr == 116) & (WriteData == 2147483609)) 	`printOK("srl",count)
		else if ((DataAdr == 120) & (WriteData == -39)) 		`printOK("sra",count)

	 	else if ((DataAdr == 160) & (WriteData == -35)) 	`printOK("lb 96",count)
	 	else if ((DataAdr == 164) & (WriteData == -64)) 	`printOK_NC("lb 97",count)
	 	else if ((DataAdr == 168) & (WriteData == 11)) 	    `printOK_NC("lb 98",count)
	 	else if ((DataAdr == 172) & (WriteData == -86)) 	`printOK_NC("lb 99",count)

    	else if ((DataAdr == 176) & (WriteData == -16163)) 	`printOK("lh 96",count)
	 	else if ((DataAdr == 180) & (WriteData == 3008)) 	`printOK_NC("lh 97",count)
	 	else if ((DataAdr == 184) & (WriteData == -22005)) 	`printOK_NC("lh 98",count)
	 	else if ((DataAdr == 188) & (WriteData == -8790)) 	`printOK_NC("lh 99",count)
	 	
	 	else if ((DataAdr == 100) & (WriteData == 221)) 	`printOK("lbu 96",count)
	 	else if ((DataAdr == 104) & (WriteData == 192)) 	`printOK_NC("lbu 97",count)
	 	else if ((DataAdr == 108) & (WriteData == 11)) 	    `printOK_NC("lbu 98",count)
	 	else if ((DataAdr == 112) & (WriteData == 170)) 	`printOK_NC("lbu 99",count)

    	else if ((DataAdr == 116) & (WriteData == 49373)) 	`printOK("lhu 96",count)
	 	else if ((DataAdr == 120) & (WriteData == 3008)) 	`printOK_NC("lhu 97",count)
	 	else if ((DataAdr == 124) & (WriteData == 43531)) 	`printOK_NC("lhu 98",count)
	 	else if ((DataAdr == 128) & (WriteData == 56746)) 	`printOK_NC("lhu 99",count)
		
		else if ((DataAdr == 100) & (WriteData == 1997258973)) 	`printOK("sb 99",count)
	 	else if ((DataAdr == 104) & (WriteData == 1997652189)) 	`printOK_NC("sb 98",count)
	 	else if ((DataAdr == 108) & (WriteData == 1997611741)) 	`printOK_NC("sb 97",count)
	 	else if ((DataAdr == 112) & (WriteData == 1997611571)) 	`printOK_NC("sb 96",count)
	 	
		else if ((DataAdr == 116) & (WriteData == -1156857686)) `printOK("sh 99",count)
	 	else if ((DataAdr == 120) & (WriteData == -857882454)) 	`printOK_NC("sh 98",count)
	 	else if ((DataAdr == 124) & (WriteData == -869055318)) 	`printOK_NC("sh 97",count)
	 	else if ((DataAdr == 128) & (WriteData == -869051034)) 	`printOK_NC("sh 96",count)

		// --------------------------------------------------------
		else if ((DataAdr == 40) && (WriteData == 30)) begin
        	$display("\nSimulation completed");
        	$display("  %2d/37 instructions PASSED\n", count);
			$stop;
        end
        
		else if (DataAdr != 96 && DataAdr != 97 && DataAdr != 98 && DataAdr != 99) begin
			$display("\nSimulation failed");
			$display("  dataAddr  = %d", DataAdr);
			$display("  writeData = %d\n", WriteData); 
			$stop;
		end
	end
end


endmodule
// ===========================================================================