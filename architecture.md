# RISCV RV32I Single Cycle Processor Core

## Specs
- Instruction Set Architecture: RISC-V RV32I
- Architecture: Single-cycle
- Data width: 32 bits
- Address width: 32 bits
- Registers: 32 x 32-bit registers

## Major Components

### Program Counter
Still have to figure out how to input
### Register File
Holds 32 x 32-bit registers
### Instruction Memory
Holds up to 64 32-bit instructions
### ALU
Currently can perform Addition, Subtraction, Shift Left Logical, Shift Right Logical, Shift Right Arithmetic, Set Less Than, Logical XOR, Logical OR, and Logical AND instructions.
### Instruction Decoder
Breaks up instructions into its different components (Do not know if I need to keep this but simplifies my work).
### Controller
Aka Control Unit. Sets different flags according to opcode (instruction type).
### Data Memory
Holds up to 64 32-bit values. Each address can be written to as a Byte, Half-Word, or Word. Writing less than a word currently does not overwrite the rest of the word with leading 0s.
### Sign Extender
Extends 12-bit imm value into 32 bits. Currently takes different bits from the instruction depending on instruction type (I or S).
## Instruction Set
RV32I : Instruction types include R, I, S, B, U, and J. Currently implemented R, I, and S instruction types, including: 
- R: ADD, SUB, SLL, SLT, XOR, SRL, SRA, OR, AND
- I: ADDI, XORI, ORI, ANDI, SLLI, SRLI, SRAI, SLTI
- S: SB, SH, SW
## Design Decisions

### Why single cycle?
- Simpler to build and Verify

### Why doesn't the write byte/half-word overwrite the entire 32-bits of memory?
- I am assuming that writing a byte or half word is only meant to edit part of a word, otherwise you would write a full word with leading 0s.

### Why only 64 addresses for instruction and data memory?
- I don't know this might change soon when I actually start doing stuff with this.