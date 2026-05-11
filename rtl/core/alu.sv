`timescale 1ns/1ps

module alu (
  input  logic [3:0]  alu_op,
  input  logic [31:0] num1,
  input  logic [31:0] num2,
  input  logic        store_op, // 1 for store instructions, 0 for ALU operations
  output logic [31:0] result,
  output logic        zero
);

  // alu_op encoding (must match controller.sv):
  //   0000 ADD   0001 SUB   0010 SLL   0011 SLT
  //   0100 XOR   0101 SRL   0110 SRA   0111 OR    1000 AND

  always_comb begin
    if (store_op) begin
      // For store instructions, the ALU calculates the effective address
      result = num1 + num2; // base address + offset
    end else begin
      case (alu_op)
        4'b0000: result = num1 + num2;                                          // ADD
        4'b0001: result = num1 - num2;                                          // SUB
        4'b0010: result = num1 << num2[4:0];                                    // SLL
        4'b0011: result = $signed(num1) < $signed(num2) ? 32'h1 : 32'h0;        // SLT
        4'b0100: result = num1 ^ num2;                                          // XOR
        4'b0101: result = num1 >> num2[4:0];                                    // SRL
        4'b0110: result = $signed(num1) >>> num2[4:0];                          // SRA
        4'b0111: result = num1 | num2;                                          // OR
        4'b1000: result = num1 & num2;                                          // AND
        default: result = 32'h0;
      endcase
    end
  end

  assign zero = (result == 32'h0) ? 1'b1 : 1'b0;

endmodule
