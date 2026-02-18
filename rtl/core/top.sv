`timescale 1ns/1ps

module top (
  input logic clk, 
  input logic reset
);

  logic [31:0] instruction_a,
               instruction_out,
               read_data1,
               read_data2,
               num2;
  
  logic        alu_src;

  assign alu_src = 1'b0; // for now, always use register value as num2

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
    .read_data1(read_data1),
    .read_data2(read_data2),
  );

  alu alu(
    .opcode(),
    .num1(read_data1),
    .num2(),
    .result()
    .zero()
  );

  i_mux mux2(
    .sel(alu_src),
    .in0(read_data2),
    .in1(),
    .out(num2)
  );
endmodule
