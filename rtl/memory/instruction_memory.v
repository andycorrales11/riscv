`timescale 1ns/1ps

module instruction_memory(input wire reset, input wire [31:0] address, output wire [31:0] instruction);

	reg [31:0] memory [64:0];

	assign instruction = memory[read_address];

	always @(posedge reset) begin
		for (i = 0; i < 64; i = i + 1) begin
			memory[k] = 32'h00000000;
		end
	end
endmodule
