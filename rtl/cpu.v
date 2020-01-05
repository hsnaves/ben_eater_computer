// Module implementing the cpu designed by Ben Eater
`default_nettype none

module cpu(i_clk,
           i_clke,
           i_reset,
           i_data,
           o_re,
           o_we,
           o_halt,
           o_addr,
           o_data,
           o_out);
   parameter DATA_WIDTH = 8; // the width of the data bus
   parameter ADDR_WIDTH = 4; // the width of the address bus

   // for the micro-instruction counter
   localparam MIC_WIDTH = 3;

   // for the flags register
   localparam F_WIDTH = 2;

   // for the micro-code rom
   localparam MC_DATA_WIDTH = 16;
   localparam MC_ADDR_WIDTH = DATA_WIDTH - ADDR_WIDTH + MIC_WIDTH + F_WIDTH;

   input  wire                  i_clk;   // input clock
   input  wire                  i_clke;  // clock enable
   input  wire                  i_reset; // reset signal
   input  wire [DATA_WIDTH-1:0] i_data;  // input data
   output wire                  o_re;    // read enable
   output wire                  o_we;    // write enable
   output wire                  o_halt;  // cpu halted
   output wire [ADDR_WIDTH-1:0] o_addr;  // output address
   output wire [DATA_WIDTH-1:0] o_data;  // output data
   output wire [DATA_WIDTH-1:0] o_out;   // contents of the out register

   // register for halt
   reg                          halt;

   assign o_halt = halt;

   // wires for the internal bus
   wire [DATA_WIDTH-1:0]        bus;

   // wires for register a
   wire [DATA_WIDTH-1:0]        reg_a;
   wire                         reg_a_reset;
   wire                         reg_a_we;

   register #(.DATA_WIDTH(DATA_WIDTH))
       register_a(.i_clk(i_clk),
                  .i_clke(i_clke),
                  .i_reset(reg_a_reset),
                  .i_we(reg_a_we),
                  .i_data(bus),
                  .o_data(reg_a));

   // mask for the output of register a to the bus
   wire [DATA_WIDTH-1:0]        reg_a_bus;
   wire                         reg_a_bus_oe;

   mask #(.DATA_WIDTH(DATA_WIDTH))
       mask_reg_a(.i_oe(reg_a_bus_oe),
                  .i_data(reg_a),
                  .o_data(reg_a_bus));

   // wires for register b
   wire [DATA_WIDTH-1:0]        reg_b;
   wire                         reg_b_reset;
   wire                         reg_b_we;

   register #(.DATA_WIDTH(DATA_WIDTH))
       register_b(.i_clk(i_clk),
                  .i_clke(i_clke),
                  .i_reset(reg_b_reset),
                  .i_we(reg_b_we),
                  .i_data(bus),
                  .o_data(reg_b));

   // wires for the alu
   wire [DATA_WIDTH-1:0]        alu_result;
   wire                         alu_sub;
   wire                         alu_ocarry;
   wire                         alu_ozero;

   alu #(.DATA_WIDTH(DATA_WIDTH))
       alu(.i_val_a(reg_a),
           .i_val_b(reg_b),
           .i_carry(alu_sub),
           .i_neg_b(alu_sub),
           .o_result(alu_result),
           .o_carry(alu_ocarry),
           .o_zero(alu_ozero));

   // mask for the output of alu to the bus
   wire [DATA_WIDTH-1:0]        alu_bus;
   wire                         alu_bus_oe;

   mask #(.DATA_WIDTH(DATA_WIDTH))
       mask_alu(.i_oe(alu_bus_oe),
                .i_data(alu_result),
                .o_data(alu_bus));

   // wires for the flags register
   wire [F_WIDTH-1:0]           reg_f;
   wire                         reg_f_reset;
   wire                         reg_f_we;

   register #(.DATA_WIDTH(F_WIDTH))
       register_flags(.i_clk(i_clk),
                      .i_clke(i_clke),
                      .i_reset(reg_f_reset),
                      .i_we(reg_f_we),
                      .i_data({alu_ocarry, alu_ozero}),
                      .o_data(reg_f));

   // wires for program counter
   wire [ADDR_WIDTH-1:0]        reg_pc;
   wire                         reg_pc_reset;
   wire                         reg_pc_we;
   wire                         reg_pc_ce;

   counter #(.DATA_WIDTH(ADDR_WIDTH))
       counter_pc(.i_clk(i_clk),
                  .i_clke(i_clke),
                  .i_reset(reg_pc_reset),
                  .i_we(reg_pc_we),
                  .i_ce(reg_pc_ce),
                  .i_data(bus[ADDR_WIDTH-1:0]),
                  .o_data(reg_pc));

   // wires for register out
   wire [DATA_WIDTH-1:0]        reg_out;
   wire                         reg_out_reset;
   wire                         reg_out_we;

   register #(.DATA_WIDTH(DATA_WIDTH))
       register_out(.i_clk(i_clk),
                    .i_clke(i_clke),
                    .i_reset(reg_out_reset),
                    .i_we(reg_out_we),
                    .i_data(bus),
                    .o_data(reg_out));

   assign o_out = reg_out;

   // wires for memory address register
   wire [ADDR_WIDTH-1:0]        reg_mar;
   wire                         reg_mar_we;

   register #(.DATA_WIDTH(ADDR_WIDTH))
       register_mar(.i_clk(i_clk),
                    .i_clke(i_clke),
                    .i_reset(i_reset),
                    .i_we(reg_mar_we),
                    .i_data(bus[ADDR_WIDTH-1:0]),
                    .o_data(reg_mar));

   // wires for instruction register
   wire [DATA_WIDTH-1:0]        reg_ir;
   wire                         reg_ir_reset;
   wire                         reg_ir_we;

   register #(.DATA_WIDTH(DATA_WIDTH))
       register_ir(.i_clk(i_clk),
                   .i_clke(i_clke),
                   .i_reset(reg_ir_reset),
                   .i_we(reg_ir_we),
                   .i_data(bus),
                   .o_data(reg_ir));

   // wires for micro-instruction counter
   wire [MIC_WIDTH-1:0]         reg_mic;
   wire                         reg_mic_reset;

   counter #(.DATA_WIDTH(MIC_WIDTH))
       counter_mic(.i_clk(i_clk),
                   .i_clke(i_clke),
                   .i_reset(reg_mic_reset),
                   .i_we(0),
                   .i_ce(1),
                   .i_data(0),
                   .o_data(reg_mic));

   // wires for the micro-code ROM
   wire [MC_DATA_WIDTH-1:0]     mc_data;
   wire [MC_ADDR_WIDTH-1:0]     mc_addr;

   rom #(.DATA_WIDTH(MC_DATA_WIDTH),
         .ADDR_WIDTH(MC_ADDR_WIDTH),
         .ROM_FILE("../../data/microcode.b"))
       microcode_rom(.i_re(1),
                     .i_addr(mc_addr),
                     .o_data(mc_data));

   assign mc_addr = { reg_ir[DATA_WIDTH-1:ADDR_WIDTH],
                      reg_mic, reg_f };

   // temporary wires for the bus
   wire [DATA_WIDTH-1:0]        data;
   wire [DATA_WIDTH-1:0]        reg_pc_bus;
   wire [DATA_WIDTH-1:0]        reg_ir_bus;

   wire                         reg_pc_bus_oe;
   wire                         reg_ir_bus_oe;

   assign data = (o_re) ? i_data : 0;
   assign reg_pc_bus = (reg_pc_bus_oe) ? {{(DATA_WIDTH-ADDR_WIDTH){1'b0}},
                                          reg_pc} : 0;
   assign reg_ir_bus = (reg_ir_bus_oe) ? {{(DATA_WIDTH-ADDR_WIDTH){1'b0}},
                                          reg_ir[ADDR_WIDTH-1:0]} : 0;

   // the bus is just the OR of the output
   // of the registers a, pc, and ir, the alu,
   // and the input data
   assign bus = data
                | reg_a_bus
                | reg_pc_bus
                | reg_ir_bus
                | alu_bus;

   assign o_data = bus; // output the contents of the bus

   // output address is just the contents of the memory address register
   assign o_addr = reg_mar;

   // the masked command from the microcode rom
   wire [MC_DATA_WIDTH-1:0]     cmd;

   assign cmd = (i_reset | halt) ? 0 : mc_data;

   // from the micro-code rom
   assign reg_a_reset   = i_reset;
   assign reg_b_reset   = i_reset;
   assign reg_pc_reset  = i_reset;
   assign reg_out_reset = i_reset;
   assign reg_ir_reset  = i_reset;
   assign reg_f_reset   = i_reset;

   assign reg_mic_reset = (reg_mic[2] & reg_mic[1]);

   assign reg_a_bus_oe  = cmd[0];
   assign alu_bus_oe    = cmd[1];
   assign reg_pc_bus_oe = cmd[2];
   assign reg_ir_bus_oe = cmd[3];
   assign o_re          = cmd[4];

   assign reg_a_we      = cmd[5];
   assign reg_b_we      = cmd[6];
   assign reg_pc_we     = cmd[7];
   assign reg_out_we    = cmd[8];
   assign reg_mar_we    = cmd[9];
   assign reg_ir_we     = cmd[10];
   assign reg_f_we      = cmd[11];
   assign o_we          = cmd[12];

   assign reg_pc_ce     = cmd[13];
   assign alu_sub       = cmd[14];


   // Halt logic
   always @(posedge i_clk)
     begin
        if (i_clke) // only do things when i_clke is set
          begin
             if (i_reset)
               halt <= 0;
             else
               halt <= halt | cmd[15];
          end
     end

endmodule
