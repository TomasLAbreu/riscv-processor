//------------------------------------------------------------------------------
class riscv_test extends uvm_test;
//------------------------------------------------------------------------------
  `uvm_component_utils(riscv_test)
  riscv_env env;

  function new(string name = "riscv_test", uvm_component parent);
    super.new(name, parent);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    riscv_config cfg = new("cfg");

    super.build_phase(phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);

    uvm_config_db#(riscv_config)::set(this, "env", "cfg", cfg);
    `uvm_info("CONFIG", {"\n", cfg.sprint()}, UVM_LOW);

    env = riscv_env::type_id::create("env", this);
  endfunction : build_phase

  virtual task main_phase(uvm_phase phase);
    super.main_phase(phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);

    // TODO: start sqr....
  endtask : main_phase

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);
    `uvm_info("SB_REPORT", env.sb.convert2string(), UVM_LOW);
  endfunction : report_phase

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);

    if (uvm_report_enabled(UVM_DEBUG, UVM_INFO, "TOPOLOGY")) begin
      uvm_root::get().print_topology();
    end

    if (uvm_report_enabled(UVM_DEBUG; UVM_INFO, "FACTORY")) begin
      uvm_factory::get().print();
    end
  endfunction : final_phase

endclass : riscv_test
