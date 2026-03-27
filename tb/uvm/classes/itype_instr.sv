class itype_instr extends rv32i_instr;
  `uvm_object_utils(itype_instr)

  rand logic [4:0] rs1;
  rand logic [2:0] funct3;
  rand logic [11:0] imm;
  rand logic [4:0] rd;

  `uvm_object_utils_begin(itype_instr)
    `uvm_field_int(rs1, UVM_ALL_ON)
    `uvm_field_int(funct3, UVM_ALL_ON)
    `uvm_field_int(imm, UVM_ALL_ON)
    `uvm_field_int(rd, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "itype_instr");
    super.new(name);
  endfunction

endclass