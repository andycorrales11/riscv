`timescale 1ns/1ps

module register_file (
  input logic         clk,
  input logic         reset,
  input logic         reg_write,
  input logic [4:0]   rs1,
  input logic [4:0]   rs2,
  input logic [4:0]   rd,
  input logic [31:0]  write_data,

  output logic [31:0] read_data1,
  output logic [31:0] read_data2
);

  logic [31:0] registers [31:0];

  assign read_data1 = registers[rs1];
  assign read_data2 = registers[rs2];

  always_ff @(posedge clk) begin
    if (reset) begin
      for (int i = 0; i < 32; i++) registers[i] <= 32'h0;
    end else if (reg_write) begin
      registers[rd] <= write_data;
    end
  end

endmodule
