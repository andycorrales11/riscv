class rv32i_env extends uvm_env;
  `uvm_component_utils(rv32i_env)

  rv32i_agent agent;

  function new(string name = "rv32i_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = rv32i_agent::type_id::create("agent", this);
  endfunction

endclass