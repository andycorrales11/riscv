`timescale 1ns/1ps

module instruction_memory (
  input  logic        reset,
  input  logic [31:0] address,
  output logic [31:0] instruction
);

  logic [31:0] memory [63:0];

  assign instruction = memory[address >> 2];

  initial begin
    $readmemh("instruction_memory.hex", memory);
  end
  
  always_ff @(posedge reset) begin
    for (int i = 0; i < 64; i++) begin
      memory[i] <= 32'h00000000;
    end
  end
endmodule
