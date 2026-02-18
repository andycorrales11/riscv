`timescale 1ns/1ps

module mux2 #(parameter WIDTH = 32) (
  input logic sel,
  input logic [WIDTH-1:0] in0,
  input logic [WIDTH-1:0] in1,
  output logic [WIDTH-1:0] out
);
  
  assign out = (sel == 1'b0) ? in0 : in1;

endmodule 