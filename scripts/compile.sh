#!/usr/bin/env bash
# Compile the Verilator-port UVM-style testbench.
set -euo pipefail
cd "$(dirname "$0")/.."
make compile_uvm
