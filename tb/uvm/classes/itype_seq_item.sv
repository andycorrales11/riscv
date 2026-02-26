class itype_seq_item extends rv32i_seq_item;
  `uvm_object_utils(itype_seq_item)

  rand logic [4:0] rs1;
  rand logic [2:0] funct3;
  rand logic [11:0] imm;
  rand logic [4:0] rd;

  function new(string name = "itype_seq_item");
    super.new(name);
  endfunction

endclass