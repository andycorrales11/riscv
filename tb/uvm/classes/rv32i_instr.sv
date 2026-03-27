class rv32i_instr extends uvm_object;
  `uvm_object_utils(rv32i_instr)

  rand logic [6:0]  opcode;

  constraint valid_opcode_c {
    opcode inside {
      7'b0110011, // R-type
      7'b0010011, // I-type (arithmetic)
      7'b0000011, // I-type (load)
      7'b1100111, // I-type (jalr)
      7'b0100011, // S-type
      7'b1100011, // B-type
      7'b0110111, // U-type (lui)
      7'b0010111, // U-type (auipc)
      7'b1101111  // J-type
    };
  }

  `uvm_object_utils_begin(rv32i_instr)
    `uvm_field_int(opcode, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "rv32i_instr");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf("opcode: %b", opcode);
  endfunction

  virtual function logic [31:0] encode();
    return {25'b0, opcode};
  endfunction

endclass