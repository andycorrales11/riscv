`timescale 1ns/1ps

module sign_extender (
  input  logic [31:0] instruction,
  output logic [31:0] imm_ex
);

  always_comb begin
    case (instruction[6:0])
      7'b0010011, // I-type arithmetic
      7'b0000011, // I-type load
      7'b1100111: // I-type jalr 
        imm_ex = {{20{instruction[31]}}, instruction[31:20]};
      7'b0100011: // S-type
        imm_ex = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
      7'b0100011: // B-type
        imm_ex = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
      7'b0110111, // U-type lui
      7'b0010111: // U-type auipc
        imm_ex = {instruction[31:12], 12'b0};
      7'b1101111: // J-type jal
        imm_ex = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
      default:
        imm_ex = 32'h0;
    endcase
  end

endmodule