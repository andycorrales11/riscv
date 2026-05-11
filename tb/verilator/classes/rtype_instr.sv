class rtype_instr extends rv32i_instr;
  logic [4:0] rs1;
  logic [4:0] rs2;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic [4:0] rd;

  function new();
    super.new();
  endfunction

  // Manual replacement for randomize() with constraints. Returns 1 on success.
  function bit do_randomize();
    logic [2:0] f3_choices [7] = '{3'b000, 3'b001, 3'b010, 3'b100, 3'b101, 3'b110, 3'b111};
    rs1    = $urandom_range(0, 31);
    rs2    = $urandom_range(0, 31);
    rd     = $urandom_range(1, 31); // rd != 0
    funct3 = f3_choices[$urandom_range(0, 6)];
    // funct7 == 0100000 only valid for funct3 == 000 (SUB) or 101 (SRA)
    if (funct3 == 3'b000 || funct3 == 3'b101)
      funct7 = ($urandom_range(0, 1) == 1) ? 7'b0100000 : 7'b0000000;
    else
      funct7 = 7'b0000000;
    return 1'b1;
  endfunction

  function logic [31:0] encode();
    return {funct7, rs2, rs1, funct3, rd, opcode};
  endfunction
endclass
