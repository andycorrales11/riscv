class utype_instr extends rv32i_instr;
  `uvm_object_utils(utype_instr)

  rand logic [19:0] imm;
  rand logic [4:0]  rd;

  `uvm_object_utils_begin(utype_instr)
    `uvm_field_int(imm, UVM_ALL_ON)
    `uvm_field_int(rd, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "utype_instr");
    super.new(name);
  endfunction

  function logic [31:0] encode();
    return {imm, rd, opcode};
  endfunction

endclass