`include "../../lib/EECS151.v"

module edge_detector #(
    parameter WIDTH = 1
)(
    input clk,
    input [WIDTH-1:0] signal_in,
    output [WIDTH-1:0] edge_detect_pulse
);

      // TODO: implement an edge detector that detects a rising edge of 'signal_in'
      // and outputs a one-cycle pulse at the next clock edge
      // Feel free to use as many number of registers you like
      wire [WIDTH-1:0] signal_reg1;
      wire [WIDTH-1:0] signal_reg2;
      wire [WIDTH-1:0] signal_reset;
      assign signal_reset = (~signal_in) & (signal_reg1 & signal_reg2);
      genvar j;
      generate
      for (j = 0; j < WIDTH; j = j + 1) begin
      REGISTER_R_CE #(1) reg1(.rst(signal_reset[j]), .clk(clk), .q(signal_reg1[j]), .d(signal_in[j]), .ce(signal_in[j]));
      REGISTER_R_CE #(1) reg2(.rst(signal_reset[j]), .clk(clk), .q(signal_reg2[j]), .d(signal_reg1[j]), .ce(signal_reg1[j]));
      end
      endgenerate
      
      assign edge_detect_pulse = (signal_reg1) & (~signal_reg2);
      

endmodule