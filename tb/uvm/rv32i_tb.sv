class rv32i_tb extends uvm_env;
  `uvm_component_utils(rv32i_tb)

  rv32i_env rv32i;
  rv32i_scoreboard scoreboard; // could be here or in the env, but more reusable here?

  function new(string name = "rv32i_tb", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rv32i = rv32i_env::type_id::create("rv32i", this);
    scoreboard = rv32i_scoreboard::type_id::create("scoreboard", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    rv32i.agent.monitor.ap.connect(scoreboard.imp);
    // FINISH ME: ?

  endfunction

endclass