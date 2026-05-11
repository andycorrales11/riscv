`timescale 1ns/1ps

module instruction_memory (
  input  logic        clk,
  input  logic        load_en,
  input  logic [5:0]  load_addr,
  input  logic [31:0] load_data,
  input  logic [31:0] address,
  output logic [31:0] instruction
);

  logic [31:0] memory [63:0];

  assign instruction = memory[address >> 2];

  initial begin
    for (int i = 0; i < 64; i++) memory[i] = 32'h00000013; // NOP
  end

  always_ff @(posedge clk) begin
    if (load_en) memory[load_addr] <= load_data;
  end

endmodule
