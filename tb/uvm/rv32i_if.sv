`define RUN_TEST_RESP_TIME 100

interface rv32i_if (input logic clk);
  
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  parameter int DATA_WIDTH = 32;

  // input
  logic endOfTest;

  // outputs
  logic [DATA_WIDTH-1:0] instruction;
  logic                  reset;

  initial begin
    reset       = 1'b1;
    instruction = 32'b0;
  end

endinterface


