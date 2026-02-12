`timescale 1ns/1ps

module program_counter (
  input  logic        clk,
  input  logic        reset,
  input  logic [31:0] pc_in,
  output logic [31:0] pc_out
);

  always_ff @(posedge clk) begin
    if (reset) pc_out <= 32'h00000000;
    else pc_out <= pc_in;
  end

endmodule
