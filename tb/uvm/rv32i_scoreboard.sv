class rv32i_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(rv32i_scoreboard)

  uvm_analysis_imp #(rv32i_monitor_txn, rv32i_scoreboard) imp;

  rv32i_ref_model ref_model;

  int pass_count;
  int fail_count;

  logic prev_reset;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp       = new("imp", this);
    ref_model = rv32i_ref_model::type_id::create("ref_model");
    prev_reset = 1'b1;
  endfunction

  function void write(input rv32i_monitor_txn txn);
    logic [4:0]  predicted_rd;
    logic [31:0] predicted_val;
    logic        predicted_reg_write;
    logic        predicted_mem_write;
    logic [31:0] predicted_mem_addr;
    logic [31:0] predicted_mem_wdata;

    // Falling edge of reset: CPU is about to start executing instructions, so reset the reference model
    if (prev_reset && !txn.reset)
      ref_model.reset();
    prev_reset = txn.reset;

    if (txn.reset) return;

    // Check PC: model and DUT must be at the same instruction
    if (txn.pc !== ref_model.pc) begin
      `uvm_error(get_type_name(),
        $sformatf("PC mismatch: model=%0h DUT=%0h", ref_model.pc, txn.pc))
      fail_count++;
      return;
    end

    // Step the model with the exact instruction the monitor observed
    predicted_reg_write = ref_model.step(txn.instr, predicted_rd, predicted_val,
                                         predicted_mem_write, predicted_mem_addr,
                                         predicted_mem_wdata);

    // Check next PC (catches wrong branch targets, JAL/JALR misses)
    if (txn.pc_next !== ref_model.pc) begin
      `uvm_error(get_type_name(),
        $sformatf("Next-PC mismatch at PC=%0h instr=%0h: model=%0h DUT=%0h",
                  txn.pc, txn.instr, ref_model.pc, txn.pc_next))
      fail_count++;
    end

    // Check if register was written to
    if (txn.reg_write !== predicted_reg_write) begin
      `uvm_error(get_type_name(),
        $sformatf("reg_write mismatch at PC=%0h instr=%0h: model=%0b DUT=%0b",
                  txn.pc, txn.instr, predicted_reg_write, txn.reg_write))
      fail_count++;
      return;
    end

    // Check destination register and value
    if (txn.reg_write) begin
      if (predicted_rd !== txn.rd || predicted_val !== txn.wr_data) begin
        `uvm_error(get_type_name(),
          $sformatf("RF write mismatch at PC=%0h: expected rd=x%0d val=%0h  got rd=x%0d val=%0h",
                    txn.pc, predicted_rd, predicted_val, txn.rd, txn.wr_data))
        fail_count++;
      end else begin
        `uvm_info(get_type_name(),
          $sformatf("PASS RF  PC=%0h rd=x%0d val=%0h", txn.pc, txn.rd, txn.wr_data),
          UVM_HIGH)
        pass_count++;
      end
    end

    // Check store address and data
    if (predicted_mem_write) begin
      if (txn.mem_addr !== predicted_mem_addr || txn.mem_wdata !== predicted_mem_wdata) begin
        `uvm_error(get_type_name(),
          $sformatf("Store mismatch at PC=%0h: expected addr=%0h data=%0h  got addr=%0h data=%0h",
                    txn.pc, predicted_mem_addr, predicted_mem_wdata,
                    txn.mem_addr, txn.mem_wdata))
        fail_count++;
      end else begin
        `uvm_info(get_type_name(),
          $sformatf("PASS ST  PC=%0h addr=%0h data=%0h", txn.pc, txn.mem_addr, txn.mem_wdata),
          UVM_HIGH)
        pass_count++;
      end
    end
  endfunction

  virtual function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(),
      $sformatf("Scoreboard results: %0d passed, %0d failed",
                pass_count, fail_count), UVM_NONE)
    if (fail_count > 0)
      `uvm_error(get_type_name(), "TEST FAILED")
    else
      `uvm_info(get_type_name(), "TEST PASSED", UVM_NONE)
  endfunction

endclass
