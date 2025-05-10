//------------------------------------------------------------------------------
class riscv_refmodel extends uvm_component;
//------------------------------------------------------------------------------
  `uvm_component_utils(riscv_refmodel)

  uvm_analysis_imp #(riscv_pkt, riscv_refmodel) source;
  uvm_analysis_port #(riscv_pkt) sink;

  function new(string name = "riscv_refmodel", uvm_component parent);
    super.new(name, parent);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);

    source = new("source", this);
    sink = new("sink", this);
  endfunction : new

  virtual function void reset();
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);
  endfunction : reset

  virtual function void write(riscv_pkt t);
    riscv_pkt pkt;     // actual packet
    riscv_pkt pkt_ref; // reference packet
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);

    pkt = riscv_pkt::type_id::create("pkt", this);
    pkt.copy(t);

    // pkt_ref = ....(pkt);

    `uvm_info("DEBUG", {$sformatf("%m\n"), pkt_ref.sprint()}, UVM_FULL);
    sink.write(pkt_ref);
  endfunction : write
endclass : riscv_refmodel
