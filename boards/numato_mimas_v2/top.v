`default_nettype none

module top(CLK_100Mhz,
           DPSwitch,
           Switch,
           LED,
           SevenSegment,
           SevenSegmentEnable);
   parameter DATA_WIDTH = 8;
   parameter ADDR_WIDTH = 4;

   input  wire                  CLK_100Mhz;
   input  wire [7:0]            DPSwitch;
   input  wire [5:0]            Switch;
   output wire [7:0]            LED;
   output wire [7:0]            SevenSegment;
   output wire [2:0]            SevenSegmentEnable;

   // Rename clock line
   wire                         i_clk;
   assign i_clk = CLK_100Mhz;

   // Wiring for the clock driver
   wire                         clk_drv_enable;
   wire                         clk_drv_sample;

   clock_driver clock_driver(.i_clk(i_clk),
                             .i_mode(~DPSwitch[0]),
                             .i_pulse(~Switch[0]),
                             .i_speed_up(~Switch[1]),
                             .i_speed_down(~Switch[2]),
                             .o_sample(clk_drv_sample),
                             .o_enable(clk_drv_enable));

   // wire for reset button
   wire                         btn_reset;

   button button_pulse(.i_clk(i_clk),
                       .i_button(~Switch[3]),
                       .i_sample(clk_drv_sample),
                       .o_button(btn_reset));

   // Wiring for the computer
   wire                              comp_halt;
   wire [ADDR_WIDTH-1:0]             comp_addr;
   wire [DATA_WIDTH-1:0]             comp_data;
   wire [DATA_WIDTH-1:0]             comp_out;

   computer #(.DATA_WIDTH(DATA_WIDTH),
              .ADDR_WIDTH(ADDR_WIDTH))
       computer(.i_clk(i_clk),
                .i_clke(clk_drv_enable),
                .i_reset(btn_reset),
                .o_halt(comp_halt),
                .o_addr(comp_addr),
                .o_data(comp_data),
                .o_out(comp_out));

   // wires for the 7-segment display
   wire [7:0]                   display_data;
   wire [2:0]                   display_addr;

   seven_segment display(.i_clk(i_clk),
                         .i_value(comp_out),
                         .i_we(1),
                         .i_oe(1),
                         .o_data(display_data),
                         .o_addr(display_addr));

   assign SevenSegment = ~display_data;
   assign SevenSegmentEnable = ~display_addr;

   // wires for cycle counter
   wire [7:0]                   cycle;

   counter #(.DATA_WIDTH(8))
       counter_cycle(.i_clk(i_clk),
                     .i_clke(clk_drv_enable),
                     .i_reset(btn_reset),
                     .i_we(0),
                     .i_ce(~comp_halt),
                     .i_data(0),
                     .o_data(cycle));

   assign LED = cycle;

endmodule
