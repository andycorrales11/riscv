class itype_instr extends rv32i_instr;
  logic [4:0]  rs1;
  logic [2:0]  funct3;
  logic [11:0] imm;
  logic [4:0]  rd;

  function new();
    super.new();
  endfunction

  // Randomize for I-type arithmetic (opcode 0010011) by default.
  // For loads (0000011) restrict funct3; for jalr (1100111) force funct3=000.
  function bit do_randomize();
    rs1 = $urandom_range(0, 31);
    rd  = $urandom_range(1, 31);
    if (opcode == 7'b0000011) begin
      logic [2:0] load_f3 [5] = '{3'b000, 3'b001, 3'b010, 3'b100, 3'b101};
      funct3 = load_f3[$urandom_range(0, 4)];
    end else if (opcode == 7'b1100111) begin
      funct3 = 3'b000;
    end else begin
      // I-type arith: funct3 0..7 all valid
      funct3 = $urandom_range(0, 7);
    end
    imm = $urandom_range(0, 4095);
    return 1'b1;
  endfunction

  function logic [31:0] encode();
    return {imm, rs1, funct3, rd, opcode};
  endfunction
endclass
