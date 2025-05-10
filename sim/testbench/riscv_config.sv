//------------------------------------------------------------------------------
class riscv_config extends uvm_object;
//------------------------------------------------------------------------------
  int coverage_enabled;

  `uvm_field_utils_begin(riscv_config)
    `uvm_field_int(coverage_enabled, UVM_DEFAULT);
  `uvm_field_utils_end

  function new(string name = "riscv_config");
    super.new(name);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);
  endfunction : new

endclass : riscv_config
