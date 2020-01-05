`default_nettype none

module switch(i_clk,
              i_switch,
              i_sample,
              o_switch);
   input wire i_clk;
   input wire i_switch;
   input wire i_sample;
   output reg o_switch;

   // For crossing clock domains
   reg        switch1, switch2;

   // Double flip-flop for crossing
   always @(posedge i_clk)
     begin
        switch1 <= i_switch;
        switch2 <= switch1;
     end

   always @(posedge i_clk)
     begin
        if (i_sample)
          begin
             o_switch <= switch2;
          end
     end

endmodule
