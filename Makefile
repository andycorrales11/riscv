# RISC-V Verification Project Makefile

# Directories
RTL_DIR = rtl/core
MEM_DIR = rtl/memory
COM_DIR = rtl/common
TB_DIR = tb/basic


# ALU Unit Test
ALU_RTL = $(RTL_DIR)/alu.sv
ALU_TB = $(TB_DIR)/alu_tb.sv

# R instruction Test
R_RTL = \
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

# Verilator flags
VFLAGS = --cc --trace --exe --build

# Top module
TOP = alu_tb

# Output directory
BUILD_DIR = sim/obj_dir

# Waveform file
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

compile_rtype: $(R_RTL) $(R_TB)
	@echo "Compiling R-type instruction testbench..."
	verilator $(VFLAGS) \
		$(R_RTL) \
		$(R_TB) \
		rtype_tb_wrapper.cpp \
		--top-module $(TOP_RTYPE) \
		--timing \
		-Mdir $(BUILD_DIR)
	@echo "Build complete!"

compile: compile_alu compile_rtype

# Run simulation
sim_alu: compile_alu
	@echo "Running simulation..."
	./$(BUILD_DIR)/V$(TOP_ALU)
	@echo "Simulation complete!"

sim_rtype: compile_rtype
	@echo "Running R-type instruction simulation..."
	./$(BUILD_DIR)/V$(TOP_RTYPE)
	@echo "Simulation complete!"

sim: sim_alu sim_rtype

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
	rm -f $(WAVE)
	@echo "Clean complete!"

# Help
help:
	@echo "Available targets:"
	@echo "  make compile  - Compile the design"
	@echo "  make sim      - Compile and run simulation"
	@echo "  make waves    - Run simulation and open waveforms"
	@echo "  make test     - Run simulation and show results"
	@echo "  make clean    - Remove build files"
	@echo "  make help     - Show this message"

.PHONY: all compile sim waves test clean help