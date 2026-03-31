// Helper function to push register indexes into a queue for ADDI initialization
function automatic void push_unique_reg(ref logic [4:0] q[$], input logic [4:0] r);
  if (r == 5'b0) return;
  foreach (q[i]) if (q[i] == r) return;
  q.push_back(r);
endfunction

class rv32i_r_seq extends uvm_sequence #(rv32i_seq_item);
  `uvm_object_utils(rv32i_r_seq)

  rand int unsigned num_instrs;
  constraint num_instrs_c { num_instrs inside {[5:20]}; }

  function new(string name = "rv32i_r_seq");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction

  virtual task body();
    rtype_instr  r_instrs[];
    itype_instr  init_instr;
    logic [4:0]  src_regs[$];
    int          preamble_size;

    // Randomize R-type Instructions
    r_instrs = new[num_instrs];
    for (int i = 0; i < num_instrs; i++) begin
      r_instrs[i]        = rtype_instr::type_id::create($sformatf("r_%0d", i));
      r_instrs[i].opcode = R_TYPE;
      if (!r_instrs[i].randomize() with { rd != 5'b0; })
        `uvm_error(get_type_name(), "Randomization failed for rtype_instr")
    end

    // Collect registers used in order to initialize them
    foreach (r_instrs[i]) begin
      push_unique_reg(src_regs, r_instrs[i].rs1);
      push_unique_reg(src_regs, r_instrs[i].rs2);
    end

    // Create program from ADDI initialization + R-type instructions
    preamble_size = src_regs.size();
    req = rv32i_seq_item::type_id::create("req");
    start_item(req);
    req.instrs     = new[preamble_size + num_instrs];
    req.num_cycles = preamble_size + num_instrs + 5;

    foreach (src_regs[i]) begin
      init_instr        = itype_instr::type_id::create($sformatf("init_%0d", i));
      init_instr.opcode = I_TYPE;
      init_instr.funct3 = 3'b000;       
      init_instr.rs1    = 5'b0;         
      init_instr.rd     = src_regs[i];
      init_instr.imm    = 12'($urandom_range(1, 255));
      req.instrs[i]     = init_instr;
    end

    for (int i = 0; i < num_instrs; i++)
      req.instrs[preamble_size + i] = r_instrs[i];

    `uvm_info(get_type_name(),
              $sformatf("Program: %0d ADDI init + %0d R-type", preamble_size, num_instrs),
              UVM_LOW)
    finish_item(req);
  endtask

endclass

class rv32i_i_seq extends uvm_sequence #(rv32i_seq_item);
  `uvm_object_utils(rv32i_i_seq)

  rand int unsigned num_instrs;
  constraint num_instrs_c { num_instrs inside {[5:20]}; }

  function new(string name = "rv32i_i_seq");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction

  virtual task body();
    itype_instr instr;
    req = rv32i_seq_item::type_id::create("req");
    start_item(req);
    req.instrs     = new[num_instrs];
    req.num_cycles = num_instrs + 5;
    for (int i = 0; i < num_instrs; i++) begin
      instr        = itype_instr::type_id::create($sformatf("instr_%0d", i));
      instr.opcode = I_TYPE;
      if (!instr.randomize() with { rd != 5'b0; })
        `uvm_error(get_type_name(), "Randomization failed for itype_instr")
      instr.imm = 12'($urandom_range(0, 31));
      req.instrs[i] = instr;
    end
    `uvm_info(get_type_name(), $sformatf("Executing %0d I-type instructions", num_instrs), UVM_LOW)
    finish_item(req);
  endtask

endclass

class rv32i_s_seq extends uvm_sequence #(rv32i_seq_item);
  `uvm_object_utils(rv32i_s_seq)

  rand int unsigned num_instrs;
  constraint num_instrs_c { num_instrs inside {[5:20]}; }

  function new(string name = "rv32i_s_seq");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction

  virtual task body();
    stype_instr  s_instrs[];
    itype_instr  init_instr;
    logic [4:0]  src_regs[$];
    int          preamble_size;

    // Randomize S-type Instructions
    s_instrs = new[num_instrs];
    for (int i = 0; i < num_instrs; i++) begin
      s_instrs[i]        = stype_instr::type_id::create($sformatf("s_%0d", i));
      s_instrs[i].opcode = S_TYPE;
      if (!s_instrs[i].randomize() with { rs2 != 5'b0; })
        `uvm_error(get_type_name(), "Randomization failed for stype_instr")
      s_instrs[i].rs1 = 5'b0;                               // base address = 0
      s_instrs[i].imm = 12'($urandom_range(0, 15) * 4);    // word-aligned, within data memory
    end

    // Collect source registers for initialization
    foreach (s_instrs[i])
      push_unique_reg(src_regs, s_instrs[i].rs2);

    // Create program from ADDI initialization + S-type instructions
    preamble_size = src_regs.size();
    req = rv32i_seq_item::type_id::create("req");
    start_item(req);
    req.instrs     = new[preamble_size + num_instrs];
    req.num_cycles = preamble_size + num_instrs + 5;

    foreach (src_regs[i]) begin
      init_instr        = itype_instr::type_id::create($sformatf("init_%0d", i));
      init_instr.opcode = I_TYPE;
      init_instr.funct3 = 3'b000;       
      init_instr.rs1    = 5'b0;
      init_instr.rd     = src_regs[i];
      init_instr.imm    = 12'($urandom_range(1, 255)); 
      req.instrs[i]     = init_instr;
    end

    for (int i = 0; i < num_instrs; i++)
      req.instrs[preamble_size + i] = s_instrs[i];

    `uvm_info(get_type_name(),
              $sformatf("Program: %0d ADDI init + %0d S-type", preamble_size, num_instrs),
              UVM_LOW)
    finish_item(req);
  endtask

endclass



