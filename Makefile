# RISC-V Verification Project Makefile

# Directories
RTL_DIR = rtl/core
TB_DIR = tb/basic

# Files
ALU_RTL = $(RTL_DIR)/alu.sv
ALU_TB = $(TB_DIR)/alu_tb.sv

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
compile: $(ALU_RTL) $(ALU_TB)
	@echo "Compiling ALU testbench..."
	verilator $(VFLAGS) \
		$(ALU_RTL) \
		$(ALU_TB) \
		alu_tb_wrapper.cpp \
		--top-module $(TOP) \
		--timing \
		-Mdir $(BUILD_DIR)
	@echo "Build complete!"

# Run simulation
sim: compile
	@echo "Running simulation..."
	./$(BUILD_DIR)/V$(TOP)
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