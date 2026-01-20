#include "Valu_tb.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
	
    Valu_tb* tb = new Valu_tb;
	
    // Create VCD trace
    VerilatedVcdC* tfp = new VerilatedVcdC;
    tb->trace(tfp, 99);
    tfp->open("alu_tb.vcd");

    vluint64_t main_time = 0;
    vluint64_t max_time = 1000000; 
	
    while (!Verilated::gotFinish() && main_time < max_time) {
        main_time++;
        tb->eval();

        if (Verilated::threadContextp()->time() < main_time) {
            Verilated::threadContextp()->time(main_time);
        }
        tfp->dump(main_time);
    }
	
    tb->final();
    tfp->close();
	
    delete tb;
    delete tfp;
	
    if (main_time >= max_time) {
        printf("WARNING: Simulation reached maximum time limit\n");
    }
	
    return 0;
}
