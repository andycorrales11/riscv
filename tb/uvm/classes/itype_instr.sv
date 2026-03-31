class itype_instr extends rv32i_instr;
  `uvm_object_utils(itype_instr)

  rand logic [4:0]  rs1;
  rand logic [2:0]  funct3;
  logic [11:0] imm;
  rand logic [4:0]  rd;

  `uvm_object_utils_begin(itype_instr)
    `uvm_field_int(rs1, UVM_ALL_ON)
    `uvm_field_int(funct3, UVM_ALL_ON)
    `uvm_field_int(imm, UVM_ALL_ON)
    `uvm_field_int(rd, UVM_ALL_ON)
  `uvm_object_utils_end

  constraint valid_funct3_c {
    opcode == 7'b0000011 -> funct3 inside {3'b000, 3'b001, 3'b010, 3'b100, 3'b101};
    opcode == 7'b1100111 -> funct3 == 3'b000;
  }

  function new(string name = "itype_instr");
    super.new(name);
  endfunction

  function logic [31:0] encode();
    return {imm, rs1, funct3, rd, opcode};
  endfunction

endclass