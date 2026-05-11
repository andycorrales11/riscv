class jtype_instr extends rv32i_instr;
  logic [20:0] imm; // 21-bit (LSB always 0)
  logic [4:0]  rd;

  function new();
    super.new();
  endfunction

  function bit do_randomize();
    imm = {$urandom_range(0, (1<<20)-1), 1'b0};
    rd  = $urandom_range(1, 31);
    return 1'b1;
  endfunction

  function logic [31:0] encode();
    return {imm[20], imm[10:1], imm[11], imm[19:12], rd, opcode};
  endfunction
endclass
