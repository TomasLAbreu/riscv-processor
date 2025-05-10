//------------------------------------------------------------------------------
class riscv_env extends uvm_env;
//------------------------------------------------------------------------------
  `uvm_component_utils(riscv_env)

  riscv_agent      riscv_agt;
  riscv_config     cfg;

  riscv_refmodel   refmodel;
  riscv_scoreboard sb;
  // riscv_coverage   fcov;

  function new(string name = "riscv_env", uvm_component parent);
    super.new(name, parent);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);

    if (!uvm_config_db#(riscv_config)::get(this, "", "cfg", cfg)) begin
      `uvm_error(get_type_name(), "Failed to get riscv_cfg");
    end

    riscv_agt = riscv_agent::type_id::create("riscv_agt", this);
    sb        = riscv_scoreboard::type_id::create("sb", this);
    refmodel  = riscv_refmodel::type_id::create("refmodel", this);

    // fcov = riscv_coverage::type_id::create("fcov", this);
  endfunction : build_phase

  virtual function void connect_phase (uvm_phase phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);

    riscv_agt.mon.sink.connect(sb.actual_source);
    refmodel.sink.connect(sb.expected_source);
    // riscv_agt.mon.sink.connect(fcov.source);
    riscv_agt.mon.sink.connect(refmodel.source);
  endfunction : connect_phase

  virtual task reset_phase(uvm_phase phase);
    super.reset_phase(phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);

    refmodel.reset();
  endtask : reset_phase

endclass : riscv_env
