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
      dut.instruction_memory.memory[i] = instructions[i];
      dut.program_counter.pc_out = i; // Set PC to the instruction address
      @(posedge clk); // Wait for the instruction to be fetched and executed
      @(posedge clk); // Wait for the next cycle to ensure execution completes
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

  task automatic test_r_type();
    logic [31:0] instructions[] = new[3];
    $display("Testing R-Type instructions");
    // ADD: x3 = x1(1) + x2(2) = 3
    instructions[0] = encode_i_type(12'b000000000001, 5'd1, F3_ADD_SUB, 5'd1); 
    instructions[1] = encode_i_type(12'b000000000010, 5'd2, F3_ADD_SUB, 5'd2); 
    instructions[2] = encode_r_type(F7_DEFAULT, 5'd2, 5'd1, F3_ADD_SUB, 5'd3); 
    check_reg(5'd3, 32'h00000003, "R-type ADD: 3 = 1 + 2");

    //SUB x3 = x1(7) - x2(4) = 3
    instructions[0] = encode_i_type(12'b000000000111, 5'd1, F3_ADD_SUB, 5'd1); 
    instructions[1] = encode_i_type(12'b000000000100, 5'd2, F3_ADD_SUB, 5'd2); 
    instructions[2] = encode_r_type(F7_ALT, 5'd2, 5'd1, F3_ADD_SUB, 5'd3); 
    run_program(instructions);
    check_reg(5'd3, 32'h00000003, "R-type SUB: 3 = 7 - 4");

    //AND x3 = x1(0b1100) & x2(0b1010) = 0b1000
    instructions[0] = encode_i_type(12'b000000001100, 5'd1, F3_ADD_SUB, 5'd1); 
    instructions[1] = encode_i_type(12'b000000001010, 5'd2, F3_ADD_SUB, 5'd2); 
    instructions[2] = encode_r_type(F7_DEFAULT, 5'd2, 5'd1, F3_AND, 5'd3);
    run_program(instructions);
    check_reg(5'd3, 32'h00000008, "R-type AND: 0b1000 = 0b1100 & 0b1010");

    //OR x3 = x1(0b1100) | x2(0b1010) = 0b1100
    instructions[0] = encode_i_type(12'b000000001100, 5'd1, F3_ADD_SUB, 5'd1); 
    instructions[1] = encode_i_type(12'b000000001010, 5'd2, F3_ADD_SUB, 5'd2); 
    instructions[2] = encode_r_type(F7_DEFAULT, 5'd2, 5'd1, F3_OR, 5'd3);
    run_program(instructions);
    check_reg(5'd3, 32'h0000000C, "R-type OR: 0b1100 = 0b1100 | 0b1010");

    //XOR x3 = x1(0b1100) ^ x2(0b1010) = 0b0100
    instructions[0] = encode_i_type(12'b000000001100, 5'd1, F3_ADD_SUB, 5'd1); 
    instructions[1] = encode_i_type(12'b000000001010, 5'd2, F3_ADD_SUB, 5'd2); 
    instructions[2] = encode_r_type(F7_DEFAULT, 5'd2, 5'd1, F3_XOR, 5'd3);  
    run_program(instructions);
    check_reg(5'd3, 32'h00000004, "R-type XOR: 0b0100 = 0b1100 ^ 0b1010");
    

  endtask

  task automatic test_s_type();
    logic [31:0] instructions[] = new[3];
    $display("Testing S-Type instructions");
    // Store word: MEM[0] = x1(0xDEADBEEF)
    instructions[0] = encode_i_type(12'b000000000000, 5'd1, F3_ADD_SUB, 5'd1); 
    instructions[1] = encode_i_type(12'b000000000000, 5'd2, F3_ADD_SUB, 5'd2); 
    instructions[2] = encode_s_type(12'b000000000000, 5'd1, 5'd2, F3_SW); 
    run_program(instructions);
    check_reg(5'd1, 32'hDEADBEEF, "S-type SW: MEM[0] = 0xDEADBEEF");
  endtask

  initial begin
    $dumpfile("sim/waves/riscv_tb.vcd");
    $display("Instruction Testbench");
    $display("");

    test_r_type();
    test_s_type();

    $display("Tests run: %0d, Passed: %0d, Failed: %0d", tests_run, tests_passed, tests_failed);
    $finish;
  end

endmodule