class rv32i_monitor extends uvm_monitor;
  `uvm_component_utils(rv32i_monitor)

  virtual rv32i_if vif;

  uvm_analysis_port #(rv32i_monitor_txn) ap;

  function new(string name = "rv32i_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db #(virtual rv32i_if)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Failed to get virtual interface from config_db")
  endfunction

  virtual task run_phase(uvm_phase phase);
    rv32i_monitor_txn txn;
    `uvm_info(get_type_name(), "Starting run phase", UVM_LOW)
    forever begin
      @(posedge vif.clk);
      txn           = rv32i_monitor_txn::type_id::create("txn");
      txn.pc        = vif.pc;
      txn.instr     = vif.instr_exec;
      txn.reg_write = vif.reg_write;
      txn.rd        = vif.rd;
      txn.wr_data   = vif.wr_data_rf;
      txn.reset     = vif.reset;
      ap.write(txn);
    end
  endtask

endclass
