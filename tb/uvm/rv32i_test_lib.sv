class base_test extends uvm_test;

  `uvm_component_utils(base_test)

  function new(string name = "base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  rv32i_tb tb;

  virtual function build_phase(uvm_phase phase);
    super.build_phase(phase);
    tb = rv32i_tb::type_id::create("tb", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction

endclass

class r_test extends base_test;
  `uvm_component_utils(r_test)

  function new(string name = "r_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  rv32i_sequencer seqr;                               
  rv32i_r_seq r_seq;

  function void build_phase(uvm_phase phase);
    r_seq = rv32i_r_seq::type_id::create("r_seq", this); //create sequence
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    seqr = tb.rv32i.agent.sequencer;                    // connect sequencer to uvc sequencer
  endfunction

  task run_phase(uvm_phase phase);       
    r_seq.start(seqr);                                   // start sequence on sequencer
  endtask

endclass

