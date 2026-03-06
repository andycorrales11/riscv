module top();
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_pkg::*;

  `include "rv32i_tb.sv"
  `include "rv32i_test_lib.sv"

  parameter DATA_WIDTH = 32;

  logic clk;
  logic if_reset;

  logic [DATA_WIDTH-1:0] instruction;
  logic                  endOfTest;

  rv32i_if if0(clk);

  assign instruction = if0.instruction;
  assign if_reset    = if0.reset;
  assign if0.endOfTest = endOfTest;

  cpu inst_cpu (
    .clk(clk),
    .reset(if_reset)
  );

  initial begin
    clk = 1'b0;
    forever
      #5 clk = ~clk;
  end

  initial begin 
    `uvm_info("TOP", "Starting simulation", UVM_LOW)

    uvm_config_db#(virtual rv32i_if)::set(null, "*.tb.rv32i.*", "vif", if0);
    run_test();
    `uvm_info("TOP", "Finished simulation", UVM_LOW)
  end
  
endmodule