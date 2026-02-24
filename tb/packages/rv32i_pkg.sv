package rv32i_pkg;
  //op codes
  parameter logic [6:0] R_TYPE = 7'b0110011;
  parameter logic [6:0] I_TYPE = 7'b0010011;
  parameter logic [6:0] S_TYPE = 7'b0100011;

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
    return {imm[11:5], rs2, rs1, funct3, imm[4:0], S_TYPE};
  endfunction

endpackage