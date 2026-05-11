`timescale 1ns/1ps

module controller (
  input logic [6:0] opcode,
  input logic [2:0] funct3,
  input logic [6:0] funct7,

  output logic       branch,
  output logic       mem_read,
  output logic       mem_write,
  output logic       reg_write,
  output logic [2:0] alu_src,    // alu_src[0] -> num2 = 0: reg, 1: imm; (maybe split this later)
                                 // alu_src[2:1] -> num1 = 00: read_data1, 01: PC (AUIPC), 10: zero (LUI))
  output logic [1:0] result_src, // result_src -> 00: alu_result, 01: data_memory_read_data, 10: PC + 4 (JAL)
  output logic       jal,
  output logic       jalr,
  output logic [3:0] alu_op      // see alu.sv for encoding
);

  always_comb begin
    case (opcode)
      7'b0110011: begin // R-type
        branch     = 1'b0;
        mem_read   = 1'b0;
        alu_src    = 3'b000;
        mem_write  = 1'b0;
        result_src = 2'b00;
        reg_write  = 1'b1;
        jal        = 1'b0;
        jalr       = 1'b0;
      end
      7'b0010011: begin // I-type arithmetic
        branch     = 1'b0;
        mem_read   = 1'b0;
        alu_src    = 3'b001;
        mem_write  = 1'b0;
        result_src = 2'b00;
        reg_write  = 1'b1;
        jal        = 1'b0;
        jalr       = 1'b0;
      end
      7'b0000011: begin // I-type load 
        branch     = 1'b0;
        mem_read   = 1'b1;
        alu_src    = 3'b001;
        mem_write  = 1'b0;
        result_src = 2'b01;
        reg_write  = 1'b1;
        jal        = 1'b0;
        jalr       = 1'b0;
      end
      7'b0100011: begin // S-type 
        branch     = 1'b0;
        mem_read   = 1'b0;
        alu_src    = 1'b1;
        mem_write  = 1'b1;
        result_src = 2'b00;
        reg_write  = 1'b0;
        jal        = 1'b0;
        jalr       = 1'b0;
      end
      7'b1100011: begin // B-type
        branch     = 1'b1;
        mem_read   = 1'b0;
        alu_src    = 1'b0;
        mem_write  = 1'b0;
        result_src = 1'b0;
        reg_write  = 1'b0;
        jal        = 1'b0;
        jalr       = 1'b0;
      end
      7'b0110111: begin // U-type lui
        branch     = 1'b0;
        mem_read   = 1'b0;
        alu_src    = 3'b011; 
        mem_write  = 1'b0;
        result_src = 2'b00; 
        reg_write  = 1'b1;
        jal        = 1'b0;
        jalr       = 1'b0;
      end
      7'b0010111: begin // U-type auipc
        branch     = 1'b0;
        mem_read   = 1'b0;
        alu_src    = 3'b101; 
        mem_write  = 1'b0;
        result_src = 2'b00; 
        reg_write  = 1'b1;
        jal        = 1'b0;
        jalr       = 1'b0;
      end
      7'b1101111: begin // J-type jal 
        branch     = 1'b0;
        mem_read   = 1'b0;
        alu_src    = 3'b000;
        mem_write  = 1'b0;
        result_src = 2'b10;
        reg_write  = 1'b1;
        jal        = 1'b1;
        jalr       = 1'b0;
      end
      7'b1100111: begin // I-type jalr
        branch     = 1'b0;
        mem_read   = 1'b0;
        alu_src    = 3'b001;
        mem_write  = 1'b0;
        result_src = 2'b10;
        reg_write  = 1'b1;
        jal        = 1'b0;
        jalr       = 1'b1;
      end
      default: begin
        branch     = 1'b0;
        mem_read   = 1'b0;
        alu_src    = 3'b000;
        mem_write  = 1'b0;
        result_src = 2'b00;
        reg_write  = 1'b0;
        jal        = 1'b0;
        jalr       = 1'b0;
      end
    endcase
  end

  // ALU op decode. funct7 is only meaningful for R-type (and for SRLI/SRAI's
  // shift-type bit); for everything else funct7 is ignored so I-type immediates
  // can't leak in as a fake funct7.
  always_comb begin
    alu_op = 4'b0000; // default: ADD (covers loads, stores, branches, JAL, JALR address calc)
    case (opcode)
      7'b0110011: begin // R-type: full (funct7, funct3) decode
        case ({funct7, funct3})
          10'b0000000_000: alu_op = 4'b0000; // ADD
          10'b0100000_000: alu_op = 4'b0001; // SUB
          10'b0000000_001: alu_op = 4'b0010; // SLL
          10'b0000000_010: alu_op = 4'b0011; // SLT
          10'b0000000_100: alu_op = 4'b0100; // XOR
          10'b0000000_101: alu_op = 4'b0101; // SRL
          10'b0100000_101: alu_op = 4'b0110; // SRA
          10'b0000000_110: alu_op = 4'b0111; // OR
          10'b0000000_111: alu_op = 4'b1000; // AND
          default:         alu_op = 4'b0000;
        endcase
      end
      7'b0010011: begin // I-type arithmetic: funct3 only, except SRLI/SRAI use funct7[5]
        case (funct3)
          3'b000: alu_op = 4'b0000;                                   // ADDI
          3'b010: alu_op = 4'b0011;                                   // SLTI
          3'b100: alu_op = 4'b0100;                                   // XORI
          3'b110: alu_op = 4'b0111;                                   // ORI
          3'b111: alu_op = 4'b1000;                                   // ANDI
          3'b001: alu_op = 4'b0010;                                   // SLLI
          3'b101: alu_op = (funct7[5]) ? 4'b0110 : 4'b0101;           // SRAI : SRLI
          default: alu_op = 4'b0000;
        endcase
      end
      default: alu_op = 4'b0000; // loads/stores/branches/JAL/JALR/LUI/AUIPC: ADD
    endcase
  end

endmodule
