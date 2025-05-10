//------------------------------------------------------------------------------
class riscv_agent extends uvm_agent;
//------------------------------------------------------------------------------
  `uvm_component_utils(riscv_agent)

  typedef uvm_sequencer#(riscv_pkt) riscv_pkt_sequencer;

  riscv_pkt_sequencer sqr;
  riscv_driver        drv;
  riscv_monitor       mon;

  function new (string name = "riscv_agent", uvm_component parent=null);
    super.new (name, parent);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);
    `uvm_info("CONFIG", $sformatf("RISCV Agent %s setting for is_active is: %p", this.get_name(), is_active), UVM_FULL);

    if (is_active == UVM_ACTIVE) begin
      sqr = riscv_pkt_sequencer::type_id::create("sqr", this);
      drv = riscv_driver::type_id::create("drv", this);
    end

    mon = riscv_monitor::type_id::create("mon", this);
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);

    if (is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(sqr.seq_item_export);
    end
  endfunction : connect_phase

endclass : riscv_agent
