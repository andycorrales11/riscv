class rv32i_monitor_txn extends uvm_sequence_item;
  `uvm_object_utils(rv32i_monitor_txn)

  logic [31:0] pc;
  logic [31:0] instr;
  logic [4:0]  rd;
  logic [31:0] wr_data;
  logic        reg_write;

  `uvm_object_utils_begin(rv32i_monitor_txn)
    `uvm_field_int(pc,        UVM_ALL_ON)
    `uvm_field_int(instr,     UVM_ALL_ON)
    `uvm_field_int(rd,        UVM_ALL_ON)
    `uvm_field_int(wr_data,   UVM_ALL_ON)
    `uvm_field_int(reg_write, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "rv32i_monitor_txn");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf("pc=%0h instr=%0h rd=x%0d wr_data=%0h reg_write=%0b",
                     pc, instr, rd, wr_data, reg_write);
  endfunction

endclass
