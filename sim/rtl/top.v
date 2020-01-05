`default_nettype none

module top(i_clk,
           i_reset,
           o_halt,
           o_addr,
           o_data,
           o_out);
   parameter DATA_WIDTH = 8;
   parameter ADDR_WIDTH = 4;

   input  wire                  i_clk;
   input  wire                  i_reset;
   output wire                  o_halt;
   output wire [ADDR_WIDTH-1:0] o_addr;
   output wire [DATA_WIDTH-1:0] o_data;
   output wire [DATA_WIDTH-1:0] o_out;

   computer #(.DATA_WIDTH(DATA_WIDTH),
              .ADDR_WIDTH(ADDR_WIDTH))
       computer(.i_clk(i_clk),
                .i_clke(1),
                .i_reset(i_reset),
                .o_halt(o_halt),
                .o_addr(o_addr),
                .o_data(o_data),
                .o_out(o_out));

endmodule
