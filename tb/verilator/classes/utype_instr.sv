class utype_instr extends rv32i_instr;
  logic [19:0] imm;
  logic [4:0]  rd;

  function new();
    super.new();
  endfunction

  function bit do_randomize();
    imm = $urandom_range(0, (1<<20)-1);
    rd  = $urandom_range(1, 31);
    return 1'b1;
  endfunction

  function logic [31:0] encode();
    return {imm, rd, opcode};
  endfunction
endclass
