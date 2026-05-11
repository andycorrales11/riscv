// Reference ISA model. Locals declared at function scope (Verilator-friendly).
class rv32i_ref_model;

  logic [31:0] rf   [32];
  logic [31:0] dmem [64];
  logic [31:0] pc;

  function new();
    this.reset();
  endfunction

  function void reset();
    pc = 0;
    for (int i = 0; i < 32; i++) rf[i]   = 0;
    for (int i = 0; i < 64; i++) dmem[i] = 0;
  endfunction

  function logic step(input  logic [31:0] instr,
                      output logic [4:0]  rd,
                      output logic [31:0] wr_data,
                      output logic        pred_mem_write,
                      output logic [31:0] pred_mem_addr,
                      output logic [31:0] pred_mem_wdata);
    logic [31:0] num1;
    logic [31:0] num2;
    logic [31:0] imm;
    logic [31:0] addr;
    logic [31:0] word;
    int          widx;
    logic        branch_taken;

    rd             = instr[11:7];
    wr_data        = 32'b0;
    pred_mem_write = 1'b0;
    pred_mem_addr  = 32'b0;
    pred_mem_wdata = 32'b0;
    num1 = 32'b0; num2 = 32'b0; imm = 32'b0; addr = 32'b0; word = 32'b0;
    widx = 0; branch_taken = 1'b0;

    case (instr[6:0])
      7'b0110011: begin // R-type
        num1 = rf[instr[19:15]];
        num2 = rf[instr[24:20]];
        case ({instr[31:25], instr[14:12]})
          10'b0000000_000: wr_data = num1 + num2;
          10'b0100000_000: wr_data = num1 - num2;
          10'b0000000_001: wr_data = num1 << num2[4:0];
          10'b0000000_010: wr_data = ($signed(num1) < $signed(num2)) ? 32'd1 : 32'd0;
          10'b0000000_011: wr_data = (num1 < num2) ? 32'd1 : 32'd0;
          10'b0000000_100: wr_data = num1 ^ num2;
          10'b0000000_101: wr_data = num1 >> num2[4:0];
          10'b0100000_101: wr_data = $signed(num1) >>> num2[4:0];
          10'b0000000_110: wr_data = num1 | num2;
          10'b0000000_111: wr_data = num1 & num2;
          default: $display("[REF] Unknown R-type funct at PC=%0h", pc);
        endcase
        rf[rd] = wr_data;
        pc = pc + 4;
        return 1'b1;
      end

      7'b0010011: begin // I-type arithmetic
        num1 = rf[instr[19:15]];
        imm  = {{20{instr[31]}}, instr[31:20]};
        case (instr[14:12])
          3'b000: wr_data = num1 + imm;
          3'b001: wr_data = num1 << instr[24:20];
          3'b010: wr_data = ($signed(num1) < $signed(imm)) ? 32'd1 : 32'd0;
          3'b011: wr_data = (num1 < imm) ? 32'd1 : 32'd0;
          3'b100: wr_data = num1 ^ imm;
          3'b101: wr_data = instr[30] ? ($signed(num1) >>> instr[24:20])
                                      : (num1 >> instr[24:20]);
          3'b110: wr_data = num1 | imm;
          3'b111: wr_data = num1 & imm;
        endcase
        rf[rd] = wr_data;
        pc = pc + 4;
        return 1'b1;
      end

      7'b0000011: begin // I-type load
        imm  = {{20{instr[31]}}, instr[31:20]};
        addr = rf[instr[19:15]] + imm;
        word = dmem[addr >> 2];
        case (instr[14:12])
          3'b000: wr_data = {{24{word[7]}},  word[7:0]};
          3'b001: wr_data = {{16{word[15]}}, word[15:0]};
          3'b010: wr_data = word;
          3'b100: wr_data = {24'b0, word[7:0]};
          3'b101: wr_data = {16'b0, word[15:0]};
          default: $display("[REF] Unknown load funct3 at PC=%0h", pc);
        endcase
        rf[rd] = wr_data;
        pc = pc + 4;
        return 1'b1;
      end

      7'b0100011: begin // S-type
        imm  = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        addr = rf[instr[19:15]] + imm;
        num2 = rf[instr[24:20]];
        widx = int'(addr >> 2);
        pred_mem_write = 1'b1;
        pred_mem_addr  = addr;
        pred_mem_wdata = num2;
        case (instr[14:12])
          3'b000: dmem[widx] = {dmem[widx][31:8],  num2[7:0]};
          3'b001: dmem[widx] = {dmem[widx][31:16], num2[15:0]};
          3'b010: dmem[widx] = num2;
          default: $display("[REF] Unknown store funct3 at PC=%0h", pc);
        endcase
        pc = pc + 4;
        rd = 5'b0;
        return 1'b0;
      end

      7'b1100011: begin // B-type
        num1 = rf[instr[19:15]];
        num2 = rf[instr[24:20]];
        imm  = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
        case (instr[14:12])
          3'b000: branch_taken = (num1 == num2);
          3'b001: branch_taken = (num1 != num2);
          3'b100: branch_taken = ($signed(num1) < $signed(num2));
          3'b101: branch_taken = ($signed(num1) >= $signed(num2));
          3'b110: branch_taken = (num1 < num2);
          3'b111: branch_taken = (num1 >= num2);
          default: branch_taken = 1'b0;
        endcase
        pc = branch_taken ? (pc + imm) : (pc + 4);
        rd = 5'b0;
        return 1'b0;
      end

      7'b0110111: begin // LUI
        wr_data = {instr[31:12], 12'b0};
        rf[rd]  = wr_data;
        pc = pc + 4;
        return 1'b1;
      end

      7'b0010111: begin // AUIPC
        wr_data = pc + {instr[31:12], 12'b0};
        rf[rd]  = wr_data;
        pc = pc + 4;
        return 1'b1;
      end

      7'b1101111: begin // JAL
        imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
        wr_data = pc + 4;
        rf[rd]  = wr_data;
        pc = pc + imm;
        return 1'b1;
      end

      7'b1100111: begin // JALR
        imm = {{20{instr[31]}}, instr[31:20]};
        wr_data = pc + 4;
        rf[rd]  = wr_data;
        pc = (rf[instr[19:15]] + imm) & ~32'b1;
        return 1'b1;
      end

      default: begin
        $display("[REF] Unknown opcode %0h at PC=%0h", instr[6:0], pc);
        pc = pc + 4;
        rd = 5'b0;
        return 1'b0;
      end
    endcase
  endfunction

endclass
