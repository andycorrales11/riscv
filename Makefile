# RISC-V Verification Project Makefile

# Directories
RTL_DIR = rtl/core
MEM_DIR = rtl/memory
COM_DIR = rtl/common
TB_DIR = tb/basic
PKG_DIR = tb/packages


# ALU Unit Test
ALU_RTL = $(RTL_DIR)/alu.sv
ALU_TB = $(TB_DIR)/alu_tb.sv

# instruction Test
RTL = \
  $(COM_DIR)/mux2.sv \
  $(MEM_DIR)/instruction_memory.sv \
  $(MEM_DIR)/data_memory.sv \
  $(RTL_DIR)/alu.sv \
  $(RTL_DIR)/controller.sv \
  $(RTL_DIR)/instruction_decoder.sv \
  $(RTL_DIR)/program_counter.sv \
  $(RTL_DIR)/register_file.sv \
  $(RTL_DIR)/sign_extender.sv \
  $(RTL_DIR)/top.sv

R_TB = $(TB_DIR)/rtype_tb.sv
I_TB = $(TB_DIR)/itype_tb.sv
INST_TB = $(TB_DIR)/instruction_tb.sv
INST_PKG = $(PKG_DIR)/rv32i_pkg.sv

# Verilator flags
VFLAGS = --cc --trace --exe --build

# Top module
TOP_ALU = alu_tb
TOP_RTYPE = rtype_tb
TOP_ITYPE = itype_tb
TOP_INST = instruction_tb

# Build and wave files
BUILD_DIR = sim/obj_dir
WAVE = sim/waves.vcd

# Default target
all: compile

# Compile and build
compile_alu: $(ALU_RTL) $(ALU_TB)
	@echo "Compiling ALU testbench..."
	verilator $(VFLAGS) \
		$(ALU_RTL) \
		$(ALU_TB) \
		alu_tb_wrapper.cpp \
		--top-module $(TOP_ALU) \
		--timing \
		-Mdir $(BUILD_DIR)
	@echo "Build complete!"

compile_rtype: $(RTL) $(R_TB)
	@echo "Compiling R-type instruction testbench..."
	verilator $(VFLAGS) \
		$(RTL) \
		$(R_TB) \
		rtype_tb_wrapper.cpp \
		--top-module $(TOP_RTYPE) \
		--timing \
		-Mdir $(BUILD_DIR)

compile_itype: $(RTL) $(I_TB)
	@echo "Compiling I-type instruction testbench..."
	verilator $(VFLAGS) \
		$(RTL) \
		$(I_TB) \
		itype_tb_wrapper.cpp \
		--top-module $(TOP_ITYPE) \
		--timing \
		-Mdir $(BUILD_DIR)
	@echo "Build complete!"

compile: 
	@echo "Compiling instruction testbench..."
	verilator $(VFLAGS) \
		$(RTL) \
		$(INST_PKG) \
		$(INST_TB) \
		instruction_tb_wrapper.cpp \
		--top-module $(TOP_INST) \
		--timing \
		-Mdir $(BUILD_DIR)
	@echo "Build complete!"

# ---------------------------------------------------------------------------
# UVM testbench (tb/uvm/)
#
# NOTE: requires a UVM-capable Verilator. Upstream UVM 2017-1.0 elaboration
# landed in Verilator *master* incrementally; the Debian 5.020 build CANNOT
# elaborate it (fails on type_id forward refs, parameterized-class typedefs,
# disable-by-label). Build Verilator from git master to use this target.
#
# Covergroup caveat: Verilator only parses/elaborates the covergroup in
# rv32i_if.sv so it can be excluded -- no functional coverage is collected.
# ---------------------------------------------------------------------------
UVM_HOME ?= /home/andy/tools/1800.2-2017-1.0/src
UVM_DIR  = tb/uvm
UVM_BUILD_DIR = sim/obj_dir_uvm
TOP_UVM = top
UVM_TEST ?= r_test

