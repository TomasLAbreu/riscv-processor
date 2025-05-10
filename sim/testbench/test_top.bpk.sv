module test_top;

`include "riscv_constants.vh"

reg rrefclk;
reg rrst_n;

always #5 rrefclk = ~rrefclk;

initial begin
  rrefclk <= 1'b0;
  rrst_n <= 1'b0;
  #(22);
  rrst_n <= 1'b1;
end

riscv_io riscv_if(rrefclk);

top #(
 .MP_DATA_WIDTH (`RISCV_DATA_WIDTH),
 .MP_ADDR_WIDTH (`RISCV_ADDR_WIDTH)
) inst_top (
 .iclk          (rrefclk),
 .irst_n        (rrst_n),
 .oinstr        (riscv_if.instr),
 .opc           (riscv_if.pc),
 .odmem_addr    (riscv_if.dmem_addr),
 .odmem_wr_en   (riscv_if.dmem_wr_en),
 .odmem_wr_data (riscv_if.dmem_wr_data),
 .odmem_rd_data (riscv_if.dmem_rd_data)
);

integer count = 0;
wire  [31:0]  pc;
wire  [31:0]  instr;
wire          dmem_wr_en;
wire  [31:0]  dmem_addr;
wire  [`RISCV_DATA_WIDTH-1:0] dmem_wr_data;
wire  [`RISCV_DATA_WIDTH-1:0] dmem_rd_data;

assign instr = riscv_if.instr;
assign pc = riscv_if.pc;
assign dmem_addr = riscv_if.dmem_addr;
assign dmem_wr_en = riscv_if.dmem_wr_en;
assign dmem_wr_data = riscv_if.dmem_wr_data;
assign dmem_rd_data = riscv_if.dmem_rd_data;

always @(negedge rrefclk) begin
  if (dmem_wr_en) begin
    if ((dmem_addr == 100) & (dmem_wr_data == 25)) begin
      `printOK("lw", count)
      `printOK("addi", count)
      `printOK("sw", count)
      `printOK("add", count)
      `printOK("sub", count)
      `printOK("or", count)
      `printOK("and", count)
      `printOK("jal", count)
    end

    else if ((dmem_addr == 104) & (dmem_wr_data == 4096))   `printOK("lui",count)
    else if ((dmem_addr == 108) & (dmem_wr_data == 4184))   `printOK("auipc",count)
    else if ((dmem_addr == 112) & (dmem_wr_data == 104))  `printOK("jalr",count)
    else if ((dmem_addr == 116) & (dmem_wr_data == 1))    `printOK("slt",count)
    else if ((dmem_addr == 120) & (dmem_wr_data == 0))    `printOK("sltu",count)

    // branch type
    else if ((dmem_addr == 124) & (dmem_wr_data == 9))    `printOK("beq",count)
    else if ((dmem_addr == 128) & (dmem_wr_data == 9))    `printOK("bne",count)
    else if ((dmem_addr == 132) & (dmem_wr_data == -1))     `printOK("blt",count)
    else if ((dmem_addr == 136) & (dmem_wr_data == 1))    `printOK("bge",count)
    else if ((dmem_addr == 140) & (dmem_wr_data == 1))    `printOK("bltu",count)
    else if ((dmem_addr == 144) & (dmem_wr_data == -1))     `printOK("bgeu",count)
    else if ((dmem_addr == 144) & (dmem_wr_data == -1))     `printOK("blt",count)

    else if ((dmem_addr == 148) & (dmem_wr_data == 254))  `printOK("xor",count)
    else if ((dmem_addr == 152) & (dmem_wr_data == 190))  `printOK("xori",count)
    else if ((dmem_addr == 156) & (dmem_wr_data == 250))  `printOK("ori",count)
    else if ((dmem_addr == 160) & (dmem_wr_data == 8))    `printOK("andi",count)

    else if ((dmem_addr == 164) & (dmem_wr_data == 0))    `printOK("slti",count)
    else if ((dmem_addr == 172) & (dmem_wr_data == 1))    `printOK("sltiu",count)

    else if ((dmem_addr == 100) & (dmem_wr_data == -154))     `printOK("slli",count)
    else if ((dmem_addr == 104) & (dmem_wr_data == 2147483609))   `printOK("srli",count)
    else if ((dmem_addr == 108) & (dmem_wr_data == -39))    `printOK("srai",count)
    else if ((dmem_addr == 112) & (dmem_wr_data == -154))     `printOK("sll",count)
    else if ((dmem_addr == 116) & (dmem_wr_data == 2147483609))   `printOK("srl",count)
    else if ((dmem_addr == 120) & (dmem_wr_data == -39))    `printOK("sra",count)

    else if ((dmem_addr == 160) & (dmem_wr_data == -35))  `printOK("lb 96",count)
    else if ((dmem_addr == 164) & (dmem_wr_data == -64))  `printOK_NC("lb 97",count)
    else if ((dmem_addr == 168) & (dmem_wr_data == 11))       `printOK_NC("lb 98",count)
    else if ((dmem_addr == 172) & (dmem_wr_data == -86))  `printOK_NC("lb 99",count)

    else if ((dmem_addr == 176) & (dmem_wr_data == -16163))   `printOK("lh 96",count)
    else if ((dmem_addr == 180) & (dmem_wr_data == 3008))   `printOK_NC("lh 97",count)
    else if ((dmem_addr == 184) & (dmem_wr_data == -22005))   `printOK_NC("lh 98",count)
    else if ((dmem_addr == 188) & (dmem_wr_data == -8790))  `printOK_NC("lh 99",count)

    else if ((dmem_addr == 100) & (dmem_wr_data == 221))  `printOK("lbu 96",count)
    else if ((dmem_addr == 104) & (dmem_wr_data == 192))  `printOK_NC("lbu 97",count)
    else if ((dmem_addr == 108) & (dmem_wr_data == 11))       `printOK_NC("lbu 98",count)
    else if ((dmem_addr == 112) & (dmem_wr_data == 170))  `printOK_NC("lbu 99",count)

    else if ((dmem_addr == 116) & (dmem_wr_data == 49373))  `printOK("lhu 96",count)
    else if ((dmem_addr == 120) & (dmem_wr_data == 3008))   `printOK_NC("lhu 97",count)
    else if ((dmem_addr == 124) & (dmem_wr_data == 43531))  `printOK_NC("lhu 98",count)
    else if ((dmem_addr == 128) & (dmem_wr_data == 56746))  `printOK_NC("lhu 99",count)

    else if ((dmem_addr == 100) & (dmem_wr_data == 1997258973))   `printOK("sb 99",count)
    else if ((dmem_addr == 104) & (dmem_wr_data == 1997652189))   `printOK_NC("sb 98",count)
    else if ((dmem_addr == 108) & (dmem_wr_data == 1997611741))   `printOK_NC("sb 97",count)
    else if ((dmem_addr == 112) & (dmem_wr_data == 1997611571))   `printOK_NC("sb 96",count)

    else if ((dmem_addr == 116) & (dmem_wr_data == -1156857686)) `printOK("sh 99",count)
    else if ((dmem_addr == 120) & (dmem_wr_data == -857882454))   `printOK_NC("sh 98",count)
    else if ((dmem_addr == 124) & (dmem_wr_data == -869055318))   `printOK_NC("sh 97",count)
    else if ((dmem_addr == 128) & (dmem_wr_data == -869051034))   `printOK_NC("sh 96",count)

    // --------------------------------------------------------
    else if ((dmem_addr == 40) && (dmem_wr_data == 30)) begin
      $display("\nSimulation completed");
      $display("  %2d/37 instructions PASSED\n", count);
      $finish;
    end

    else if (dmem_addr != 96 && dmem_addr != 97 && dmem_addr != 98 && dmem_addr != 99) begin
      $display("\nSimulation failed");
      $display("  dataAddr  = %d", dmem_addr);
      $display("  dmem_wr_data = %d\n", dmem_wr_data);
      $finish;
    end
  end
end

endmodule
