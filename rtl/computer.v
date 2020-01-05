// Module implementing the computer designed by Ben Eater
`default_nettype none

module computer(i_clk,
                i_clke,
                i_reset,
                o_halt,
                o_addr,
                o_data,
                o_out);
   parameter DATA_WIDTH = 8; // the width of the data bus
   parameter ADDR_WIDTH = 4; // the width of the address bus

   input  wire                  i_clk;   // input clock
   input  wire                  i_clke;  // clock enable
   input  wire                  i_reset; // reset signal
   output wire                  o_halt;  // cpu halted
   output wire [ADDR_WIDTH-1:0] o_addr;  // address bus
   output wire [DATA_WIDTH-1:0] o_data;  // data bus
   output wire [DATA_WIDTH-1:0] o_out;   // contents of out register

   // wires for the cpu
   wire                         cpu_re;
   wire                         cpu_we;
   wire                         cpu_halt;
   wire [ADDR_WIDTH-1:0]        cpu_addr;
   wire [DATA_WIDTH-1:0]        cpu_data;
   wire [DATA_WIDTH-1:0]        cpu_out;

   // wires for the RAM memory
   wire [DATA_WIDTH-1:0]        ram_data;

   cpu #(.DATA_WIDTH(DATA_WIDTH),
         .ADDR_WIDTH(ADDR_WIDTH))
       cpu(.i_clk(i_clk),
           .i_clke(i_clke),
           .i_reset(i_reset),
           .i_data(ram_data),
           .o_re(cpu_re),
           .o_we(cpu_we),
           .o_halt(cpu_halt),
           .o_addr(cpu_addr),
           .o_data(cpu_data),
           .o_out(cpu_out));

   ram #(.DATA_WIDTH(DATA_WIDTH),
         .ADDR_WIDTH(ADDR_WIDTH),
         .INITIALIZE(1),
         .RAM_FILE("../../data/ram.b")) // initial contents of RAM
       ram(.i_clk(i_clk),
           .i_clke(i_clke),
           .i_re(cpu_re),
           .i_we(cpu_we),
           .i_addr(cpu_addr),
           .i_data(cpu_data),
           .o_data(ram_data));

   // The output wires
   assign o_halt = cpu_halt;
   assign o_addr = cpu_addr;
   assign o_data = cpu_data;
   assign o_out = cpu_out;

endmodule
