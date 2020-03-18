`include "../../lib/EECS151.v"

module debouncer #(
    parameter WIDTH              = 1,
    parameter SAMPLE_CNT_MAX     = 25000,
    parameter PULSE_CNT_MAX      = 150,
    parameter WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX) + 1,
    parameter SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1)
(
    input clk,
    input [WIDTH-1:0] glitchy_signal,
    output [WIDTH-1:0] debounced_signal
);

    // TODO: fill in neccesary logic to implement the wrapping counter and the saturating counters
    // Some initial code has been provided to you, but feel free to change it however you like
    // One wrapping counter is required
    // One saturating counter is needed for each bit of debounced_signal
    // You need to think of the conditions for reseting, clock enable, etc. those registers
    // Refer to the block diagram in the spec

    wire [WRAPPING_CNT_WIDTH-1:0] wrapping_cnt_val;
    wire [WRAPPING_CNT_WIDTH-1:0] wrapping_cnt_next;
    wire reset;

    REGISTER_R #(.N(WRAPPING_CNT_WIDTH)) wrapping_cnt(.q(wrapping_cnt_val), .d(wrapping_cnt_next), .rst(reset), .clk(clk));
    assign reset =  (wrapping_cnt_val == SAMPLE_CNT_MAX);
    
    wire [WIDTH-1:0] inter_signal;
    
    REGISTER_CE #(WIDTH) detect(.q(inter_signal), .d(glitchy_signal), .ce(reset), .clk(clk));
    assign wrapping_cnt_next = wrapping_cnt_val + 1;

    wire [SAT_CNT_WIDTH-1:0] sat_cnt_val[WIDTH-1:0];
    wire [SAT_CNT_WIDTH-1:0] sat_cnt_next[WIDTH-1:0];
    wire [WIDTH-1:0] sat_cnt_rst;
    wire [WIDTH-1:0] sat_cnt_ce;
    
    wire [WIDTH-1:0] delete;
   genvar n;
   generate
    for (n = 0; n < WIDTH; n = n + 1) begin
        assign delete[n] = !(inter_signal[n] & glitchy_signal[n]);
    end
    endgenerate
    
    
    genvar k;
    generate
        for (k = 0; k < WIDTH; k = k + 1) begin: label
            assign sat_cnt_ce[k] = !(sat_cnt_val[k] == PULSE_CNT_MAX);
            assign sat_cnt_rst[k] = (!inter_signal[k]) & glitchy_signal[k];
        end
    endgenerate
    

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin
            assign sat_cnt_next[i] = sat_cnt_val[i] + 1;
            REGISTER_R_CE #(.N(SAT_CNT_WIDTH)) sat_cnt (.q(sat_cnt_val[i]), .d(sat_cnt_next[i]), .rst(sat_cnt_rst[i]), .ce(sat_cnt_ce[i]), .clk(clk));
        end
    endgenerate

    genvar j;
    generate
        for (j = 0; j < WIDTH; j = j + 1) begin
            assign debounced_signal[j] = (sat_cnt_val[j] == PULSE_CNT_MAX) & (!delete[j]);
        end
    endgenerate

endmodule