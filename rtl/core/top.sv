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
  
  logic        branch, mem_read, alu_src, mem_write, mem_to_reg, reg_write;

  program_counter program_counter(
    .clk(clk),
    .reset(reset),
    .pc_in(),
    .pc_out(instruction_a)
  );

  instruction_memory instruction_memory(
    .reset(reset),
    .address(),
    .instruction(instruction_a)
  );

  register_file register_file(
    .clk(clk),
    .reset(reset),
    .reg_write(),
    .rs1(),
    .rs2(),
    .rd(),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2),
  );

  alu alu(
    .opcode(),
    .num1(read_data1),
    .num2(num2),
    .result(alu_result),
    .zero()
  );

  i_mux mux2(
    .sel(alu_src),
    .in0(read_data2),
    .in1(),
    .out(num2)
  );

  data_memory data_memory(
    .clk(clk),
    .mem_write(mem_write),
    .mem_read(mem_read),
    .reset(reset),
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
