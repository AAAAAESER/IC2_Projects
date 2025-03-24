module storage_layer #(
    parameter DATA_WIDTH = 6,        // 每个数据位宽
    parameter NUM_ELEMENTS = 16      // 存储元素的数量（假设每个存储模块存储 16 个元素）
)(
    input wire clk,                    // 时钟信号
    input wire reset,                  // 复位信号
    input wire valid,           // 写使能信号
    input wire [DATA_WIDTH-1:0] data_in_0,  // 存储池化模块0的输出数据
    input wire [DATA_WIDTH-1:0] data_in_1,  // 存储池化模块1的输出数据
    input wire [DATA_WIDTH-1:0] data_in_2,  // 存储池化模块2的输出数据
    input wire [DATA_WIDTH-1:0] data_in_3,  // 存储池化模块3的输出数据
    input wire [DATA_WIDTH-1:0] data_in_4,  // 存储池化模块4的输出数据
    input wire [DATA_WIDTH-1:0] data_in_5,  // 存储池化模块5的输出数据
    
    output wire [DATA_WIDTH*NUM_ELEMENTS-1:0] memory_0,  // 存储模块 0 输出
    output wire [DATA_WIDTH*NUM_ELEMENTS-1:0] memory_1,  // 存储模块 1 输出
    output wire [DATA_WIDTH*NUM_ELEMENTS-1:0] memory_2,  // 存储模块 2 输出
    output wire [DATA_WIDTH*NUM_ELEMENTS-1:0] memory_3,  // 存储模块 3 输出
    output wire [DATA_WIDTH*NUM_ELEMENTS-1:0] memory_4,  // 存储模块 4 输出
    output wire [DATA_WIDTH*NUM_ELEMENTS-1:0] memory_5   // 存储模块 5 输出
);

    // 定义 6 个存储模块，用于存储池化层的输出
    reg [DATA_WIDTH-1:0] memory_0_reg [0:NUM_ELEMENTS-1];
    reg [DATA_WIDTH-1:0] memory_1_reg [0:NUM_ELEMENTS-1];
    reg [DATA_WIDTH-1:0] memory_2_reg [0:NUM_ELEMENTS-1];
    reg [DATA_WIDTH-1:0] memory_3_reg [0:NUM_ELEMENTS-1];
    reg [DATA_WIDTH-1:0] memory_4_reg [0:NUM_ELEMENTS-1];
    reg [DATA_WIDTH-1:0] memory_5_reg [0:NUM_ELEMENTS-1];

    // 计数器，用于确定每次写入哪个位置
    reg [4:0] write_address;

    // 写操作
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            write_address <= 0; // 复位时计数器归零
        end else if (valid) begin
            // 将池化模块的输出数据写入对应的存储模块
            memory_0_reg[write_address] <= data_in_0;
            memory_1_reg[write_address] <= data_in_1;
            memory_2_reg[write_address] <= data_in_2;
            memory_3_reg[write_address] <= data_in_3;
            memory_4_reg[write_address] <= data_in_4;
            memory_5_reg[write_address] <= data_in_5;

            if (write_address == NUM_ELEMENTS-1)
                write_address <= 0;  // 达到最后一个位置后，归零计数器
            else
                write_address <= write_address + 1;  // 否则递增计数器
        end
    end

    // 将存储的结果输出到顶层模块
genvar i;
 

generate
      

for (i = 0; i <NUM_ELEMENTS ; i = i + 1)
	begin :cunchu       
    assign memory_0[(i+1)*5-1:i*5] = memory_0_reg[i];
    assign memory_1[(i+1)*5-1:i*5] = memory_1_reg[i];
    assign memory_2[(i+1)*5-1:i*5] = memory_2_reg[i];
    assign memory_3[(i+1)*5-1:i*5] = memory_3_reg[i];
    assign memory_4[(i+1)*5-1:i*5] = memory_4_reg[i];
    assign memory_5[(i+1)*5-1:i*5] = memory_5_reg[i];
end
  

endgenerate


endmodule
