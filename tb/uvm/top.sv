module top();
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_pkg::*;

  `include "rv32i_tb.sv"
  `include "rv32i_test_lib.sv"

  parameter DATA_WIDTH = 32;

  logic clk;

  rv32i_if if0(clk);

  cpu inst_cpu (
    .clk(clk),
    .reset(if0.reset)
  );

  // Assign signals from DUt to interface
  assign if0.pc         = inst_cpu.instruction_a;
  assign if0.instr_exec = inst_cpu.instruction_out;
  assign if0.reg_write  = inst_cpu.reg_write;
  assign if0.rd         = inst_cpu.rd;
  assign if0.wr_data_rf = inst_cpu.write_data;
  assign if0.opcode     = inst_cpu.opcode;
  assign if0.mem_write  = inst_cpu.mem_write;
  assign if0.mem_addr   = inst_cpu.alu_result;
  assign if0.mem_wdata  = inst_cpu.read_data2;
  assign if0.pc_next    = inst_cpu.pc_next;

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