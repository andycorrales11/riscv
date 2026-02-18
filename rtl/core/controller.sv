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
        branch = 0;
        mem_read = 0;
        alu_src = 0;
        mem_write = 0;
        mem_to_reg = 0;
        reg_write = 1;
      end
      7'b00?0011: begin // I-type load
        branch = 0;
        mem_read = 1;
        alu_src = 1;
        mem_write = 0;
        mem_to_reg = (opcode == 7'b0000011) ? 1 : 0; // Load instructions set mem_to_reg to 1
        reg_write = 1;
      end
      default: begin
        branch = 0;
        mem_read = 0;
        alu_src = 0;
        mem_write = 0;
        mem_to_reg = 0;
        reg_write = 0;
      end
    endcase
  end

endmodule