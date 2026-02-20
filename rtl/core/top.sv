`timescale 1ns/1ps

module top (
  input logic clk, 
  input logic reset
);

  logic [31:0] instruction_a,
               instruction_out,
               read_data1,
               read_data2,
               num2,
               data_memory_read_data,
               alu_result;
               write_data;
  
  logic        branch, 
               mem_read, 
               alu_src, 
               mem_write, 
               mem_to_reg, 
               reg_write;
  
  logic [6:0]  opcode;
  logic [4:0]  rd, rs1, rs2;
  logic [2:0]  funct3;
  logic [6:0]  funct7;
  logic [11:0] imm12;
  

  program_counter program_counter(
    .clk(clk),
    .reset(reset),
    .pc_in(),
    .pc_out(instruction_a)
  );

  instruction_memory instruction_memory(
    .reset(reset),
    .address(instruction_a),
    .instruction(instruction_out)
  );

  instruction_decoder instruction_decoder(
    .instruction(instruction_out),
    .opcode(opcode),
    .rd(rd),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .funct7(funct7)
  );

  register_file register_file(
    .clk(clk),
    .reset(reset),
    .reg_write(reg_write),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2),
  );

  controller controller(
    .opcode(opcode),
    .branch(branch),
    .mem_read(mem_read),
    .alu_src(alu_src),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .reg_write(reg_write)
  );

  alu alu(
    .opcode({funct7, funct3}),
    .num1(read_data1),
    .num2(num2),
    .result(alu_result),
    .zero()
  );

  sign_extender sign_extender(
    .funct7(funct7),
    .rs2(rs2),
    .rd(rd),
    .opcode(opcode),
    .imm_ex(imm12)
  );

  i_mux mux2(
    .sel(alu_src),
    .in0(read_data2),
    .in1(imm12),
    .out(num2)
  );

  data_memory data_memory(
    .clk(clk),
    .mem_write(mem_write),
    .mem_read(mem_read),
    .reset(reset),
    .width(funct3),
    .address(alu_result),
    .write_data(read_data2),
    .read_data(data_memory_read_data)
  );

  data_mux mux2(
    .sel(mem_to_reg),
    .in0(alu_result),
    .in1(data_memory_read_data),
    .out(write_data)
  )


endmodule
