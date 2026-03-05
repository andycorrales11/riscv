class rv32i_driver extends uvm_driver #(rv32i_seq_item);
  `uvm_component_utils(rv32i_driver)

  function new(string name = "rv32i_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      send_to_dut(req);
      seq_item_port.item_done();
    end
  endtask

  virtual task send_to_dut(rv32i_seq_item item);
    
  endtask
endclass