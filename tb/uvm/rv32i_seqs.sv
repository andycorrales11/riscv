class rv32i_r_seq extends uvm_sequence #(rtype_seq_item);
  `uvm_object_utils(rv32i_r_seq)

  function new(string name = "rv32i_r_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing R-type instructions", UVM_LOW)
    `uvm_do_with(req, {opcode == I_TYPE; rs1 == 5'b00000; funct3 == F3_ADD_SUB; imm = 12'b000000000001; rd == 5'b00001;}) 
    `uvm_do_with(req, {opcode == I_TYPE; rs1 == 5'b00000; funct3 == F3_ADD_SUB; imm = 12'b000000000010; rd == 5'b00010;})
    `uvm_do_with(req, {opcode == R_TYPE; rs1 == 5'b00001; rs2 == 5'b00010; funct3 == F3_ADD_SUB; funct7 == F7_DEFAULT; rd == 5'b00011;})
  endtask

endclass



