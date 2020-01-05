// Module implementing a register.
// This is used for the cpu internal registers.
`default_nettype none

module register(i_clk,
                i_clke,
                i_reset,
                i_we,
                i_data,
                o_data);
   parameter DATA_WIDTH = 8;

   input  wire                  i_clk;   // input clock
   input  wire                  i_clke;  // clock enable
   input  wire                  i_reset; // reset signal
   input  wire                  i_we;    // write enable
   input  wire [DATA_WIDTH-1:0] i_data;  // input data
   output wire [DATA_WIDTH-1:0] o_data;  // output data

   // internal data
   reg [DATA_WIDTH-1:0]         data;

   // output of the register
   assign o_data = data;

   always @(posedge i_clk)
     begin
        if (i_clke) // only do things when i_clke is set
          begin
             if (i_reset)
               data <= 0;
             else if (i_we)
               data <= i_data;
          end
     end

endmodule
