class stype_instr extends rv32i_instr;
  `uvm_object_utils(stype_instr)

  rand logic [4:0] rs1;
  rand logic [4:0] rs2;
  rand logic [2:0] funct3;
  rand logic [11:0] imm;

  `uvm_object_utils_begin(stype_instr)
    `uvm_field_int(rs1, UVM_ALL_ON)
    `uvm_field_int(rs2, UVM_ALL_ON)
    `uvm_field_int(funct3, UVM_ALL_ON)
    `uvm_field_int(imm, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "stype_instr");
    super.new(name);
  endfunction

endclass