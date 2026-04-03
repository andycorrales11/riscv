class rv32i_ref_model extends uvm_object;
  `uvm_object_utils(rv32i_ref_model)

  logic [31:0] rf   [32];
  logic [31:0] dmem [64];
  logic [31:0] pc;

  function new(string name = "rv32i_ref_model");
    super.new(name);
    this.reset();
  endfunction

  function void reset();
    pc = 0;
    for (int i = 0; i < 32; i++) rf[i]   = 0;
    for (int i = 0; i < 64; i++) dmem[i] = 0;
  endfunction

  function logic step(input  logic [31:0] instr, output logic [4:0]  rd, output logic [31:0] wr_data);
    rd      = instr[11:7];
    wr_data = 32'b0;

    case (instr[6:0])
      // R-Type
      7'b0110011: begin
        logic [31:0] num1 = rf[instr[19:15]];
        logic [31:0] num2 = rf[instr[24:20]];
        case ({instr[31:25], instr[14:12]})
          10'b0000000_000: wr_data = num1 + num2;                               // ADD
          10'b0100000_000: wr_data = num1 - num2;                               // SUB
          10'b0000000_001: wr_data = num1 << num2[4:0];                         // SLL
          10'b0000000_010: wr_data = ($signed(num1) < $signed(num2)) ? 1 : 0;  // SLT
          10'b0000000_011: wr_data = (num1 < num2) ? 1 : 0;                    // SLTU
          10'b0000000_100: wr_data = num1 ^ num2;                               // XOR
          10'b0000000_101: wr_data = num1 >> num2[4:0];                         // SRL
          10'b0100000_101: wr_data = $signed(num1) >>> num2[4:0];               // SRA
          10'b0000000_110: wr_data = num1 | num2;                               // OR
          10'b0000000_111: wr_data = num1 & num2;                               // AND
          default: `uvm_error("REF_MODEL", $sformatf("Unknown R-type funct at PC=%0h", pc))
        endcase
        rf[rd] = wr_data;
        pc = pc + 4;
        return 1;
      end

      // I-Type arithmetic
      7'b0010011: begin
        logic [31:0] num1 = rf[instr[19:15]];
        logic [31:0] imm  = {{20{instr[31]}}, instr[31:20]};
        case (instr[14:12])
          3'b000: wr_data = num1 + imm;                                         // ADDI
          3'b001: wr_data = num1 << instr[24:20];                               // SLLI
          3'b010: wr_data = ($signed(num1) < $signed(imm)) ? 1 : 0;            // SLTI
          3'b011: wr_data = (num1 < imm) ? 1 : 0;                              // SLTIU
          3'b100: wr_data = num1 ^ imm;                                         // XORI
          3'b101: wr_data = instr[30] ? ($signed(num1) >>> instr[24:20])        // SRAI
                                      : (num1 >> instr[24:20]);                 // SRLI
          3'b110: wr_data = num1 | imm;                                         // ORI
          3'b111: wr_data = num1 & imm;                                         // ANDI
        endcase
        rf[rd] = wr_data;
        pc = pc + 4;
        return 1;
      end

      // I-Type load
      7'b0000011: begin
        logic [31:0] imm  = {{20{instr[31]}}, instr[31:20]};
        logic [31:0] addr = rf[instr[19:15]] + imm;
        logic [31:0] word = dmem[addr >> 2];
        case (instr[14:12])
          3'b000: wr_data = {{24{word[7]}},  word[7:0]};   // LB
          3'b001: wr_data = {{16{word[15]}}, word[15:0]};  // LH
          3'b010: wr_data = word;                           // LW
          3'b100: wr_data = {24'b0, word[7:0]};            // LBU
          3'b101: wr_data = {16'b0, word[15:0]};           // LHU
          default: `uvm_error("REF_MODEL", $sformatf("Unknown load funct3 at PC=%0h", pc))
        endcase
        rf[rd] = wr_data;
        pc = pc + 4;
        return 1;
      end

      // S-Type store
      7'b0100011: begin
        logic [31:0] imm  = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        logic [31:0] addr = rf[instr[19:15]] + imm;
        logic [31:0] num2 = rf[instr[24:20]];
        int          widx = int'(addr >> 2);
        case (instr[14:12])
          3'b000: dmem[widx] = {dmem[widx][31:8],  num2[7:0]};   // SB
          3'b001: dmem[widx] = {dmem[widx][31:16], num2[15:0]};  // SH
          3'b010: dmem[widx] = num2;                              // SW
          default: `uvm_error("REF_MODEL", $sformatf("Unknown store funct3 at PC=%0h", pc))
        endcase
        pc = pc + 4;
        rd = 5'b0;
        return 0;
      end

      // B-type
      7'b1100011: begin
        logic [31:0] num1 = rf[instr[19:15]];
        logic [31:0] num2 = rf[instr[24:20]];
        logic [31:0] imm  = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
        logic branch_taken;
        case (instr[14:12])
          3'b000: branch_taken = (num1 == num2);                   // BEQ
          3'b001: branch_taken = (num1 != num2);                   // BNE
          3'b100: branch_taken = ($signed(num1) < $signed(num2));  // BLT
          3'b101: branch_taken = ($signed(num1) >= $signed(num2)); // BGE
          3'b110: branch_taken = (num1 < num2);                    // BLTU
          3'b111: branch_taken = (num1 >= num2);                   // BGEU
          default: branch_taken = 1'b0;
        endcase
        pc = branch_taken ? (pc + imm) : (pc + 4);
        rd = 5'b0;
        return 0;
      end

      // LUI
      7'b0110111: begin
        wr_data = {instr[31:12], 12'b0};
        rf[rd]  = wr_data;
        pc = pc + 4;
        return 1;
      end

      // AUIPC
      7'b0010111: begin
        wr_data = pc + {instr[31:12], 12'b0};
        rf[rd]  = wr_data;
        pc = pc + 4;
        return 1;
      end

      // JAL
      7'b1101111: begin
        logic [31:0] imm = {{11{instr[31]}}, instr[31], instr[19:12],  instr[20], instr[30:21], 1'b0};
        wr_data = pc + 4;
        rf[rd]  = wr_data;
        pc = pc + imm;
        return 1;
      end

      // JALR
      7'b1100111: begin
        logic [31:0] imm = {{20{instr[31]}}, instr[31:20]};
        wr_data = pc + 4;
        rf[rd]  = wr_data;
        pc = (rf[instr[19:15]] + imm) & ~32'b1;
        return 1;
      end

      default: begin
        `uvm_error("REF_MODEL",
          $sformatf("Unknown opcode %0h at PC=%0h", instr[6:0], pc))
        pc = pc + 4;
        rd = 5'b0;
        return 0;
      end

    endcase
  endfunction

endclass
