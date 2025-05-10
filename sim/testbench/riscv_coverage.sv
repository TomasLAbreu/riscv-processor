//------------------------------------------------------------------------------
class riscv_coverage extends uvm_subscriber #(riscv_pkt);
//------------------------------------------------------------------------------
  `uvm_component_utils(riscv_coverage)

  riscv_pkt pkt;
  real result;

  covergroup cg;
    option.per_instance = 1;
    option.auto_bin_max = 1;

    addr: coverpoint pkt.addr {
      bins all[] = {[0 : 2**`RISCV_ADDR_WIDTH-1]};
    }
  endgroup : cg

  function new(string name = "riscv_coverage", uvm_component parent);
    super.new(name, parent);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);

    cg = new();
    result = 0;
  endfunction : new

  virtual function void write(T t);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);
    this.pkt = t;
    cg.sample();
    result = $get_coverage();
  endfunction : write

  virtual task wait_for_done();
    wait(result == 100.0);
    `uvm_info("COVERAGE", $sformatf("FCOV reached 100%%"), UVM_LOW);
  endtask : wait_for_done

endclass : riscv_coverage
