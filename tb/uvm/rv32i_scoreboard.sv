class rv32i_scoreboard extends uvm_scoreboard;

  rv32i_cpu_expected_state expected_state[$];
  rv32i_cpu_actual_state   actual_state[$];

  uvm_analysis_imp #(rv32i_monitor_txn, rv32i_scoreboard) imp;

  function new (string name, uvm_component parent);
    super.new(name, parent);
    imp = new("imp", this);
  endfunction

  function void write(input rv32i_monitor_txn txn);
    // FINISH ME: Implement scoreboard checking logic here
  endfunction

endclass