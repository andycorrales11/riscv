class rv32i_seq_item extends uvm_sequence_item;
  `uvm_object_utils(rv32i_seq_item)

  rand logic [6:0]  opcode;

  function new(string name = "rv32i_seq_item");
    super.new(name);
  endfunction

endclass