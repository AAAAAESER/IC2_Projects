module top(
    input clk,
    input rst_n,
    input mode_port,
    input [15:0]data_in_port,
    input in_valid_port,
    output [1:0]data_out_port,
    output in_ready_port,
    output out_en_port
);
parameter CHANNEL_NUM = 6;
//data in and out 3-state-gate
wire data_out_en;
// assign data_out_en = 1'b0;//test
assign out_en_port = data_out_en;
wire [15:0] data_in;
wire [1:0]data_out;
assign data_out_port = data_out;
assign data_in = data_in_port;
wire [CHANNEL_NUM*16-1:0] weight;
wire weight_req;//,weight_OK;

wire data2conv_valid;
wire conv2slide_valid;
wire slilde2pool_valid;
// wire pool2fc_valid;
wire fc2out_valid;

wire [16-1:0]data_in2conv;
wire [CHANNEL_NUM*5-1:0]data_conv2slide;
wire [CHANNEL_NUM*9*5-1:0]data_slide2pool;
wire [CHANNEL_NUM*16*5-1:0]data_pool2fc;
wire [CHANNEL_NUM*9-1:0]data_fc2out;

assign in_ready_port = 1'b1;
// wire soft_rst;

data u_data(
    .clk            (clk                ),//input
    .rst_n          (rst_n              ),//input
    .mode           (mode_port          ),//input
    .valid          (in_valid_port      ),//input
    .data_in        (data_in            ),//input
    .weight_req     (weight_req         ),//input
    // .weight_rst     (soft_rst           ),//input
    // .weight_OK      (weight_OK          ),//output
    .weight0        (weight[15:0]       ),//output
    .weight1        (weight[31:16]      ),//output
    .weight2        (weight[47:32]      ),//output
    .weight3        (weight[63:48]      ),//output
    .weight4        (weight[79:64]      ),//output
    .weight5        (weight[95:80]      ),//output
    .conv_data_pass (data2conv_valid     ),//output
    .data0          (data_in2conv[0]  ),//output
    .data1          (data_in2conv[1]  ),//output
    .data2          (data_in2conv[2]  ),//output
    .data3          (data_in2conv[3]  ),//output
    .data4          (data_in2conv[4]  ),//output
    .data5          (data_in2conv[5]  ),//output
    .data6          (data_in2conv[6]  ),//output
    .data7          (data_in2conv[7]  ),//output
    .data8          (data_in2conv[8]  ),//output
    .data9          (data_in2conv[9]  ),//output
    .data10         (data_in2conv[10] ),//output
    .data11         (data_in2conv[11] ),//output
    .data12         (data_in2conv[12] ),//output
    .data13         (data_in2conv[13] ),//output
    .data14         (data_in2conv[14] ),//output
    .data15         (data_in2conv[15] )//output
    // .ready          (in_ready_port      ) //output
);



conv_top #(
      .CONV_DATA_WIDTH(1),
      .FC_DATA_WIDTH(5),
      .K(4),
      .LOGK(4),
      .CH_NUM(6)
    ) u_conv_top(
    // Clock input
    .clk            (clk            ), // input
    .rstn           (rst_n           ), // input
    .conv_valid     (data2conv_valid ), // input
    // .conv_ready     (      ), // output
    // .fc_valid       (pool2fc_valid), // input
    // .fc_ready       (       ), // output
    // .weight_ready   (weight_OK      ), // input
    .weight_req     (weight_req    ), // output
    .out_conv_valid (conv2slide_valid ), // output
    .out_fc_valid   (fc2out_valid   ), // output
    .weight         (weight         ), // input
    .conv_data_in   (data_in2conv   ), // input
    .conv_data_out  (data_conv2slide), // output
    .fc_data_in     (data_pool2fc   ), // input
    .fc_data_out    (data_fc2out    )  // output
);

conv_slide #(
      .CH_NUM(CHANNEL_NUM),
      .DATA_WIDTH(5),
      .K(3),
      .LEN(9)
    )u_conv_slide(
    .clk    (clk    ),//input
    .rstn   (rst_n   ),//input
    .ivalid (conv2slide_valid ),//input
    .idata  (data_conv2slide  ),//input
    .dout   (data_slide2pool   ),//output
    .ovalid (slilde2pool_valid ) //output
);

pool_top u_pool_top(
    .clk      (clk      ),//input
    .rst      (rst_n      ),//input
    .valid    (slilde2pool_valid),//input
    .data_in  (data_slide2pool  ),//input
    .memory_0 (data_pool2fc[0     +:16*5]),//output
    .memory_1 (data_pool2fc[16*5*1+:16*5] ),//output
    .memory_2 (data_pool2fc[16*5*2+:16*5] ),//output
    .memory_3 (data_pool2fc[16*5*3+:16*5] ),//output
    .memory_4 (data_pool2fc[16*5*4+:16*5] ),//output
    .memory_5 (data_pool2fc[16*5*5+:16*5] ) //output
);

compare_probabilities u_compare_probabilities(
    .clk        (clk        ),
    .reset      (rst_n      ),
    .data_in    (data_fc2out    ),
    .data_valid (fc2out_valid ),
    .data_out  (data_out   ),
    .done       (data_out_en )
    // .soft_rst   (soft_rst   )
);

endmodule