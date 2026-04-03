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

  covergroup instr_cg @(posedge clk);
    cp_opcode: coverpoint opcode {
      bins r_type  = {7'b0110011};
      bins i_arith = {7'b0010011};
      bins i_load  = {7'b0000011};
      bins s_type  = {7'b0100011};
      bins b_type  = {7'b1100011};
      bins lui     = {7'b0110111};
      bins auipc   = {7'b0010111};
      bins jal     = {7'b1101111};
      bins jalr    = {7'b1100111};
    }
    cp_funct3:    coverpoint instr_exec[14:12];
    cp_funct7:    coverpoint instr_exec[31:25] iff (opcode == 7'b0110011);
    cx_rtype_ops: cross cp_funct3, cp_funct7;
    cp_rd:        coverpoint rd { ignore_bins x0 = {5'b00000}; }
    cp_reg_write: coverpoint reg_write;
  endgroup

  instr_cg cg = new();

endinterface


