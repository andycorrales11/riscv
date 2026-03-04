module top();
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_pkg::*;

  `include "rv32i_tb.sv"
  `include "rv32i_test_lib.sv"

  initial begin
    run_test();
  end
  
endmodule