# RISC-V Processor Design and Verification Project


**GOAL**: Design and then verify a RISC-V processor core to improve my skills, over the span of a year, to improve my digital design and verification skills.  
**CHALLENGES**: All HDL will be written by me, on my Thinkpad X1 Carbon 2nd Gen, running Linux Mint, using Neovim.  
**TOOLS**: I will use Verilator and GTKWave, two open source programs, to simulate and view waveforms.  

**SOURCES**
- *Digital Design and Computer Architecture: RISC-V Edition* by Sarah L. Harris and David Harris
- *RV32I Base Integer Instruction Set* - https://docs.riscv.org/reference/isa/unpriv/rv32.html
- *Verilog Language and Application v29.0* Cadence Training
- *Essential SystemVerilog for UVM v1.2.5* Cadence Training
- *SystemVerilog Accelerated Verification using UVM v1.2.6* Cadence Training
- *Verilog Style Guide* - https://github.com/lowrisc/style-guides/blob/master/VerilogCodingStyle.md
- *RISC-V Instruction Reference* - https://www.cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CARD.pdf
- *UVM Cookbook* - Siemens Verification Academy
- I will keep adding more as I find them

[Architecture](architecture.md)

Architecture Graphic is not updated to match current architecture and is therefore ommitted

---

## Running the Verilator UVM-style testbench

This branch (`Alternate`) contains a Verilator port of the UVM testbench. UVM features that Verilator does not support (`uvm_*` classes/macros, `rand`/`constraint`/`randomize()`, covergroups, `uvm_config_db`, factory, virtual interfaces in classes, `uvm_hdl_deposit`, UVM phases) have been replaced with plain SystemVerilog equivalents under `tb/verilator/`. Tests are dispatched via a `+TEST=` plusarg.

### Prerequisites

- Verilator 5.x (tested on 5.020) — must support `--timing`
- A C++ compiler with C++20 coroutines (g++ 10+)
- GNU make

### Quick start

```bash
# Compile the design + Verilator testbench
make compile_uvm

# Run an individual test (TEST defaults to r_test)
make sim_uvm TEST=r_test
make sim_uvm TEST=i_test
make sim_uvm TEST=s_test

# Or via the helper scripts
./scripts/compile.sh
./scripts/run_sim.sh r_test
```

A successful run ends with:
```
[TOP] Scoreboard results: N passed, 0 failed
[TOP] TEST PASSED
```

A VCD trace is written to `uvm_tb.vcd` in the working directory and can be opened with GTKWave.

### Available tests

| Test     | What it does                                                                 |
| -------- | ---------------------------------------------------------------------------- |
| `r_test` | ADDI preamble to seed source registers, then 5–20 randomized R-type instrs. |
| `i_test` | 5–20 randomized I-type arithmetic instructions (no preamble; reads x0).      |
| `s_test` | ADDI preamble seeds rs2; then 5–20 randomized stores into data memory.       |

The scoreboard checks every retired instruction against an in-module reference ISA model: PC, next-PC, `reg_write`, destination register, written value, and (for stores) memory address and data.

### Structure of the Verilator testbench

```
tb/verilator/
├── classes/
│   ├── rv32i_instr.sv       # base class (no UVM, no rand)
│   ├── rtype_instr.sv       # each subclass exposes do_randomize()
│   ├── itype_instr.sv       # using $urandom_range internally
│   ├── stype_instr.sv
│   ├── btype_instr.sv
│   ├── utype_instr.sv
│   └── jtype_instr.sv
├── rv32i_pkg.sv             # opcodes, push_unique_reg helper, class includes
├── rv32i_if.sv              # interface (covergroup removed)
├── rv32i_ref_model.sv       # ref model with locals at function scope
└── top.sv                   # clock/reset/load driver, program builder,
                             # in-module monitor + scoreboard, +TEST dispatch
```

### Required RTL changes

Two RTL changes were necessary to support Verilator (no backdoor writes possible):

1. `rtl/memory/instruction_memory.sv` — replaced `$readmemh` and `always_ff @(posedge reset)` clearing with an explicit clocked write port (`load_en`, `load_addr[5:0]`, `load_data[31:0]`) and NOP initialization.
2. `rtl/core/cpu.sv` — three new pass-through input ports (`inst_load_en`, `inst_load_addr`, `inst_load_data`) routed to the instruction memory.

The legacy testbenches in `tb/basic/` have not been updated, so their `cpu(.clk, .reset)` instantiations will not compile until they wire (or zero out) the new load ports.


