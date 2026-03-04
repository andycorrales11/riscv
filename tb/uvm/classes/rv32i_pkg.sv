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

endpackage