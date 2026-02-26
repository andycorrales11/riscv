package rv32i_pkg;
  //op codes
  parameter logic [6:0] R_TYPE = 7'b0110011;
  parameter logic [6:0] I_TYPE = 7'b0010011;
  parameter logic [6:0] S_TYPE = 7'b0100011;
  parameter logic [6:0] B_TYPE = 7'b1100011;
  parameter logic [6:0] LUI    = 7'b0110111;
  parameter logic [6:0] AUIPC  = 7'b0010111;
  parameter logic [6:0] JAL    = 7'b1101111;
  parameter logic [6:0] JALR   = 7'b1100111;

  //funct3
  parameter logic [2:0] F3_ADD_SUB = 3'b000;
  parameter logic [2:0] F3_SLL     = 3'b001;
  parameter logic [2:0] F3_SLT     = 3'b010;
  parameter logic [2:0] F3_XOR     = 3'b100;
  parameter logic [2:0] F3_SRL_SRA = 3'b101;
  parameter logic [2:0] F3_OR      = 3'b110;
  parameter logic [2:0] F3_AND     = 3'b111;

  parameter logic [2:0] F3_SB = 3'b000;
  parameter logic [2:0] F3_SH = 3'b001;
  parameter logic [2:0] F3_SW = 3'b010;

  parameter logic [2:0] F3_BEQ  = 3'b000;
  parameter logic [2:0] F3_BNE  = 3'b001;
  parameter logic [2:0] F3_BLT  = 3'b100;
  parameter logic [2:0] F3_BGE  = 3'b101;
  parameter logic [2:0] F3_BLTU = 3'b110;
  parameter logic [2:0] F3_BGEU = 3'b111;

  //funct7
  parameter logic [6:0] F7_DEFAULT = 7'b0000000; // ADD, SLL, SLT, XOR, SRL, OR, AND
  parameter logic [6:0] F7_ALT     = 7'b0100000; // SUB, SRA

  function automatic logic [31:0] encode_r_type(
    input logic [6:0] funct7,
    input logic [4:0] rs2, 
    input logic [4:0] rs1, 
    input logic [2:0] funct3, 
    input logic [4:0] rd
  );
    $display("Encoding R-Type instruction with funct7=0x%0h, rs2=%0d, rs1=%0d, funct3=%0b, rd=%0d", funct7, rs2, rs1, funct3, rd);
    return {funct7, rs2, rs1, funct3, rd, R_TYPE};
  endfunction

  function automatic logic [31:0] encode_i_type(
    input logic [11:0] imm, 
    input logic [4:0] rs1, 
    input logic [2:0] funct3, 
    input logic [4:0] rd
  );
    $display("Encoding I-Type instruction with imm=0x%0h, rs1=%0d, funct3=%0b, rd=%0d", imm, rs1, funct3, rd);
    return {imm, rs1, funct3, rd, I_TYPE};
  endfunction

  function automatic logic [31:0] encode_s_type(
    input logic [11:0] imm,
    input logic [4:0]  rs2,
    input logic [4:0]  rs1,
    input logic [2:0]  funct3
  );
    $display("Encoding S-Type instruction with imm[11:5]=0x%0h, rs2=%0d, rs1=%0d, funct3=%0b, imm[4:0]=0x%0h", imm[11:5], rs2, rs1, funct3, imm[4:0]);
    return {imm[11:5], rs2, rs1, funct3, imm[4:0], S_TYPE};
  endfunction

  function automatic logic [31:0] encode_b_type(
    input logic [12:0] imm,
    input logic [4:0]  rs2,
    input logic [4:0]  rs1,
    input logic [2:0]  funct3
  );
    $display("Encoding B-Type instruction with imm[12]=%b, imm[10:5]=0x%0h, rs2=%0d, rs1=%0d, funct3=%0b, imm[4:1]=0x%0h, imm[11]=%b", imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11]);
    return {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], B_TYPE};
  endfunction

  function automatic logic [31:0] encode_lui(
    input logic [19:0] imm,
    input logic [4:0]  rd
  );
    $display("Encoding LUI instruction with imm=0x%0h, rd=%0d", imm, rd);
    return {imm, rd, LUI};
  endfunction

  function automatic logic [31:0] encode_auipc(
    input logic [19:0] imm,
    input logic [4:0]  rd
  );
    $display("Encoding AUIPC instruction with imm=0x%0h, rd=%0d", imm, rd);
    return {imm, rd, AUIPC};
  endfunction

  function automatic logic [31:0] encode_jal(
    input logic [20:0] imm,
    input logic [4:0]  rd
  );
    $display("Encoding J-Type instruction with imm[20]=%b, imm[10:1]=0x%0h, rd=%0d, imm[19:12]=0x%0h", imm[20], imm[10:1], rd, imm[19:12]);
    return {imm[20], imm[10:1], rd, JAL};
  endfunction

  function automatic logic [31:0] encode_jalr(
    input logic [11:0] imm,
    input logic [4:0]  rs1,
    input logic [2:0]  funct3,
    input logic [4:0]  rd
  );
    $display("Encoding I-Type JALR instruction with imm=0x%0h, rs1=%0d, funct3=%0b, rd=%0d", imm, rs1, funct3, rd);
    return {imm, rs1, funct3, rd, JALR};
  endfunction

endpackage