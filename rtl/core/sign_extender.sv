`timescale 1ns/1ps

module sign_extender (
  input  logic [31:0] instruction,
  output logic [31:0] imm_ex
);

  always_comb begin
    case (instruction[6:0])
      7'b0010011: // I-type 
        imm_ex = {{20{instruction[31]}}, instruction[31:20]};
      7'b0100011: // S-type
        imm_ex = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
      default:
        imm_ex = 32'h0;
    endcase
  end

endmodule