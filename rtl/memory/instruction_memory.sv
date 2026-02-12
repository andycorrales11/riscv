`timescale 1ns/1ps

module instruction_memory (
  input  logic        reset,
  input  logic [31:0] address,
  output logic [31:0] instruction
);

  logic [31:0] memory [63:0];

  assign instruction = memory[address];

  int i;

  always_latch @(posedge reset) begin
    for (i = 0; i < 64; i = i + 1) begin
      memory[i] = 32'h00000000;
    end
  end
endmodule
