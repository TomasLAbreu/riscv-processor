//------------------------------------------------------------------------------
class riscv_monitor extends uvm_monitor;
//------------------------------------------------------------------------------
  `uvm_component_utils(riscv_monitor)
  virtual riscv_if vif;
  uvm_analysis_port #(riscv_pkt) sink;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);

    if (!uvm_config_db#(virtual riscv_if)::get(this, "", "vif", vif)) begin
      `uvm_error("CONFIG", "RISCV interface not found");
    end

    sink = new("sink", this);
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    riscv_pkt pkt;
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);
    pkt = riscv_pkt::type_id::create("pkt");

    forever begin
      fork
        begin : recv_pkt
          recv(pkt);
        end
        begin : watchdog
          repeat(1000) @(vif.cb);
          `uvm_fatal("TIMEOUT", "Too long waiting for a packet");
        end
      join_any
      disable fork;

      `uvm_info("DEBUG", {$sformatf("%m\n"), pkt.sprint()}, UVM_FULL);
      sink.write(pkt);
    end
  endtask : run_phase

  task recv(riscv_pkt pkt);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);

    wait(vif.rst_n);
    @(vif.cb);

    pkt.instr = vif.instr;
    pkt.pc = vif.pc;
    pkt.dmem_addr = vif.dmem_addr;
    pkt.dmem_wr_be = vif.dmem_wr_be;
    pkt.dmem_wr_en = vif.dmem_wr_en;
    pkt.dmem_wr_data = vif.dmem_wr_data;
    pkt.dmem_rd_data = vif.dmem_rd_data;
  endtask : recv

endclass : riscv_monitor
