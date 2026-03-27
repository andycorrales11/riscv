class rv32i_seq_item extends uvm_sequence_item;
  `uvm_object_utils(rv32i_seq_item)

  rv32i_instr instrs [];
  int         num_cycles;

  `uvm_object_utils_begin(rv32i_seq_item)
    `uvm_field_array_object(instrs, UVM_ALL_ON)
    `uvm_field_int(num_cycles, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "rv32i_seq_item");
    super.new(name);
  endfunction

endclass