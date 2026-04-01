class rv32i_driver extends uvm_driver #(rv32i_seq_item);
  `uvm_component_utils(rv32i_driver)

  virtual rv32i_if vif;

  localparam string INST_MEM = "top.inst_cpu.instruction_memory.memory";
  localparam int    INST_MEM_S = 64;
  localparam logic [31:0] NOP = 32'h00000013; // ADDI x0, x0, 0

  function new(string name = "rv32i_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual rv32i_if)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Failed to get virtual interface from config_db")
  endfunction

  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Starting run phase", UVM_LOW)
    forever begin
      seq_item_port.get_next_item(req);
      send_to_dut(req);
      seq_item_port.item_done();
    end
  endtask

  virtual task send_to_dut(rv32i_seq_item item);
    string path;
    logic [31:0] encoded;

    vif.reset = 1'b1;
    repeat (2) @(posedge vif.clk);

    // Backdoor Load
    for (int i = 0; i < INST_MEM_S; i++) begin
      if (i < item.instrs.size()) begin
        encoded = item.instrs[i].encode();
      end else begin
        encoded = NOP;
      end
      path = $sformatf("%s[%0d]", INST_MEM, i);
      if (!uvm_hdl_deposit(path, encoded))
        `uvm_error(get_type_name(),
                   $sformatf("uvm_hdl_deposit failed for %s", path))
    end

    @(posedge vif.clk);
    vif.reset = 1'b0;

    repeat (item.num_cycles) @(posedge vif.clk);

    vif.endOfTest = 1'b1;
    @(posedge vif.clk);
    vif.endOfTest = 1'b0;
  endtask

endclass
