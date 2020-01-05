// Module implementing the RAM memory block.
`default_nettype none

module ram(i_clk,
           i_clke,
           i_re,
           i_we,
           i_addr,
           i_data,
           o_data);
   parameter DATA_WIDTH = 8; // the width of the data bus
   parameter ADDR_WIDTH = 4; // the width of the address bus
   parameter INITIALIZE = 0; // read the contents if parameter is nonzero
   parameter RAM_FILE = ""; // the contents of the RAM

   localparam ADDR_SIZE = 1 << ADDR_WIDTH;

   input  wire                  i_clk;  // input clock
   input  wire                  i_clke; // clock enable
   input  wire                  i_re;   // read enable
   input  wire                  i_we;   // write enable
   input  wire [ADDR_WIDTH-1:0] i_addr; // input memory address
   input  wire [DATA_WIDTH-1:0] i_data; // input data
   output wire [DATA_WIDTH-1:0] o_data; // output data

   reg [DATA_WIDTH-1:0]         mem [0:ADDR_SIZE-1];

   // Read the contents of the RAM
   initial
     if (INITIALIZE)
       $readmemb(RAM_FILE, mem);

   assign o_data = (i_re) ? mem[i_addr] : 0;

   always @(posedge i_clk)
     begin
        if (i_clke) // only do things when i_clke is set
          begin
             if (i_we)
               mem[i_addr] <= i_data;
          end
     end

endmodule
