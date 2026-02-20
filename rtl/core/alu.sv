`timescale 1ns/1ps

module alu (
  input  logic [9:0] opcode,
  input  logic [31:0] num1,
  input  logic [31:0] num2,
  output logic [31:0] result,
  output logic        zero
);

  always_comb begin
    case (opcode)
      10'b0000000000: result = num1 + num2; // ADD - funct3 = 0x0, funct7 = 0x00
      10'b0010100000: result = num1 - num2; // SUB - funct3 = 0x0, funct7 = 0x20
      10'b0000000001: result = num1 << num2[4:0]; // SLL - funct3 = 0x1, funct7 = 0x00
      10'b0000000010: result = $signed(num1) < $signed(num2) ? 32'h1 : 32'h0; // SLT - funct3 = 0x2, funct7 = 0x00
      // 10'b0000000011: result = SLTU - funct3 = 0x3, funct7 = 0x00 (NOT IMPLEMENTED)
      10'b0000000100: result = num1 ^ num2; // XOR - funct3 = 0x4, funct7 = 0x00
      10'b0000000101: result = num1 >> num2[4:0]; // SRL  - funct3 = 0x5, funct7 = 0x00
      10'b0010100101: result = $signed(num1) >>> num2[4:0]; // SRA - funct3 = 0x5, funct7 = 0x20
      10'b0000000110: result = num1 | num2; // OR  - funct3 = 0x6, funct7 = 0x00
      10'b0000000111: result = num1 & num2; // AND - funct3 = 0x7, funct7 = 0x00
      default: result = 32'h0;
    endcase
  end

  assign zero = (result == 32'h0) ? 1'b1 : 1'b0;

endmodule
