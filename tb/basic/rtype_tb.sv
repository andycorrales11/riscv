`timescale 1ns/1ps

module rtype_tb;

  parameter logic [6:0] R_TYPE = 7'b0110011;
  parameter logic [6:0] I_TYPE = 7'b0010011;

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
  always #1 clk = ~clk;

  function automatic logic [31:0] encode_r_type(
    input logic [6:0] funct7,
    input logic [4:0] rs2, 
    input logic [4:0] rs1, 
    input logic [2:0] funct3, 
    input logic [4:0] rd
  );
    return {funct7, rs2, rs1, funct3, rd, R_TYPE};
  endfunction

  function automatic logic [31:0] encode_i_type(
    input logic [11:0] imm, 
    input logic [4:0] rs1, 
    input logic [2:0] funct3, 
    input logic [4:0] rd
  );
    return {imm, rs1, funct3, rd, I_TYPE};
  endfunction

  task automatic run_instruction(input logic [31:0] instruction, input logic [31:0] instruction_number);
    dut.instruction_memory.memory[instruction_number] = instruction;
    dut.program_counter.pc_out = instruction_number; // Set PC to the instruction address
    @(posedge clk); // Wait for the instruction to be fetched and executed
  endtask

  task automatic check_reg(
    input logic [4:0]  rd,
    input logic [31:0] expected,
    input string       test_name
  );
    logic [31:0] read_data;
    read_data = dut.register_file.registers[rd];
    $display("Reading Register x%0d for test: %s", rd, test_name);
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
    tests_run++;
  endtask

  task automatic test_r_type();
    logic [31:0] instruction;
    logic [31:0] a, b, result;

    reset = 1'b1;
    #1
    reset = 1'b0;

    instruction = encode_i_type(12'b000000000001, 5'd1, 3'b000, 5'd1); // ADD x1, x1, 1 (initialize x1 to 1)
    run_instruction(instruction, 0); // Load and execute instruction at address 0
    instruction = encode_i_type(12'b000000000010, 5'd2, 3'b000, 5'd2); // ADD x2, x2, 2 (initialize x2 to 2)
    run_instruction(instruction, 1); // Load and execute instruction at address 1
    instruction = encode_r_type(7'b0000000, 5'd1, 5'd2, 3'b000, 5'd3); // ADD x3, x2, x1
    run_instruction(instruction, 2); // Load and execute instruction at address 2


    check_reg(5'd3, 32'h00000003, "R-type ADD: x3 = x2 + x1");

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