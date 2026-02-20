`timescale 1ns/1ps

module rtype_tb;

  parameter logic [6:0] R_TYPE = 7'b0110011;

  logic clk;
  logic reset;

  integer tests_run = 0;
  integer tests_passed = 0;
  integer tests_failed = 0;

  top dut (
    .clk(clk),
    .reset(reset)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  function automatic logic [31:0] encode_r_type(
    input logic [6:0] funct7,
    input logic [4:0] rs2, 
    input logic [4:0] rs1, 
    input logic [2:0] funct3, 
    input logic [4:0] rd
  );
    return {funct7, rs2, rs1, funct3, rd, R_TYPE};
  endfunction

  task automatic check_reg(
    input logic [4:0]  rd,
    input logic [31:0] expected,
    input string       test_name
  );
    logic [31:0] read_data;
    read_data = dut.register_file.registers[rd];
    if (read_data === expected) begin
      $display("[PASS] %s", test_name);
      $display("Expected: 0x%08h, Got: 0x%08h", expected, read_data);
      tests_passed++;
    end else begin
      $display("[FAIL] %s", test_name);
      $display("Expected: 0x%08h, Got: 0x%08h", expected, read_data);
      tests_failed++;
    end
    $display("");
  endtask

  task automatic test_r_type();
    logic [31:0] instruction;
    logic [31:0] a, b, result;

    reset = 1'b1;

    #1;

    dut.instruction_memory.memory[0] = encode_r_type(7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3); // ADD x3, x1, x2

    @(posedge clk);
    @(posedge clk);

    reset = 1'b0;

    check_reg(5'd3, 32'h00000003, "R-type ADD: x3 = x1 + x2");

  endtask

  initial begin
    $dumpfile("sim/waves/riscv_tb.vcd");
    $display("R-type Instruction Testbench");
    $display("");

    test_r_type();

    $display("Tests run: %0d, Passed: %0d, Failed: %0d", tests_run, tests_passed, tests_failed);
    $finish;
  end

endmodule