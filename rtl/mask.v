// Module implementing a mask.
// This is used for the cpu internal registers.
`default_nettype none

module mask(i_oe,
            i_data,
            o_data);
   parameter DATA_WIDTH = 8;

   input  wire                  i_oe;    // output enable
   input  wire [DATA_WIDTH-1:0] i_data;  // input data
   output wire [DATA_WIDTH-1:0] o_data;  // output data

   // masked output
   assign o_data = (i_oe) ? i_data : 0;

endmodule
