`timescale 1ns/1ps

module riscv_core (
  input wire clk, 
  input wire reset
);

  wire [31:0] instruction_a;

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
    .write_data(),
    .read_data1(),
    .read_data2(),
  );
endmodule
