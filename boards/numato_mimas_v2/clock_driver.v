`default_nettype none
`timescale 1ns / 1ps
module clock_driver(i_clk,
                    i_mode,
                    i_pulse,
                    i_speed_up,
                    i_speed_down,
                    o_sample,
                    o_enable);
   parameter COUNTER_BITS = 28;
   parameter DEBOUNCE_BITS = 22;

   input  wire i_clk;
   input  wire i_mode;
   input  wire i_pulse;
   input  wire i_speed_up;
   input  wire i_speed_down;
   output wire o_sample;
   output reg  o_enable;

   // Main counter for clock
   reg [COUNTER_BITS-1:0] counter = 0;
   reg [COUNTER_BITS-1:0] speed_mask = -1;

   // Wires with the de-bounced signals
   wire                   mode;
   wire                   pulse;
   wire                   speed_up;
   wire                   speed_down;

   // Wire for the de-bouncing clock
   wire                   sample;

   assign sample = (counter[DEBOUNCE_BITS-1:0] == 0);
   assign o_sample = sample;

   always @(posedge i_clk)
     begin
        counter <= counter + 1;
     end

   switch switch_mode(.i_clk(i_clk),
                      .i_switch(i_mode),
                      .i_sample(sample),
                      .o_switch(mode));

   button button_pulse(.i_clk(i_clk),
                       .i_button(i_pulse),
                       .i_sample(sample),
                       .o_button(pulse));

   button button_speed_up(.i_clk(i_clk),
                          .i_button(i_speed_up),
                          .i_sample(sample),
                          .o_button(speed_up));

   button button_speed_down(.i_clk(i_clk),
                            .i_button(i_speed_down),
                            .i_sample(sample),
                            .o_button(speed_down));

   always @(posedge i_clk)
     begin
        if (speed_down)
          begin
             speed_mask <= {speed_mask[COUNTER_BITS-2:0], 1'b1};
          end
        else if (speed_up)
          begin
             speed_mask <= {1'b0, speed_mask[COUNTER_BITS-1:1]};
          end
     end

   always @(posedge i_clk)
     begin
        if (mode == 0)
          begin
             o_enable <= ((counter & speed_mask) == 0);
          end
        else
          begin
             o_enable <= pulse;
          end
     end

endmodule
