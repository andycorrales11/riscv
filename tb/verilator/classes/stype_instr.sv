class stype_instr extends rv32i_instr;
  logic [4:0]  rs1;
  logic [4:0]  rs2;
  logic [2:0]  funct3;
  logic [11:0] imm;

  function new();
    super.new();
  endfunction

  function bit do_randomize();
    logic [2:0] f3_choices [3] = '{3'b000, 3'b001, 3'b010};
    rs1    = $urandom_range(0, 31);
    rs2    = $urandom_range(1, 31); // sequence forces rs2 != 0
    funct3 = f3_choices[$urandom_range(0, 2)];
    imm    = $urandom_range(0, 4095);
    return 1'b1;
  endfunction

  function logic [31:0] encode();
    return {imm[11:5], rs2, rs1, funct3, imm[4:0], opcode};
  endfunction
endclass
