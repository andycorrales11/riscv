class btype_seq_item extends rv32i_seq_item;
  `uvm_object_utils(btype_seq_item)

  rand logic [4:0] rs1;
  rand logic [4:0] rs2;
  rand logic [2:0] funct3;
  rand logic [11:0] imm;

  `uvm_object_utils_begin(btype_seq_item)
    `uvm_field_int(rs1, UVM_ALL_ON)
    `uvm_field_int(rs2, UVM_ALL_ON)
    `uvm_field_int(funct3, UVM_ALL_ON)
    `uvm_field_int(imm, UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name = "btype_seq_item");
    super.new(name);
  endfunction

endclass