interface rv32i_if (input logic clk);
  logic        reset;
  logic        endOfTest;

  logic [31:0] pc;
  logic [31:0] instr_exec;
  logic        reg_write;
  logic [4:0]  rd;
  logic [31:0] wr_data_rf;
  logic [6:0]  opcode;
  logic        mem_write;
  logic [31:0] mem_addr;
  logic [31:0] mem_wdata;
  logic [31:0] pc_next;

  initial begin
    reset     = 1'b1;
    endOfTest = 1'b0;
  end
endinterface