# All RTL needed by the cpu the UVM top instantiates
UVM_RTL = \
  $(COM_DIR)/mux2.sv \
  $(COM_DIR)/mux3.sv \
  $(MEM_DIR)/instruction_memory.sv \
  $(MEM_DIR)/data_memory.sv \
  $(RTL_DIR)/alu.sv \
  $(RTL_DIR)/branch_unit.sv \
  $(RTL_DIR)/controller.sv \
  $(RTL_DIR)/instruction_decoder.sv \
  $(RTL_DIR)/program_counter.sv \
  $(RTL_DIR)/register_file.sv \
  $(RTL_DIR)/sign_extender.sv \
  $(RTL_DIR)/cpu.sv

compile_uvm:
	@test -f "$(UVM_HOME)/uvm_pkg.sv" || { \
	  echo "ERROR: UVM_HOME=$(UVM_HOME) has no uvm_pkg.sv."; \
	  echo "Set UVM_HOME to your 1800.2-2017-1.0/src, e.g.:"; \
	  echo "  make compile_uvm UVM_HOME=/path/to/1800.2-2017-1.0/src"; \
	  exit 1; }
	@echo "Compiling UVM testbench (needs UVM-capable Verilator master)..."
	verilator --binary --timing -Wno-fatal --build-jobs 4 \
		+incdir+$(UVM_HOME) +define+UVM_NO_DPI \
		+incdir+$(UVM_DIR) +incdir+$(UVM_DIR)/classes \
		$(UVM_HOME)/uvm_pkg.sv \
		$(UVM_RTL) \
		$(UVM_DIR)/rv32i_if.sv \
		$(UVM_DIR)/rv32i_pkg.sv \
		$(UVM_DIR)/top.sv \
		--top-module $(TOP_UVM) \
		-Mdir $(UVM_BUILD_DIR)
	@echo "Build complete!"

sim_uvm: compile_uvm
	@echo "Running UVM simulation (UVM_TEST=$(UVM_TEST))..."
	./$(UVM_BUILD_DIR)/V$(TOP_UVM) +UVM_TESTNAME=$(UVM_TEST)
	@echo "Simulation complete!"

# Run simulation
sim_alu: compile_alu
	@echo "Running simulation..."
	./$(BUILD_DIR)/V$(TOP_ALU)
	@echo "Simulation complete!"

sim_rtype: compile_rtype
	@echo "Running R-type instruction simulation..."
	./$(BUILD_DIR)/V$(TOP_RTYPE)
	@echo "Simulation complete!"

sim_itype: compile_itype
	@echo "Running I-type instruction simulation..."
	./$(BUILD_DIR)/V$(TOP_ITYPE)
	@echo "Simulation complete!"

sim: compile
	@echo "Running instruction simulation..."
	./$(BUILD_DIR)/V$(TOP_INST)
	@echo "Simulation complete!"

# View waveforms
waves: sim
	@echo "Opening waveforms..."
	gtkwave $(WAVE) &

# Run and show result
test: sim
	@echo "Tests completed. Check output above."

# Clean build files
clean:
	@echo "Cleaning build files..."
	rm -rf $(BUILD_DIR)
	rm -rf $(UVM_BUILD_DIR)
	rm -f $(WAVE)
	@echo "Clean complete!"

# Help
help:
	@echo "Available targets:"
	@echo "  make compile     - Compile the design"
	@echo "  make sim         - Compile and run simulation"
	@echo "  make compile_uvm - Compile the UVM testbench (needs UVM-capable Verilator master)"
	@echo "  make sim_uvm     - Compile and run the UVM testbench (UVM_TEST=<name>)"
	@echo "  make waves       - Run simulation and open waveforms"
	@echo "  make test        - Run simulation and show results"
	@echo "  make clean       - Remove build files"
	@echo "  make help        - Show this message"

.PHONY: all compile sim compile_uvm sim_uvm waves test clean help