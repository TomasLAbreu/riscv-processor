//------------------------------------------------------------------------------
class riscv_driver extends uvm_driver #(riscv_pkt);
  //------------------------------------------------------------------------------
  `uvm_component_utils(riscv_driver)
  virtual riscv_if vif;

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
  endfunction : build_phase

  virtual task reset_phase(uvm_phase phase);
    super.reset_phase(phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);

    vif.rst_n = 1'b0;
    repeat(10) @(vif.cb);
    vif.rst_n = 1'b1;
  endtask : reset_phase

  virtual task run_phase(uvm_phase phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);

    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info("DEBUG", {$sformatf("%m\n"), req.sprint()}, UVM_FULL);

      send(req);
      seq_item_port.item_done();
    end
  endtask : run_phase

  virtual task send(riscv_pkt pkt);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);

    @(vif.cb);
    vif.instr = pkt.instr;
    vif.pc = pkt.pc;
    vif.dmem_addr = pkt.dmem_addr;
    vif.dmem_wr_be = pkt.dmem_wr_be;
    vif.dmem_wr_en = pkt.dmem_wr_en;
    vif.dmem_wr_data = pkt.dmem_wr_data;
    vif.dmem_rd_data = pkt.dmem_rd_data;
  endtask : send

endclass : riscv_driver
