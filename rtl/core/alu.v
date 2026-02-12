`timescale 1ns/1ps

module alu (
  input wire [3:0]  opcode,
  input wire [31:0] num1,
  input wire [31:0] num2,
  output reg [31:0] result
);

  always @(*) begin
    case (opcode)
      0: result = num1 + num2; // add
      1: result = num1 - num2; // sub
      2: result = num1 & num2; // and
      3: result = num1 | num2; // or
      4: result = num1 ^ num2; // xor
      5: result = num1 < num2; // less than
      6: result = num1 > num2; // greater than
      // add more later
    endcase
  end

endmodule
