`define RUN_TEST_RESP_TIME 100

interface rv32i_if (input logic clk);
  
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  parameter int DATA_WIDTH = 32;

  // driver signals
  logic endOfTest;
  logic reset;

  // monitor signals
  logic [31:0] pc;
  logic [31:0] instr_exec;
  logic        reg_write;
  logic [4:0]  rd;
  logic [31:0] wr_data_rf;
  logic [6:0]  opcode;

  initial begin
    reset      = 1'b1;
    endOfTest  = 1'b0;
  end

endinterface


