class rv32i_ref_model extends uvm_object;
  `uvm_object_utils(rv32i_ref_model)

  logic [31:0] rf   [32];
  logic [31:0] dmem [64];
  logic [31:0] imem [64];
  logic [31:0] pc;

  function new(string name = "rv32i_ref_model");
    super.new(name);
    this.reset();
  endfunction

  function void reset();
    pc = 0;
    for (int i = 0; i < 32; i++) rf[i] = 0;
    for (int i = 0; i < 64; i++) begin
      dmem[i] = 0;
      imem[i] = 32'h00000013;
    end
  endfunction

  function void load_program(rv32i_seq_item item);
    for (int i = 0; i < item.instrs.size(); i++) imem[i] = item.instrs[i].encode();
  endfunction

  function int step(output logic [4:0] rd, output logic [31:0] wr_data);
    logic [31:0] instr;
    instr = imem[pc >> 2];

    case (instr[6:0])
      7'b0110011: begin // R-type
        logic [9:0] funct = {instr[31:25], instr[14:12]};
        logic [4:0] rs1 = instr[19:15];
        logic [4:0] rs2 = instr[24:20];
        rd  = instr[11:7];
        logic [31:0] num1 = rf[rs1];
        logic [31:0] num2 = rf[rs2];
        case (funct)
          10'b0000000000: rf[rd] = num1 + num2; // ADD
          10'b0100000000: rf[rd] = num1 - num2; // SUB
          10'b0000000001: rf[rd] = num1 << num2[4:0]; // SLL
          10'b0000000010: rf[rd] = ($signed(num1) < $signed(num2)) ? 32'h1 : 32'h0; // SLT
          // 10'b0000000011: rf[rd] = SLTU - (NOT IMPLEMENTED)
          10'b0000000100: rf[rd] = num1 ^ num2; // XOR
          10'b0000000101: rf[rd] = num1 >> num2[4:0]; // SRL
          10'b0100000101: rf[rd] = $signed(num1) >>> num2[4:0]; // SRA
          10'b0000000110: rf[rd] = num1 | num2; // OR
          10'b0000000111: rf[rd] = num1 & num2; // AND
          default: begin
            $display("Unknown R-type instruction at PC = %h", pc);
          end
        endcase

        pc += 4;
        wr_data = 0;
        return 0;
      end
      7'b0010011: begin // I-type
        logic [2:0] funct3 = instr[14:12];
        logic [4:0] rs1 = instr[19:15];
        rd  = instr[11:7];
        logic [31:0] num1 = rf[rs1];
        logic [31:0] imm = {{20{instr[31]}}, instr[31:20]};
        case (funct3)
          3'b000: rf[rd] = num1 + imm; // ADDI
          3'b010: rf[rd] = ($signed(num1) < $signed(imm)) ? 32'h1 : 32'h0; // SLTI
          3'b100: rf[rd] = num1 ^ imm; // XORI
          3'b110: rf[rd] = num1 | imm; // ORI
          3'b111: rf[rd] = num1 & imm; // ANDI
          3'b001: rf[rd] = num1 << imm[4:0]; // SLLI
          3'b101: begin
            if (imm[11:5] == 7'b0000000) rf[rd] = num1 >> imm[4:0]; // SRLI
            else if (imm[11:5] == 7'b0100000) rf[rd] = $signed(num1) >>> imm[4:0]; // SRAI
            else begin
              $display("Unknown I-type shift instruction at PC = %h", pc);     
            end
          end
        endcase 
        pc += 4;
        wr_data = 0;
        return 0;
      end
      7'b0000011: begin // I-Type Load
        
      end
      7'b0100011: begin // S-Type
        
      end
      7'b1100011: begin // B-Type
        
      end
      7'b1101111: begin //JAL

      end
      7'b1100111: begin // JALR

      end
      7'b0110111: begin // LUI

      end
      7'b0010111: begin //AUIPC

      end
      default: begin
        $display("Unknown instruction at PC = %h", pc);
      end
    endcase
    rd = 5'b0;
    wr_data = 32'b0;
    return 0; 
  endfunction

endclass