`timescale 1ns/1ps

module instruction_tb;

  import rv32i_pkg::*;

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

  task automatic run_program(input logic [31:0] instructions[]);
    reset = 1'b1;
    #1
    reset = 1'b0;
    for (int i = 0; i < instructions.size(); i++) begin
      dut.instruction_memory.memory[i*4] = instructions[i];
      $display("Loading instruction 0x%8h at address %0d", instructions[i], i*4);
    end
    // Run for enough cycles to execute all instructions
    for (int cycle = 0; cycle < instructions.size() + 1; cycle++) begin
      @(posedge clk);
    end
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

  task automatic check_dmem(
    input logic [31:0] addr,
    input logic [31:0] expected,
    input string       test_name
  );
    logic [31:0] read_data;
    read_data = dut.data_memory.memory[addr];
    $display("Reading data memory[%0d] for test: %s", addr, test_name);
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

  task automatic test_i_type();
    logic [31:0] instruction[] = new[1];
    // ADDI: x1 = x0(0) + 32 = 32 FAILS
    instruction[0] = encode_i_type(12'd32, 5'd0, F3_ADD_SUB, 5'd1); // ADDI x1, x0, 32
    run_program(instruction);
    check_reg(5'd1, 32'd32, "I-type ADDI: 32 = 0 + 32");

    // ADDI: x1 = x0(0) + 30 = 30 PASSES
    instruction[0] = encode_i_type(12'd30, 5'd0, F3_ADD_SUB, 5'd1); // ADDI x1, x0, 30
    run_program(instruction);
    check_reg(5'd1, 32'd30, "I-type ADDI: 30 = 0 + 30");
    
  endtask


  task automatic test_r_type();
    logic [31:0] instructions[] = new[3];
    $display("Testing R-Type instructions");
    // ADD: x3 = x1(1) + x2(2) = 3
    instructions[0] = encode_i_type(12'd1, 5'd0, F3_ADD_SUB, 5'd1);  // ADDI x1, x0, 1
    instructions[1] = encode_i_type(12'd2, 5'd0, F3_ADD_SUB, 5'd2);  // ADDI x2, x0, 2
    instructions[2] = encode_r_type(F7_DEFAULT, 5'd2, 5'd1, F3_ADD_SUB, 5'd3);
    run_program(instructions);
    check_reg(5'd3, 32'd3, "R-type ADD: 3 = 1 + 2");

    // SUB: x3 = x1(7) - x2(4) = 3
    instructions[0] = encode_i_type(12'd7, 5'd0, F3_ADD_SUB, 5'd1);  // ADDI x1, x0, 7
    instructions[1] = encode_i_type(12'd4, 5'd0, F3_ADD_SUB, 5'd2);  // ADDI x2, x0, 4
    instructions[2] = encode_r_type(F7_ALT, 5'd2, 5'd1, F3_ADD_SUB, 5'd3);
    run_program(instructions);
    check_reg(5'd3, 32'd3, "R-type SUB: 3 = 7 - 4");

    // AND: x3 = x1(0b1100) & x2(0b1010) = 0b1000 = 8
    instructions[0] = encode_i_type(12'd12, 5'd0, F3_ADD_SUB, 5'd1); // ADDI x1, x0, 12
    instructions[1] = encode_i_type(12'd10, 5'd0, F3_ADD_SUB, 5'd2); // ADDI x2, x0, 10
    instructions[2] = encode_r_type(F7_DEFAULT, 5'd2, 5'd1, F3_AND, 5'd3);
    run_program(instructions);
    check_reg(5'd3, 32'd8, "R-type AND: 8 = 0b1100 & 0b1010");

    // OR: x3 = x1(0b1100) | x2(0b1010) = 0b1110 = 14
    instructions[0] = encode_i_type(12'd12, 5'd0, F3_ADD_SUB, 5'd1); // ADDI x1, x0, 12
    instructions[1] = encode_i_type(12'd10, 5'd0, F3_ADD_SUB, 5'd2); // ADDI x2, x0, 10
    instructions[2] = encode_r_type(F7_DEFAULT, 5'd2, 5'd1, F3_OR, 5'd3);
    run_program(instructions);
    check_reg(5'd3, 32'd14, "R-type OR: 14 = 0b1100 | 0b1010");

    // XOR: x3 = x1(0b1100) ^ x2(0b1010) = 0b0110 = 6
    instructions[0] = encode_i_type(12'd12, 5'd0, F3_ADD_SUB, 5'd1); // ADDI x1, x0, 12
    instructions[1] = encode_i_type(12'd10, 5'd0, F3_ADD_SUB, 5'd2); // ADDI x2, x0, 10
    instructions[2] = encode_r_type(F7_DEFAULT, 5'd2, 5'd1, F3_XOR, 5'd3);
    run_program(instructions);
    check_reg(5'd3, 32'd6, "R-type XOR: 6 = 0b1100 ^ 0b1010");

  endtask

  task automatic test_s_type();
    logic [31:0] instructions[] = new[3];
    $display("Testing S-Type instructions");
    // SW: store x1(42) to data_memory[5]
    instructions[0] = encode_i_type(12'd12, 5'd0, F3_ADD_SUB, 5'd1); // ADDI x1, x0, 12
    instructions[1] = encode_i_type(12'd5,  5'd0, F3_ADD_SUB, 5'd2); // ADDI x2, x0, 5
    instructions[2] = encode_s_type(12'd0, 5'd1, 5'd2, F3_SW);       // SW x1, x2 -> data_memory[5] = 12
    run_program(instructions);
    check_dmem(32'd5, 32'd12, "S-type SW: data_memory[5] = 12");
  endtask

  initial begin
    $dumpfile("sim/waves/riscv_tb.vcd");
    $display("Instruction Testbench");
    $display("");
    dut.program_counter.pc_out = 32'h0; // Start at address 0

    test_i_type();
    test_r_type();
    test_s_type();

    $display("Tests run: %0d, Passed: %0d, Failed: %0d", tests_run, tests_passed, tests_failed);
    $finish;
  end

endmodule