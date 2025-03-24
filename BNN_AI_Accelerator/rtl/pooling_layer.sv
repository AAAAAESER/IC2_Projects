module pooling_layer #(
    parameter NUM_CHANNELS = 6,        // 通道数
    parameter DATA_WIDTH = 6,          // 每个数据位宽
    parameter MATRIX_DIM = 3           // 输入矩阵的维度（3x3）
)(
    input wire [NUM_CHANNELS * MATRIX_DIM * MATRIX_DIM * DATA_WIDTH - 1:0] data_in, // 输入数据（每个通道的3x3矩阵）
    output wire [NUM_CHANNELS * DATA_WIDTH - 1:0] data_out    // 输出池化结果（每个通道一个池化值）
);

    // 生成多个并行的池化模块
    genvar i;
    generate
        for (i = 0; i < NUM_CHANNELS; i = i + 1) begin : gen_pooling_channel
            pooling_channel #(
                .DATA_WIDTH(DATA_WIDTH),
                .MATRIX_DIM(MATRIX_DIM)
            ) channel_inst (
                .data_in(data_in[(i+1)*MATRIX_DIM*MATRIX_DIM*DATA_WIDTH-1:i*MATRIX_DIM*MATRIX_DIM*DATA_WIDTH]),
                .data_out(data_out[(i+1)*DATA_WIDTH-1:i*DATA_WIDTH])
            );
        end
    endgenerate

endmodule
