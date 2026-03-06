class rv32i_r_seq extends uvm_sequence #(rtype_seq_item);
  `uvm_object_utils(rv32i_r_seq)

  function new(string name = "rv32i_r_seq");
    super.new(name);
    set_automatic_phase_objection(1);          // apparently no longer need to manage objections in UVM 1.2? Keep any eye on this
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing R-type instructions", UVM_LOW)
    `uvm_do_with(req, {opcode == I_TYPE; rs1 == 5'b00000; funct3 == F3_ADD_SUB; imm = 12'b000000000001; rd == 5'b00001;}) 
    `uvm_do_with(req, {opcode == I_TYPE; rs1 == 5'b00000; funct3 == F3_ADD_SUB; imm = 12'b000000000010; rd == 5'b00010;})
    `uvm_do_with(req, {opcode == R_TYPE; rs1 == 5'b00001; rs2 == 5'b00010; funct3 == F3_ADD_SUB; funct7 == F7_DEFAULT; rd == 5'b00011;})
    `uvm_do_with(req, {opcode == R_TYPE; rs1 == 5'b00010; rs2 == 5'b00001; funct3 == F3_ADD_SUB; funct7 == F7_ALT; rd == 5'b00100;})
  endtask

endclass

class rv32i_i_seq extends uvm_sequence #(itype_seq_item);
  `uvm_object_utils(rv32i_i_seq)

  function new(string name = "rv32i_i_seq");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing I-type instructions", UVM_LOW)
    `uvm_do_with(req, {opcode == I_TYPE; rs1 == 5'b00000; funct3 == F3_ADD_SUB; imm = 12'b000000000001; rd == 5'b00001;}) 
    `uvm_do_with(req, {opcode == I_TYPE; rs1 == 5'b00000; funct3 == F3_ADD_SUB; imm = 12'b000000000010; rd == 5'b00010;})
  endtask

endclass

class rv32i_s_seq extends uvm_sequence #(stype_seq_item);
  `uvm_object_utils(rv32i_s_seq)

  function new(string name = "rv32i_s_seq");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing S-type instructions", UVM_LOW)
    `uvm_do_with(req, {opcode == S_TYPE; rs1 == 5'b00000; rs2 == 5'b00001; funct3 == F3_SB; imm = 12'b000000000001;}) 
    `uvm_do_with(req, {opcode == S_TYPE; rs1 == 5'b00000; rs2 == 5'b00010; funct3 == F3_SH; imm = 12'b000000000010;})
    `uvm_do_with(req, {opcode == S_TYPE; rs1 == 5'b00000; rs2 == 5'b00011; funct3 == F3_SW; imm = 12'b000000000011;})
  endtask

endclass



