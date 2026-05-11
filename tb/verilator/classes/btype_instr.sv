class btype_instr extends rv32i_instr;
  logic [4:0]  rs1;
  logic [4:0]  rs2;
  logic [2:0]  funct3;
  logic [12:0] imm; // 13-bit signed (LSB always 0)

  function new();
    super.new();
  endfunction

  function bit do_randomize();
    logic [2:0] f3_choices [6] = '{3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111};
    rs1    = $urandom_range(0, 31);
    rs2    = $urandom_range(0, 31);
    funct3 = f3_choices[$urandom_range(0, 5)];
    imm    = {$urandom_range(0, 4095), 1'b0};
    return 1'b1;
  endfunction

  function logic [31:0] encode();
    return {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], opcode};
  endfunction
endclass
