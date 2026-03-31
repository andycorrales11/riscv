class rtype_instr extends rv32i_instr;
  `uvm_object_utils(rtype_instr)

  rand logic [4:0] rs1;
  rand logic [4:0] rs2;
  rand logic [2:0] funct3;
  rand logic [6:0] funct7;
  rand logic [4:0] rd;

  `uvm_object_utils_begin(rtype_instr)
    `uvm_field_int(rs1, UVM_ALL_ON)
    `uvm_field_int(rs2, UVM_ALL_ON)
    `uvm_field_int(funct3, UVM_ALL_ON)
    `uvm_field_int(funct7, UVM_ALL_ON)
    `uvm_field_int(rd, UVM_ALL_ON)
  `uvm_object_utils_end

  constraint valid_funct3_c {
    funct3 inside {3'b000, 3'b001, 3'b010, 3'b100, 3'b101, 3'b110, 3'b111};
  }

  constraint valid_funct7_c {
    funct7 inside {7'b0000000, 7'b0100000};
    funct7 == 7'b0100000 -> funct3 inside {3'b000, 3'b101};
  }

  function new(string name = "rtype_instr");
    super.new(name);
  endfunction

  function logic [31:0] encode();
    return {funct7, rs2, rs1, funct3, rd, opcode};
  endfunction

endclass