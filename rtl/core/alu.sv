`timescale 1ns/1ps

module alu (
  input  logic [3:0]  opcode,
  input  logic [31:0] num1,
  input  logic [31:0] num2,
  output logic [31:0] result,
  output logic        zero
);

  always_comb begin
    case (opcode)
      0: result = num1 + num2; // add
      1: result = num1 - num2; // sub
      2: result = num1 & num2; // and
      3: result = num1 | num2; // or
      4: result = num1 ^ num2; // xor
      5: result = (num1 < num2) ? 32'h00000001 : 32'h00000000; // less than
      6: result = (num1 > num2) ? 32'h00000001 : 32'h00000000; // greater than
      // add more later
    endcase
  end

  assign zero = (result == 32'h0) ? 1'b1 : 1'b0;

endmodule
