//------------------------------------------------------------------------------
class riscv_scoreboard extends uvm_scoreboard;
//------------------------------------------------------------------------------
  `uvm_component_utils(riscv_scoreboard)
  `uvm_analysis_imp_decl(_actual)
  `uvm_analysis_imp_decl(_expected)

  uvm_analysis_imp_actual #(riscv_pkt, riscv_scoreboard) actual_source;
  uvm_analysis_imp_expected #(riscv_pkt, riscv_scoreboard) expected_source;

  int num_mismatches = 0;
  int num_matches = 0;

  riscv_pkt actual_queue[$];
  riscv_pkt expected_queue[$];

  function new(string name = "riscv_scoreboard", uvm_component parent);
    super.new(name, parent);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);
  endfunction

  // TODO: reset function that clears num_matches* and others...
  function void reset();
    num_mismatches = 0;
    num_matches = 0;
    actual_queue.delete();
    expected_queue.delete();
  endfunction : reset

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_FULL);

    actual_source = new("actual_source", this);
    expected_source = new("expected_source", this);
  endfunction : build_phase

  virtual function void write_actual(riscv_pkt t);
    riscv_pkt pkt = riscv_pkt::type_id::create("pkt", this);
    pkt.copy(t);
    actual_queue.push_back(pkt);
    check_queues();
  endfunction : write_actual

  virtual function void write_expected(riscv_pkt t);
    riscv_pkt pkt = riscv_pkt::type_id::create("pkt", this);
    pkt.copy(t);
    expected_queue.push_back(pkt);
    check_queues();
  endfunction : write_expected

  virtual function void check_queues();
    while ((expected_queue.size() > 0) && (actual_queue.size() > 0)) begin
      riscv_pkt expected_pkt = expected_queue.pop_front();
      riscv_pkt actual_pkt = actual_queue.pop_front();

      if (!actual_pkt.compare(expected_pkt)) begin
        num_mismatches++;
        expected_pkt.display("ERROR");
        actual_pkt.display("ERROR");
      end else begin
        num_matches++;
        `uvm_info("SB_CHECK", $sformatf("Pkt #%0d matched expected", num_matches), UVM_MEDIUM);
      end
    end
  endfunction : check_queues

endclass : riscv_scoreboard
