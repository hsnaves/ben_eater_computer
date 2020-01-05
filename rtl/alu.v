// Arithmetic logic unit for the cpu.
`default_nettype none

module alu(i_val_a,
           i_val_b,
           i_carry,
           i_neg_b,
           o_result,
           o_carry,
           o_zero);
   parameter DATA_WIDTH = 8;   // the width of the data bus

   input  wire [DATA_WIDTH-1:0] i_val_a;  // first operand
   input  wire [DATA_WIDTH-1:0] i_val_b;  // second operand
   input  wire                  i_carry;  // input carry
   input  wire                  i_neg_b;  // to negate second operand
   output wire [DATA_WIDTH-1:0] o_result; // result
   output wire                  o_carry;  // output carry
   output wire                  o_zero;   // output is zero

   // Internal wires
   wire [DATA_WIDTH-1:0]        val_b; // for the negated B
   wire [DATA_WIDTH:0]          sum;   // temporary for the sum

   // Negate B if necessary
   assign val_b = i_val_b ^ {DATA_WIDTH{i_neg_b}};

   // compute the sum
   assign sum = i_val_a + val_b + {{DATA_WIDTH{1'b0}}, i_carry};

   // Compute the output
   assign {o_carry, o_result} = sum;

   // The zero flag
   assign o_zero = ~(|sum[DATA_WIDTH-1:0]);

endmodule
