`timescale 1ns/1ps

module alu_tb;

  typedef enum logic[3:0] {
      ALU_ADD = 4'b0000,
      ALU_SUB = 4'b0001,
      ALU_AND = 4'b0010,
      ALU_OR  = 4'b0011,
      ALU_XOR = 4'b0100,
      ALU_LT  = 4'b0101,
      ALU_GT  = 4'b0110 
    } alu_op_t;

  logic    [31:0] num1;
  logic    [31:0] num2;
  alu_op_t        operand;
  logic    [31:0] result;

  integer tests_run    = 0;
  integer tests_passed = 0;
  integer tests_failed = 0;

  alu dut(
      .num1(num1),
      .num2(num2),
      .opcode(operand),
      .result(result)
    );

  task check_result(input logic [31:0] expected, 
                    input string       test_name
    );
    tests_run++;
    #10;

    if (result == expected) begin
      $display("[PASS] %s", test_name);
      $display("Expected: 0x%08h, Got: 0x%08h", expected, result);
      tests_passed++;

    end else begin
      $display("[FAIL] %s", test_name);
      $display("Expected: 0x%08h, Got: 0x%08h", expected, result);
      tests_failed++;
    end
    $display("");
  endtask

  task run_test(
      input logic [31:0] a, 
      input logic [31:0] b, 
      input alu_op_t     op, 
      input logic [31:0] expected, 
      input string       test_name
    );

    num1    = a;
    num2    = b;
    operand = op;

    check_result(expected, test_name);
  endtask

  initial begin
    $display("RISC-V ALU Testbench");
    $display("");

    num1    = 32'h0;
    num2    = 32'h0;
    operand = ALU_ADD;

    #10;

    $display("Testing ADD");

    run_test(2, 2, ALU_ADD, 4, "ADD: 2 + 2 = 4");
    run_test(5, 8, ALU_ADD, 13, "ADD: 5 + 8 = 13");
    run_test(10, 10, ALU_ADD, 20, "ADD: 10 + 10 = 20");

    $display("Testing SUB");

    run_test(3, 2, ALU_SUB, 1, "SUB: 3 - 2 = 1");
    run_test(5, 5, ALU_SUB, 0, "SUB: 5 - 5 = 0");
    run_test(10, 14, ALU_SUB, -4, "SUB: 10 - 14 = -4");

    $display("");
    $display("Test Summary");
    $display("Total tests run: %0d", tests_run);
    $display("Total tests passed: %0d", tests_passed);
    $display("Total tests failed: %0d", tests_failed);

    $finish;
  end
endmodule
