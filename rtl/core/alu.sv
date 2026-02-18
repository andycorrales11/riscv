`timescale 1ns/1ps

module alu (
  input  logic [10:0] opcode,
  input  logic [31:0] num1,
  input  logic [31:0] num2,
  output logic [31:0] result,
  output logic        zero
);

  always_comb begin
    case (opcode)
      11'b00000000000: result = num1 + num2; // ADD
      11'b01000000000: result = num1 - num2; // SUB
      11'b00000000001: result = num1 << num2[4:0]; // SLL
      11'b00000000010: result = $signed(num1) < $signed(num2) ? 32'h1 : 32'h0; // SLT
      11'b00000000100: result = num1 ^ num2; // XOR
      11'b00000000101: result = num1 >> num2[4:0]; // SRL
      11'b01000000101: result = $signed(num1) >>> num2[4:0]; // SRA
      11'b00000000110: result = num1 | num2; // OR
      11'b00000000111: result = num1 & num2; // AND
      default: result = 32'h0;
    endcase
  end

  assign zero = (result == 32'h0) ? 1'b1 : 1'b0;

endmodule
