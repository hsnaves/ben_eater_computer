// Module implementing a counter register.
// This is mainly used for the program counter.
`default_nettype none

module counter(i_clk,
               i_clke,
               i_reset,
               i_we,
               i_ce,
               i_data,
               o_data);
   parameter DATA_WIDTH = 8; // the width of the data bus

   input  wire                  i_clk;   // input clock
   input  wire                  i_clke;  // clock enable
   input  wire                  i_reset; // reset signal
   input  wire                  i_we;    // write enable
   input  wire                  i_ce;    // count enable
   input  wire [DATA_WIDTH-1:0] i_data;  // input data
   output wire [DATA_WIDTH-1:0] o_data;  // output data

   // internal counter
   reg [DATA_WIDTH-1:0]         cnt;

   // output of the counter
   assign o_data = cnt;

   always @(posedge i_clk)
     begin
        if (i_clke) // only do things when i_clke is set
          begin
             if (i_reset)
               cnt <= 0;
             else if (i_we)
               cnt <= i_data;
             else if (i_ce)
               cnt <= cnt + 1;
          end
     end

endmodule
