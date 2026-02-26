`timescale 1ns/1ps

module mux3 #(parameter WIDTH = 32) (
  input logic [1:0] sel,
  input logic [WIDTH-1:0] in0,
  input logic [WIDTH-1:0] in1,
  input logic [WIDTH-1:0] in2,
  output logic [WIDTH-1:0] out
);
  
  assign out = (sel == 2'b00) ? in0 :
               (sel == 2'b01) ? in1 : in2;
endmodule