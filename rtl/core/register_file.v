`timescale 1ns/1ps

module register_file (
  input wire         clk,
  input wire         reset,
  input wire         reg_write,
  input wire [19:15] rs1,
  input wire [24:20] rs2,
  input wire [11:7]  rd,
  input wire [31:0]  write_data,

  output wire [31:0] read_data1,
  output wire [31:0] read_data2
  );

  reg [31:0] registers [31:0];

  assign read_data1 = registers[rs1];
  assign read_data2 = registers[rs2];

  int i;

  always @(posedge clk) begin
    if (reset == 1'b1) begin
      for(i = 0; i < 32; i = i + 1) registers[k] = 32'h0;
    end else if (reg_write == 1'b1) begin
      registers[rd] = write_data;
    end
  end
endmodule
