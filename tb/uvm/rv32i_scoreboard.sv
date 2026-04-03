class rv32i_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(rv32i_scoreboard)

  `uvm_analysis_imp_decl(_driver)
  `uvm_analysis_imp_decl(_monitor)

  `uvm_analysis_imp_driver #(rv32i_seq_item,     rv32i_scoreboard) driver_imp;
  `uvm_analysis_imp_monitor #(rv32i_monitor_txn, rv32i_scoreboard) monitor_imp;
  rv32i_ref_model ref_model;


  function new (string name, uvm_component parent);
    super.new(name, parent);
    imp = new("imp", this);
  endfunction

  function void write_driver(input rv32i_seq_item item);
    ref_model.load_program(item);
  endfunction

  function void write_monitor(input rv32i_monitor_txn txn);
    logic [4:0] predicted_rd;
    logic [31:0] predicted_val;

    if (txn.reset) return;

    ref_model.step(predicted_rd, predicted_val);

    if (txn.reg_write) begin
      if (predicted_rd !== txn.rd || predicted_val !== txn.wr_data) begin
        `uvm_error(get_type_name(), $sformatf("Mismatch at PC = %h: expected rd = %0d, wr_data = %h; got rd = %0d, wr_data = %h",
          txn.pc, predicted_rd, predicted_val, txn.rd, txn.wr_data))
      end else begin
        `uvm_info(get_type_name(), $sformatf("Match at PC = %h: rd = %0d, wr_data = %h", txn.pc, txn.rd, txn.wr_data), UVM_LOW)
      end
    end
  endfunction

endclass