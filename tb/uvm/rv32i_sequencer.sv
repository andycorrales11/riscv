class rv32i_sequencer extends uvm_sequencer #(rv32i_seq_item);
  `uvm_component_utils(rv32i_sequencer)

  function new(string name = "rv32i_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction

endclass