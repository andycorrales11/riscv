// Plain SV base instruction (no UVM, no rand)
class rv32i_instr;
  logic [6:0] opcode;

  function new();
  endfunction

  virtual function logic [31:0] encode();
    return {25'b0, opcode};
  endfunction
endclass
