module pool_top (
    input wire clk,                          // 时钟信号
    input wire rst,                          // 复位信号
    input wire valid,                 // 写使能信号
    input wire [5*3*3*6-1:0] data_in,       // 输入数据：6个通道的3x3矩阵，每个矩阵元素为6位
    output wire [5*16-1:0] memory_0,              // 存储模块 0 输出
    output wire [5*16-1:0] memory_1,              // 存储模块 1 输出
    output wire [5*16-1:0] memory_2,              // 存储模块 2 输出
    output wire [5*16-1:0] memory_3,              // 存储模块 3 输出
    output wire [5*16-1:0] memory_4,              // 存储模块 4 输出
    output wire [5*16-1:0] memory_5               // 存储模块 5 输出
);

    // 输出数据，池化后的结果
    wire [4:0] pool_data_out_0;
    wire [4:0] pool_data_out_1;
    wire [4:0] pool_data_out_2;
    wire [4:0] pool_data_out_3;
    wire [4:0] pool_data_out_4;
    wire [4:0] pool_data_out_5;

    // 实例化池化层模块
    pooling_layer #(
        .NUM_CHANNELS(6),
        .DATA_WIDTH(5),
        .MATRIX_DIM(3)
    ) pooling_inst (
        .data_in(data_in),                       // 输入数据（6通道，每个通道是一个3x3矩阵）
        .data_out({pool_data_out_5, pool_data_out_4, pool_data_out_3, pool_data_out_2, pool_data_out_1, pool_data_out_0}) // 池化结果输出
    );

    // 实例化存储模块
    storage_layer #(
        .DATA_WIDTH(5),
        .NUM_ELEMENTS(16)
    ) storage_inst (
        .clk(clk),                               // 时钟信号
        .reset(rst),                             // 复位信号
        .valid(valid),             // 写使能信号
        .data_in_0(pool_data_out_0),            // 从池化层得到的第0通道数据
        .data_in_1(pool_data_out_1),            // 从池化层得到的第1通道数据
        .data_in_2(pool_data_out_2),            // 从池化层得到的第2通道数据
        .data_in_3(pool_data_out_3),            // 从池化层得到的第3通道数据
        .data_in_4(pool_data_out_4),            // 从池化层得到的第4通道数据
        .data_in_5(pool_data_out_5),            // 从池化层得到的第5通道数据
        .memory_0(memory_0),                    // 存储模块 0 输出
        .memory_1(memory_1),                    // 存储模块 1 输出
        .memory_2(memory_2),                    // 存储模块 2 输出
        .memory_3(memory_3),                    // 存储模块 3 输出
        .memory_4(memory_4),                    // 存储模块 4 输出
        .memory_5(memory_5)                     // 存储模块 5 输出
    );

endmodule

