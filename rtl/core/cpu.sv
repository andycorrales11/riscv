`timescale 1ns/1ps

module cpu (
  input logic clk, 
  input logic reset
);

  logic [31:0] instruction_a,
               instruction_out,
               read_data1,
               read_data2,
               num1,
               num2,
               data_memory_read_data,
               alu_result,
               write_data,
               imm_ex,
               pc_next,
               pc_plus4;

  logic        branch, 
               mem_read, 
               mem_write,
               reg_write,
               branch_taken,
               jal,
               jalr,
               link;

  logic [2:0]  alu_src;
  logic [1:0]  result_src;

  logic [6:0]  opcode;
  logic [4:0]  rd, rs1, rs2;
  logic [2:0]  funct3;
  logic [6:0]  funct7;
  
  assign pc_plus4 = instruction_a + 4;
  assign pc_next  = (jal) ? (instruction_a + imm_ex) :                    // jal
                    (jalr) ? ((read_data1 + imm_ex) & ~32'b1) :           // jalr
                    (branch && branch_taken) ? (instruction_a + imm_ex) : // branch_taken
                     pc_plus4;                                            // sequential execution

   program_counter program_counter(
    .clk(clk),
    .reset(reset),
    .pc_in(pc_next),
    .pc_out(instruction_a)
  );

  instruction_memory instruction_memory(
    .reset(reset),
    .address(instruction_a),
    .instruction(instruction_out)
  );

  instruction_decoder instruction_decoder(
    .instruction(instruction_out),
    .opcode(opcode),
    .rd(rd),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .funct7(funct7)
  );

  register_file register_file(
    .clk(clk),
    .reset(reset),
    .reg_write(reg_write),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
  );

  controller controller(
    .opcode(opcode),
    .branch(branch),
    .mem_read(mem_read),
    .alu_src(alu_src),
    .mem_write(mem_write),
    .result_src(result_src),
    .jal(jal),
    .jalr(jalr),
    .reg_write(reg_write)
  );

  alu alu(
    .opcode({funct7, funct3}),
    .num1(num1),
    .num2(num2),
    .store_op(mem_write),
    .result(alu_result),
    .zero()
  );

  branch_unit branch_unit(
    .val1(read_data1),
    .val2(read_data2),
    .funct3(funct3),
    .branch_taken(branch_taken)
  );

  sign_extender sign_extender(
    .instruction(instruction_out),
    .imm_ex(imm_ex)
  );

  mux3 src1_mux( // source of num1 is either read_data1, PC (for AUIPC), or zero (for LUI)
    .sel(alu_src[2:1]),
    .in0(read_data1),
    .in1(instruction_a), 
    .in2(32'b0), 
    .out(num1)
  );

  mux2 src2_mux( // source of num2 is either read_data2 or imm_ex, depending on the instruction type
    .sel(alu_src[0]),
    .in0(read_data2),
    .in1(imm_ex),
    .out(num2)
  );

  data_memory data_memory(
    .clk(clk),
    .mem_write(mem_write),
    .mem_read(mem_read),
    .reset(reset),
    .width(funct3),
    .address(alu_result),
    .write_data(read_data2),
    .read_data(data_memory_read_data)
  );

  mux3 data_mux( // source of data to write back to register file is either alu_result, data_memory_read_data, or PC + 4 (for JAL)
    .sel(result_src),
    .in0(alu_result),
    .in1(data_memory_read_data),
    .in2(pc_plus4), // for JAL
    .out(write_data)
  );


endmodule
