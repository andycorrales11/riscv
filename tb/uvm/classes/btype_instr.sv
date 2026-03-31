class btype_instr extends rv32i_instr;
  `uvm_object_utils(btype_instr)

  rand logic [4:0]  rs1;
  rand logic [4:0]  rs2;
  rand logic [2:0]  funct3;
  logic      [11:0] imm;

  `uvm_object_utils_begin(btype_instr)
    `uvm_field_int(rs1, UVM_ALL_ON)
    `uvm_field_int(rs2, UVM_ALL_ON)
    `uvm_field_int(funct3, UVM_ALL_ON)
    `uvm_field_int(imm, UVM_ALL_ON)
  `uvm_object_utils_end
  
  constraint valid_funct3_c {
    funct3 inside {3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111};
  }

  function new(string name = "btype_instr");
    super.new(name);
  endfunction

  function logic [31:0] encode();
    return {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], opcode};
  endfunction

endclass