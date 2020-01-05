#include <verilated.h>
#include <Vtop.h>

#if VM_TRACE
#include <verilated_vcd_c.h>
#endif

// Current simulation time (64-bit unsigned)
vluint64_t main_time = 0;

// Called by $time in Verilog
double sc_time_stamp()
{
  return main_time; // Note does conversion to real, to match SystemC
}

int main(int argc, char** argv, char** env)
{
  // Set debug level, 0 is off, 9 is highest presently used
  // May be overridden by commandArgs
  Verilated::debug(0);

  // Randomization reset policy
  // May be overridden by commandArgs
  Verilated::randReset(2);

  // Pass arguments so Verilated code can see them
  // This needs to be called before you create any model
  Verilated::commandArgs(argc, argv);

  // Construct the Verilated model, from Vtop.h generated from Verilating "top.v"
  Vtop* top = new Vtop();

#if VM_TRACE
  // If verilator was invoked with --trace argument,
  // and if at run time passed the +trace argument, turn on tracing
  VerilatedVcdC* tfp = NULL;
  const char* flag = Verilated::commandArgsPlusMatch("trace");

  if (flag && 0 == strcmp(flag, "+trace")) {
    Verilated::traceEverOn(true);  // Verilator must compute traced signals
    VL_PRINTF("Enabling waves into logs/vlt_dump.vcd...\n");
    tfp = new VerilatedVcdC;
    top->trace(tfp, 99);  // Trace 99 levels of hierarchy
    Verilated::mkdir("logs");
    tfp->open("logs/vlt_dump.vcd");  // Open the dump file
  }
#endif

  // Set some inputs
  top->i_clk = 1;
  top->i_reset = 1;

  // Simulate until cpu is halted
  while (!top->o_halt || (main_time <= 2)) {
    main_time++;  // Time passes...

    // Toggle clocks and such
    top->i_clk = !top->i_clk;

    if (main_time > 2) {
      top->i_reset = 0;
    }

    // Evaluate model
    top->eval();

#if VM_TRACE
    // Dump trace data for this cycle
    if (tfp) tfp->dump(main_time);
#endif

    // Read outputs
    VL_PRINTF("[%4d] i_clk=%x, i_reset=%x, "
              "o_addr=0x%1X, o_data=0x%02X, o_out=0x%02X\n",
              (int) main_time, top->i_clk, top->i_reset,
              top->o_addr, top->o_data, top->o_out);
  }

  // Final model cleanup
  top->final();

  // Close trace if opened
#if VM_TRACE
  if (tfp) { tfp->close(); tfp = NULL; }
#endif

  //  Coverage analysis (since test passed)
#if VM_COVERAGE
  Verilated::mkdir("logs");
  VerilatedCov::write("logs/coverage.dat");
#endif

  // Destroy model
  delete top; top = NULL;

  return 0;
}
