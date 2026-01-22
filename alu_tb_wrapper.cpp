#include "Valu_tb.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char** argv) {
    // Initialize Verilator
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    
    // Create instance of our module
    Valu_tb* tb = new Valu_tb;
    
    // Create VCD trace
    VerilatedVcdC* tfp = new VerilatedVcdC;
    tb->trace(tfp, 99);
    tfp->open("alu_tb.vcd");
    
    // Simulation time
    vluint64_t sim_time = 0;
    
    // Run simulation
    while (!Verilated::gotFinish()) {
        // Evaluate model
        tb->eval();
        
        // Dump trace
        tfp->dump(sim_time);
        
        // Advance time
        sim_time++;
    }
    
    // Clean up
    tfp->close();
    delete tb;
    delete tfp;
    
    return 0;
}
