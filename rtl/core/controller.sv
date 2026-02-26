`timescale 1ns/1ps

module controller (
  input logic [6:0] opcode,

  output logic       branch, 
  output logic       mem_read, 
  output logic       mem_write,
  output logic       reg_write,
  output logic [2:0] alu_src,    // alu_src[0] -> num2 = 0: reg, 1: imm; (maybe split this later)
                                 // alu_src[2:1] -> num1 = 00: read_data1, 01: PC (AUIPC), 10: zero (LUI))
  output logic [1:0] result_src, // result_src -> 00: alu_result, 01: data_memory_read_data, 10: PC + 4 (JAL)
  output logic       jal,
  output logic       jalr
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

endmodule