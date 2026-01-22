`timescale 1ns/1ps

module program_counter (
  input  wire        clk,
  input  wire        reset,
  input  wire [31:0] pc_in,
  output wire [31:0] pc_out
);

  always @(posedge clk) begin
    if (reset) pc_out <= 32'h00000000;
    else pc_out <= pc_in;
  end

endmodule
