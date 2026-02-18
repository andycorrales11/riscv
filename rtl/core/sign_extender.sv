`timescale 1ns/1ps

module sign_extender (
  input logic [11:0] imm_12,
  output logic [31:0] imm_ex
)
  assign imm_ex = {{20{imm_12[11]}}, imm_12};

endmodule