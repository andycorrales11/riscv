class rv32i_agent extends uvm_agent;
  
  `uvm_component_utils_begin(rv32i_agent)
    `uvm_field_enum(uvm_active_passive_enum, active_passive, UVM_ALL_ON)
  `uvm_component_utils_end

  rv32i_sequencer sequencer;
  rv32i_driver driver;

  function new(string name = "rv32i_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    if (is_active == UVM_ACTIVE) begin
      sequencer = rv32i_sequencer::type_id::create("sequencer", this);
      driver = rv32i_driver::type_id::create("driver", this);
    end
  endfunction

  virtual function void connect_phase (uvm_phase phase);
    if (is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction

endclass