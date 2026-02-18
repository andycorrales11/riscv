`timescale 1ns/1ps

module mux2 #(parameter WIDTH = 32) (
  input logic sel,
  input logic [WIDTH-1:0] in0,
  input logic [WIDTH-1:0] in1,
  output logic [WIDTH-1:0] out
);

  always_comb begin
    case (sel)
      1'b0: out = in0;
      1'b1: out = in1;
    endcase
  end