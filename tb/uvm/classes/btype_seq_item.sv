class btype_seq_item extends rv32i_seq_item;
  `uvm_object_utils(btype_seq_item)

  rand logic [4:0] rs1;
  rand logic [4:0] rs2;
  rand logic [2:0] funct3;
  rand logic [11:0] imm;

  function new(string name = "btype_seq_item");
    super.new(name);
  endfunction

endclass