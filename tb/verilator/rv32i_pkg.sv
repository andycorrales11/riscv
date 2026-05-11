package rv32i_pkg;

  `include "classes/rv32i_instr.sv"
  `include "classes/rtype_instr.sv"
  `include "classes/itype_instr.sv"
  `include "classes/stype_instr.sv"
  `include "classes/btype_instr.sv"
  `include "classes/utype_instr.sv"
  `include "classes/jtype_instr.sv"

  parameter logic [6:0] R_TYPE = 7'b0110011;
  parameter logic [6:0] I_TYPE = 7'b0010011;
  parameter logic [6:0] I_LOAD = 7'b0000011;
  parameter logic [6:0] S_TYPE = 7'b0100011;
  parameter logic [6:0] B_TYPE = 7'b1100011;
  parameter logic [6:0] LUI    = 7'b0110111;
  parameter logic [6:0] AUIPC  = 7'b0010111;
  parameter logic [6:0] JAL    = 7'b1101111;
  parameter logic [6:0] JALR   = 7'b1100111;

  // Push reg index into queue if not already present and not x0
  function automatic void push_unique_reg(ref logic [4:0] q[$], input logic [4:0] r);
    if (r == 5'b0) return;
    foreach (q[i]) if (q[i] == r) return;
    q.push_back(r);
  endfunction

endpackage
