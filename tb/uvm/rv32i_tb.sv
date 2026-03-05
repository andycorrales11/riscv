class rv32i_tb extends uvm_env;
  `uvm_component_util(rv32i_tb)

  rv32i = rv32i_env;

  function new(string name = "rv32i_tb", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function build_phase(uvm_phase phase);
    super.build_phase(phase);
    rv32i = new("rv32i", this);
  endfunction

endclass