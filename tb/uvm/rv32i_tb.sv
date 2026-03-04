class rv32i_tb extends uvm_env;
  `uvm_component_util(rv32i_tb)

  function new(string name = "rv32i_tb", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function build_phase(uvm_phase phase);
    super.build_phase(phase);
    // add components later
  endfunction

endclass