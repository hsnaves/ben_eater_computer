`default_nettype none

module button(i_clk,
              i_button,
              i_sample,
              o_button);
   input wire i_clk;
   input wire i_button;
   input wire i_sample;
   output reg o_button;

   // For crossing clock domains
   reg        button1, button2;

   // State variable for debouncing
   reg        was_pressed = 0;

   // Double flip-flop for crossing
   always @(posedge i_clk)
     begin
        button1 <= i_button;
        button2 <= button1;
     end

   always @(posedge i_clk)
     begin
        if (i_sample)
          begin
             o_button <= button2 & ~was_pressed;
             was_pressed <= button2;
          end
        else
          begin
             o_button <= 0;
          end
     end

endmodule
