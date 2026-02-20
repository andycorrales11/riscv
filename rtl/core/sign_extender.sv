`timescale 1ns/1ps

module sign_extender (
  input logic [6:0] funct7,
  input logic [4:0] rs2,
  input logic [4:0]  rd,
  input logic [6:0]   opcode,
  output logic [31:0] imm_ex
);

  always_comb begin
    case (opcode)
      7'b0010011: // I-type 
        imm_ex = {{20{funct7[6]}}, funct7[6:0], rs2};
      7'b0100011: // S-type
        imm_ex = {{20{funct7[6]}}, funct7[6:0], rd};
      default:
        imm_ex = 32'h0;
    endcase
  end

endmodule