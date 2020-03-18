`include "../../lib/EECS151.v"

// Source: https://www.ibm.com/support/knowledgecenter/P8DEA/p8egb/p8egb_supportedresolution.htm
module display_controller #(

    // Video resolution parameters for 800x600 @60Hz -- pixel_freq = 40 MHz
    parameter H_ACTIVE_VIDEO = 800,
    parameter H_FRONT_PORCH  = 40,
    parameter H_SYNC_WIDTH   = 128,
    parameter H_BACK_PORCH   = 88,

    parameter V_ACTIVE_VIDEO = 600,
    parameter V_FRONT_PORCH  = 1,
    parameter V_SYNC_WIDTH   = 4,
    parameter V_BACK_PORCH   = 23

) (
    input pixel_clk,

    input [23:0] pixel_stream_din,
    input pixel_stream_din_valid,
    output pixel_stream_din_ready,

    // video signals
    output [23:0] video_out_pData,
    output video_out_pHSync,
    output video_out_pVSync,
    output video_out_pVDE
);

    // Some hints for you to get started
    localparam H_FRAME = H_ACTIVE_VIDEO + H_FRONT_PORCH + H_SYNC_WIDTH + H_BACK_PORCH;
    localparam V_FRAME = V_ACTIVE_VIDEO + V_FRONT_PORCH + V_SYNC_WIDTH + V_BACK_PORCH;

    wire [31:0] x_pixel_val, x_pixel_next;
    wire x_pixel_ce, x_pixel_rst;
    wire [31:0] y_pixel_val, y_pixel_next;
    wire y_pixel_ce, y_pixel_rst;

    // x_pixel: 0 ---> H_FRAME
    // y_pixel: 0 ---> V_FRAME
    REGISTER_R_CE #(.N(32), .INIT(0)) x_pixel (
        .q(x_pixel_val),
        .d(x_pixel_next),
        .ce(x_pixel_ce),
        .rst(x_pixel_rst),
         .clk(pixel_clk));
    assign x_pixel_next = x_pixel_val + 1;
    
    REGISTER_R_CE #(.N(32), .INIT(0)) y_pixel (
        .q(y_pixel_val),
        .d(y_pixel_next),
        .ce(y_pixel_ce),
        .rst(y_pixel_rst),
        .clk(pixel_clk));
    assign y_pixel_next = y_pixel_val + 1;
    
    assign x_pixel_rst = (x_pixel_next == H_FRAME);
    assign y_pixel_rst = (y_pixel_next == V_FRAME) && (x_pixel_next == H_FRAME);
    
    assign x_pixel_ce = 1;
    assign y_pixel_ce = (x_pixel_next == H_FRAME);
    
    assign video_out_pHSync = (x_pixel_val < H_ACTIVE_VIDEO + H_FRONT_PORCH + H_SYNC_WIDTH
                               && x_pixel_val >= H_ACTIVE_VIDEO + H_FRONT_PORCH) ? 1'b1 : 0;
    
    assign video_out_pVSync = (y_pixel_val < V_ACTIVE_VIDEO + V_FRONT_PORCH + V_SYNC_WIDTH
                               && y_pixel_val >= V_ACTIVE_VIDEO + V_FRONT_PORCH) ? 1'b1 : 0;
    
    assign video_out_pVDE = (x_pixel_val < H_ACTIVE_VIDEO && y_pixel_val < V_ACTIVE_VIDEO) ? 1 : 0;
    
    // TODO: fill in the remaining logic to implement the display controller
    // Make sure your signals meet the timing specification for HSync, VSync, and Video Active
    // For task 1, do not worry about the 'pixel_stream_din', just set 'video_out_pData'
    // to some constant value to test if your code works with a monitor
    // For task 2, you need to implement proper control logic to enqueue the 'pixel_stream_din'

    assign video_out_pData = (pixel_stream_din_valid == 1) ? pixel_stream_din : 0;
    assign pixel_stream_din_ready = ((x_pixel_val >= H_ACTIVE_VIDEO  && x_pixel_val < H_FRAME)
                                    || (y_pixel_val >= V_ACTIVE_VIDEO  && y_pixel_val < V_FRAME))
     ? 0 : 1;
    
//    assign video_out_pData = pixel_stream_din; // task 2

endmodule
