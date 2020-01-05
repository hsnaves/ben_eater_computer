// Logic to display an 8-bit value using
// 3 seven segment displays
`default_nettype none

module seven_segment(i_clk,
                     i_value,
                     i_oe,
                     i_we,
                     o_data,
                     o_addr);
   parameter COUNTER_BITS = 16;

   // Input and output
   input  wire             i_clk;    // clock signal
   input  wire [7:0]       i_value;  // input value
   input  wire             i_oe;     // output enable
   input  wire             i_we;     // write enable
                                     // (to change the value on display)

   output reg [7:0]        o_data;   // For the 7-segment display
   output reg [2:0]        o_addr;   // For the 7-segment display

   // Auxiliary registers
   reg [COUNTER_BITS-1:0] counter;
   reg [7:0]              digit1;
   reg [7:0]              digit2;
   reg [7:0]              digit3;
   reg [1:0]              current_digit;

   // Contents of the rom
   reg [23:0]             rom[255:0];
   initial $readmemb("../../data/7segment_decode.b", rom);

   always @(posedge i_clk)
     if (i_we)
       begin
          {digit1, digit2, digit3} <= rom[i_value];
       end

   always @(posedge i_clk)
     counter <= counter + 1;

   always @(posedge i_clk)
     begin
        case (current_digit)
          0:
            begin
               o_addr <= 3'b001;
               if (i_oe)
                 o_data <= digit1;
               else
                 o_data <= 0;

               if (counter == 0)
                 current_digit <= 1;
            end
          1:
            begin
               o_addr <= 3'b010;
               if (i_enable)
                 o_data <= digit2;
               else
                 o_data <= 0;

               if (counter == 0)
                 current_digit <= 2;
            end
          2:
            begin
               o_addr <= 3'b100;
               if (i_enable)
                 o_data <= digit3;
               else
                 o_data <= 0;

               if (counter == 0)
                 current_digit <= 0;
            end
          default:
            begin
               o_addr <= 3'b000;
               o_data <= 8'b11111111;
               current_digit <= 0;
            end
        endcase
     end

endmodule
