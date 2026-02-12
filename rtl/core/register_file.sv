`timescale 1ns/1ps

module register_file (
  input logic         clk,
  input logic         reset,
  input logic         reg_write,
  input logic [19:15] rs1,
  input logic [24:20] rs2,
  input logic [11:7]  rd,
  input logic [31:0]  write_data,

  output logic [31:0] read_data1,
  output logic [31:0] read_data2
  );

  logic [31:0] registers [31:0];

  assign read_data1 = registers[rs1];
  assign read_data2 = registers[rs2];

  int i;

  always_ff @(posedge clk) begin
    if (reset == 1'b1) begin
      for(i = 0; i < 32; i = i + 1) registers[i] = 32'h0;
    end else if (reg_write == 1'b1) begin
      registers[rd] = write_data;
    end
  end
endmodule
