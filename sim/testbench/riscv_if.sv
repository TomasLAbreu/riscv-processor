//------------------------------------------------------------------------------
interface riscv_if(input clk);
//------------------------------------------------------------------------------
  logic                         rst_n;
  logic [31:0]                  instr;
  logic [31:0]                  pc;
  // logic [`RISCV_ADDR_WIDTH-1:0] dmem_addr;
  logic [31:0]                  dmem_addr;
  logic [1:0]                   dmem_wr_be;
  logic                         dmem_wr_en;
  logic [`RISCV_DATA_WIDTH-1:0] dmem_wr_data;
  logic [`RISCV_DATA_WIDTH-1:0] dmem_rd_data;

  clocking cb @(posedge clk);
    default input #1ns output #1ns;
    output instr;
    input pc;
    input dmem_addr;
    input dmem_wr_be;
    input dmem_wr_en;
    input dmem_wr_data;
    output dmem_rd_data;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1ns output #1ns;
    input instr;
    input pc;
    input dmem_addr;
    input dmem_wr_be;
    input dmem_wr_en;
    input dmem_wr_data;
    input dmem_rd_data;
  endclocking

endinterface : riscv_if