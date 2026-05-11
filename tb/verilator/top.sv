`timescale 1ns/1ps

module top;
  import rv32i_pkg::*;

  `include "rv32i_ref_model.sv"

  // Clock + DUT signals
  logic clk;
  logic reset;
  logic        inst_load_en;
  logic [5:0]  inst_load_addr;
  logic [31:0] inst_load_data;

  rv32i_if if0(clk);

  cpu inst_cpu (
    .clk(clk),
    .reset(reset),
    .inst_load_en(inst_load_en),
    .inst_load_addr(inst_load_addr),
    .inst_load_data(inst_load_data)
  );

  assign if0.reset      = reset;
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

  // Clock
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // Program storage (encoded instructions).
  logic [31:0] program_mem [64];
  int          program_size;
  int          num_cycles;

  // Scoreboard state
  rv32i_ref_model ref_model;
  int pass_count;
  int fail_count;

  // ---------- Test program builders ----------

  task automatic build_r_test();
    rtype_instr  r_instrs [$];
    itype_instr  init_instr;
    rtype_instr  r;
    logic [4:0]  src_regs [$];
    int          n;
    int          idx;
    n = $urandom_range(5, 20);
    for (int i = 0; i < n; i++) begin
      r        = new();
      r.opcode = R_TYPE;
      void'(r.do_randomize());
      r_instrs.push_back(r);
      push_unique_reg(src_regs, r.rs1);
      push_unique_reg(src_regs, r.rs2);
    end
    idx = 0;
    foreach (src_regs[i]) begin
      init_instr        = new();
      init_instr.opcode = I_TYPE;
      init_instr.funct3 = 3'b000;
      init_instr.rs1    = 5'b0;
      init_instr.rd     = src_regs[i];
      init_instr.imm    = 12'($urandom_range(1, 31));
      program_mem[idx]  = init_instr.encode();
      idx++;
    end
    foreach (r_instrs[i]) begin
      program_mem[idx] = r_instrs[i].encode();
      idx++;
    end
    program_size = idx;
    num_cycles   = idx + 5;
    $display("[TOP] r_test program: %0d ADDI init + %0d R-type", src_regs.size(), n);
  endtask

  task automatic build_i_test();
    itype_instr instr;
    int n;
    n = $urandom_range(5, 20);
    for (int i = 0; i < n; i++) begin
      instr        = new();
      instr.opcode = I_TYPE;
      void'(instr.do_randomize());
      instr.imm    = 12'($urandom_range(0, 31));
      program_mem[i] = instr.encode();
    end
    program_size = n;
    num_cycles   = n + 5;
    $display("[TOP] i_test program: %0d I-type", n);
  endtask

  task automatic build_s_test();
    stype_instr  s_instrs [$];
    itype_instr  init_instr;
    stype_instr  s;
    logic [4:0]  src_regs [$];
    int          n;
    int          idx;
    n = $urandom_range(5, 20);
    for (int i = 0; i < n; i++) begin
      s        = new();
      s.opcode = S_TYPE;
      void'(s.do_randomize());
      s.rs1 = 5'b0;
      s.imm = 12'($urandom_range(0, 15) * 4);
      s_instrs.push_back(s);
      push_unique_reg(src_regs, s.rs2);
    end
    idx = 0;
    foreach (src_regs[i]) begin
      init_instr        = new();
      init_instr.opcode = I_TYPE;
      init_instr.funct3 = 3'b000;
      init_instr.rs1    = 5'b0;
      init_instr.rd     = src_regs[i];
      init_instr.imm    = 12'($urandom_range(1, 31));
      program_mem[idx]  = init_instr.encode();
      idx++;
    end
    foreach (s_instrs[i]) begin
      program_mem[idx] = s_instrs[i].encode();
      idx++;
    end
    program_size = idx;
    num_cycles   = idx + 5;
    $display("[TOP] s_test program: %0d ADDI init + %0d S-type", src_regs.size(), n);
  endtask

  // ---------- Scoreboard tick (called every posedge while !reset) ----------
  task automatic scoreboard_tick();
    logic [4:0]  predicted_rd;
    logic [31:0] predicted_val;
    logic        predicted_reg_write;
    logic        predicted_mem_write;
    logic [31:0] predicted_mem_addr;
    logic [31:0] predicted_mem_wdata;

    if (if0.pc !== ref_model.pc) begin
      $display("[SCB] PC mismatch: model=%0h DUT=%0h", ref_model.pc, if0.pc);
      fail_count++;
      return;
    end

    predicted_reg_write = ref_model.step(if0.instr_exec, predicted_rd, predicted_val,
                                         predicted_mem_write, predicted_mem_addr,
                                         predicted_mem_wdata);

    if (if0.pc_next !== ref_model.pc) begin
      $display("[SCB] Next-PC mismatch at PC=%0h instr=%0h: model=%0h DUT=%0h",
               if0.pc, if0.instr_exec, ref_model.pc, if0.pc_next);
      fail_count++;
    end

    if (if0.reg_write !== predicted_reg_write) begin
      $display("[SCB] reg_write mismatch at PC=%0h instr=%0h: model=%0b DUT=%0b",
               if0.pc, if0.instr_exec, predicted_reg_write, if0.reg_write);
      fail_count++;
      return;
    end

    if (if0.reg_write) begin
      if (predicted_rd !== if0.rd || predicted_val !== if0.wr_data_rf) begin
        $display("[SCB] RF mismatch at PC=%0h: expected rd=x%0d val=%0h  got rd=x%0d val=%0h",
                 if0.pc, predicted_rd, predicted_val, if0.rd, if0.wr_data_rf);
        fail_count++;
      end else begin
        pass_count++;
      end
    end

    if (predicted_mem_write) begin
      if (if0.mem_addr !== predicted_mem_addr || if0.mem_wdata !== predicted_mem_wdata) begin
        $display("[SCB] Store mismatch at PC=%0h: expected addr=%0h data=%0h  got addr=%0h data=%0h",
                 if0.pc, predicted_mem_addr, predicted_mem_wdata,
                 if0.mem_addr, if0.mem_wdata);
        fail_count++;
      end else begin
        pass_count++;
      end
    end
  endtask

  // ---------- Main flow ----------
  initial begin
    string test_name;

    pass_count = 0;
    fail_count = 0;
    inst_load_en   = 1'b0;
    inst_load_addr = '0;
    inst_load_data = '0;
    reset          = 1'b1;

    if (!$value$plusargs("TEST=%s", test_name)) test_name = "r_test";
    $display("[TOP] Running test: %s", test_name);

    // Initialize program memory area to NOPs
    for (int i = 0; i < 64; i++) program_mem[i] = 32'h00000013;

    case (test_name)
      "r_test": build_r_test();
      "i_test": build_i_test();
      "s_test": build_s_test();
      default: begin
        $display("[TOP] Unknown test '%s', defaulting to r_test", test_name);
        build_r_test();
      end
    endcase

    // Hold reset for a couple of cycles before loading
    @(posedge clk);
    @(posedge clk);

    // Load program through the load port (one entry per cycle)
    for (int i = 0; i < 64; i++) begin
      @(negedge clk);
      inst_load_en   = 1'b1;
      inst_load_addr = i[5:0];
      inst_load_data = program_mem[i];
    end
    @(negedge clk);
    inst_load_en   = 1'b0;
    inst_load_addr = '0;
    inst_load_data = '0;

    // Drop reset between edges so PC is held at 0 going into the first sample
    @(negedge clk);
    reset = 1'b0;

    ref_model = new();
    ref_model.reset();

    // Sample current state, then advance one posedge — keeps DUT and model in lockstep
    for (int c = 0; c < num_cycles; c++) begin
      scoreboard_tick();
      @(posedge clk);
      #1;
    end

    $display("[TOP] Scoreboard results: %0d passed, %0d failed", pass_count, fail_count);
    if (fail_count > 0)
      $display("[TOP] TEST FAILED");
    else
      $display("[TOP] TEST PASSED");

    $finish;
  end

endmodule
