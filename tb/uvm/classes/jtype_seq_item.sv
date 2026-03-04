class jtype_seq_item extends rv32i_seq_item;
  `uvm_object_utils(jtype_seq_item)

  rand logic [19:0] imm;
  rand logic [4:0] rd;

  `uvm_object_utils_begin(jtype_seq_item)
    `uvm_field_int(imm, UVM_ALL_ON)
    `uvm_field_int(rd, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "jtype_seq_item");
    super.new(name);
  endfunction

endclass