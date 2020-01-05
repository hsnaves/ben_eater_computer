// Module implementing ROM memory block.
`default_nettype none

module rom(i_re,
           i_addr,
           o_data);
   parameter DATA_WIDTH = 8; // the width of the data bus
   parameter ADDR_WIDTH = 4; // the width of the address bus
   parameter ROM_FILE = "rom.b"; // location of the rom file to load

   localparam ADDR_SIZE = 1 << ADDR_WIDTH;

   input  wire                  i_re;   // read enable
   input  wire [ADDR_WIDTH-1:0] i_addr; // input memory address
   output wire [DATA_WIDTH-1:0] o_data; // output data

   reg [DATA_WIDTH-1:0]         mem [0:ADDR_SIZE-1];

   // Read the contents of the ROM
   initial $readmemb(ROM_FILE, mem);

   assign o_data = (i_re) ? mem[i_addr] : 0;

endmodule
