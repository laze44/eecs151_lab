`include "../../lib/EECS151.v"

module synchronizer #(parameter WIDTH = 1) (
    input [WIDTH-1:0] async_signal,
    input clk,
    output [WIDTH-1:0] sync_signal
);
	    // TODO: Create your 2 flip-flop synchronizer here
	    // This module takes in a vector of WIDTH-bit asynchronous
      // (from different clock domain or not clocked, such as button press) signals
	    // and should output a vector of WIDTH-bit synchronous signals
      // that are synchronized to the input clk
    wire [WIDTH-1:0] inter;

    REGISTER #(WIDTH) dreg1(.clk(clk), .q(inter), .d(async_signal));
    REGISTER #(WIDTH) dreg2(.clk(clk), .q(sync_signal), .d(inter));


	    // Remove this line once you create your synchronize


endmodule