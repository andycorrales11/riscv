class base_test extends uvm_test;

  `uvm_component_utils(base_test)

  function new(string name = "base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  rv32i_tb tb;

  virtual function build_phase(uvm_phase phase);
    super.build_phase(phase);
    tb = new("tb",. this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction

endclass

