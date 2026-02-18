`timescale 1ns/1ps

module data_memory (
  input logic        clk,
  input logic        mem_write,
  input logic        mem_read,
  input logic        reset,
  input logic [31:0] address,
  input logic [31:0] write_data,

  output logic [31:0] read_data
)

  logic [31:0] memory [63:0];

  assign read_data = (mem_read) ? memory[address] : 32'h00000000;

  int i;

  always_ff @(posedge clk) begin
    if (reset == 1'b1) begin
      for(i = 0; i < 64; i = i + 1) memory[i] = 32'h0;
    end else if (mem_write == 1'b1) begin
      memory[address] = write_data;
    end
  end

endmodule