#!/usr/bin/env bash
# Run the Verilator-port UVM testbench. Usage: ./scripts/run_sim.sh [r_test|i_test|s_test]
set -euo pipefail
cd "$(dirname "$0")/.."
TEST="${1:-r_test}"
make sim_uvm TEST="$TEST"
