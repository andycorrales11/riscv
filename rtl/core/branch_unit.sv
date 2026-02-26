module branch_unit ( // Dont know if its the best idea to split from ALU
  input  logic [31:0] val1,
  input  logic [31:0] val2,
  input  logic [2:0]  funct3,
  output logic        branch_taken
);
  always_comb begin
    case (funct3)
      3'b000: branch_taken = (val1 == val2);                   // BEQ
      3'b001: branch_taken = (val1 != val2);                   // BNE
      3'b100: branch_taken = ($signed(val1) < $signed(val2));  // BLT
      3'b101: branch_taken = ($signed(val1) >= $signed(val2)); // BGE
      3'b110: branch_taken = (val1 < val2);                    // BLTU
      3'b111: branch_taken = (val1 >= val2);                   // BGEU
      default: branch_taken = 1'b0;
    endcase
  end
endmodule