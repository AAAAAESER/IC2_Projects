module FC_by_cov_1_1(
    input [8:0]single_pixel_in,      //8bit date+1bit signed bit
    input single_bw,                
    output [8:0]single_pixel_out     //input and output are all 2's complement
);
    wire [8:0]single_pixel_out_temp;
    wire [8:0]single_bw_9b;
    assign single_bw_9b = {9{single_bw}};
    assign single_pixel_out_temp = single_pixel_in ~^ single_bw_9b;
    assign single_pixel_out = single_pixel_out_temp + {8'b0,~single_bw};
endmodule