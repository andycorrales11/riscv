class rv32i_driver extends uvm_driver #(rv32i_seq_item);
  `uvm_component_utils(rv32i_driver)

  virtual rv32i_if vif;

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
    logic [31:0] encoded;

    vif.reset   = 1'b1;
    vif.load_en = 1'b0;
    repeat (2) @(posedge vif.clk);

    // Backdoor load: drive one word per clock; top.sv writes the instruction
    // memory on posedge clk. Values are set on negedge for clean setup.
    for (int i = 0; i < INST_MEM_S; i++) begin
      encoded = (i < item.instrs.size()) ? item.instrs[i].encode() : NOP;
      @(negedge vif.clk);
      vif.load_en   = 1'b1;
      vif.load_addr = i[5:0];
      vif.load_data = encoded;
    end
    @(negedge vif.clk);
    vif.load_en = 1'b0;

    // Deassert reset just AFTER the posedge so the program_counter latches
    // reset=1 at that edge (PC stays 0). This gives one clean reset=0/pc=0
    // cycle that the negedge monitor can observe before PC advances to 4.
    @(posedge vif.clk);
    #1 vif.reset = 1'b0;

    repeat (item.num_cycles) @(posedge vif.clk);

    vif.endOfTest = 1'b1;
    @(posedge vif.clk);
    vif.endOfTest = 1'b0;
  endtask

endclass
