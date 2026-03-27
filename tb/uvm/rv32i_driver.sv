class rv32i_driver extends uvm_driver #(rv32i_seq_item);
  `uvm_component_utils(rv32i_driver)

  virtual rv32i_if vif;

  function new(string name = "rv32i_driver", uvm_component parent);
    super.new(name, parent);
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
    `uvm_info(get_type_name(), $sformatf("Sending instruction: 0x%08x", item.encode()), UVM_LOW)
    
  endtask
endclass