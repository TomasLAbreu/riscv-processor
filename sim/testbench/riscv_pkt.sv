//------------------------------------------------------------------------------
class riscv_pkt extends uvm_sequence_item;
//------------------------------------------------------------------------------
  rand bit [31:0]                  instr;
  bit [31:0]                       pc;
  // bit [`RISCV_ADDR_WIDTH-1:0]      dmem_addr;
  bit [31:0]                       dmem_addr;
  bit [1:0]                        dmem_wr_be;
  bit                              dmem_wr_en;
  bit [`RISCV_DATA_WIDTH-1:0]      dmem_wr_data;
  rand bit [`RISCV_DATA_WIDTH-1:0] dmem_rd_data;

  `uvm_object_utils_begin(riscv_pkt)
    `uvm_field_int(instr, UVM_DEFAULT);
    `uvm_field_int(pc, UVM_DEFAULT);
    `uvm_field_int(dmem_addr, UVM_DEFAULT);
    `uvm_field_int(dmem_wr_be, UVM_DEFAULT);
    `uvm_field_int(dmem_wr_en, UVM_DEFAULT);
    `uvm_field_int(dmem_wr_data, UVM_DEFAULT);
    `uvm_field_int(dmem_rd_data, UVM_DEFAULT);
  `uvm_object_utils_end

  function new(string name = "riscv_pkt");
    super.new(name);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);
  endfunction : new

  virtual function void display(string tag = "INFO");
    // TODO: create msg
    $display({tag, ": hello"});
    // return $sformatf("addr=0x%0h wr=0x%0h wdata=0x%0h rdata=0x%0h", addr, wr, wdata, rdata);
  endfunction : display

  virtual function void copy(riscv_pkt t);
    // TODO: create copy
    // return t;
  endfunction : copy

  virtual function bit compare(riscv_pkt cmp);
    // TODO: compare this against cmp
    return 1;
  endfunction : compare

endclass : riscv_pkt
