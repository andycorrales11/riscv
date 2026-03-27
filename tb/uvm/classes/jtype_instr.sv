class jtype_instr extends rv32i_instr;
  `uvm_object_utils(jtype_instr)

  logic      [19:0] imm;
  rand logic [4:0]  rd;

  `uvm_object_utils_begin(jtype_instr)
    `uvm_field_int(imm, UVM_ALL_ON)
    `uvm_field_int(rd, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "jtype_instr");
    super.new(name);
  endfunction

endclass