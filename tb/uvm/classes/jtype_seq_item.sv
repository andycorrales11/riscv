class jtype_seq_item extends rv32i_seq_item;
  `uvm_object_utils(jtype_seq_item)

  rand logic [19:0] imm;
  rand logic [4:0] rd;

  function new(string name = "jtype_seq_item");
    super.new(name);
  endfunction

endclass