`timescale 1ns/1ps

module controller (
  input logic [6:0] opcode,

  output logic branch, 
  output logic mem_read, 
  output logic alu_src, 
  output logic mem_write, 
  output logic mem_to_reg, 
  output logic reg_write
);

  always_comb begin
    case (opcode)
      7'b0110011: begin // R-type
        branch     = 1'b0;
        mem_read   = 1'b0;
        alu_src    = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        reg_write  = 1'b1;
      end
      7'b0010011: begin // I-type arithmetic
        branch     = 1'b0;
        mem_read   = 1'b0;
        alu_src    = 1'b1;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        reg_write  = 1'b1;
      end
      7'b0000011: begin // I-type load 
        branch     = 1'b0;
        mem_read   = 1'b1;
        alu_src    = 1'b1;
        mem_write  = 1'b0;
        mem_to_reg = 1'b1;
        reg_write  = 1'b1;
      end
      7'b0100011: begin // S-type 
        branch     = 1'b0;
        mem_read   = 1'b0;
        alu_src    = 1'b1;
        mem_write  = 1'b1;
        mem_to_reg = 1'b0;
        reg_write  = 1'b0;
      end
      default: begin
        branch     = 1'b0;
        mem_read   = 1'b0;
        alu_src    = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        reg_write  = 1'b0;
      end
    endcase
  end

endmodule