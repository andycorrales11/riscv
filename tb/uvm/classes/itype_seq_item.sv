class itype_seq_item extends rv32i_seq_item;
  `uvm_object_utils(itype_seq_item)

  rand logic [4:0] rs1;
  rand logic [2:0] funct3;
  rand logic [11:0] imm;
  rand logic [4:0] rd;

  `uvm_object_utils_begin(itype_seq_item)
    `uvm_field_int(rs1, UVM_ALL_ON)
    `uvm_field_int(funct3, UVM_ALL_ON)
    `uvm_field_int(imm, UVM_ALL_ON)
    `uvm_field_int(rd, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "itype_seq_item");
    super.new(name);
  endfunction

endclass