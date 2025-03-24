module pooling_channel #(
  

parameter DATA_WIDTH = 6,    // 数据位宽
   

parameter MATRIX_DIM = 3     // 输入矩阵维度 (3x3)

)
(
  


input  wire [MATRIX_DIM*MATRIX_DIM*DATA_WIDTH-1:0] data_in, // 输入数据：3x3矩阵，每个元素为DATA_WIDTH位
   

output wire [DATA_WIDTH-1:0] data_out                      // 输出数据：最大池化值
);

   

// 内部信号
 

wire [DATA_WIDTH-1:0] elements [MATRIX_DIM*MATRIX_DIM-1:0]; // 展开后的矩阵元素

  

// 提取输入数据
   

genvar i;
 

generate
      

for (i = 0; i < MATRIX_DIM*MATRIX_DIM; i = i + 1) begin : extract_data
     

assign elements[i] = data_in[(5*9-1-i*DATA_WIDTH)-: DATA_WIDTH];
  

end
  

endgenerate

    
// 比较逻辑：逐步比较所有 9 个元素，找出最大值
   

wire [DATA_WIDTH-1:0] max_1, max_2, max_3, max_4, max_5, max_6, max_7, max_8;

 

assign max_1 = ($signed(elements[0]) > $signed(elements[1])) ? $signed(elements[0]) : $signed(elements[1]);
  

assign max_2 = ($signed(elements[2]) > $signed(elements[3])) ? $signed(elements[2]) : $signed(elements[3]);  

assign max_3 = ($signed(elements[4]) > $signed(elements[5])) ? $signed(elements[4]) : $signed(elements[5]);
   

assign max_4 = ($signed(elements[6]) > $signed(elements[7])) ? $signed(elements[6]) : $signed(elements[7]);  

assign max_5 = ($signed(max_1) > $signed(max_2)) ? $signed(max_1) : $signed(max_2);
  

assign max_6 = ($signed(max_3) >$signed(max_4)) ? $signed(max_3) : $signed(max_4);
  

assign max_7 = ($signed(max_5) > $signed(max_6)) ? $signed(max_5) :$signed(max_6);
  

assign max_8 = ($signed(max_7) > $signed(elements[8])) ? $signed(max_7) : $signed(elements[8]);

 

// 控制输出仅在 valid 高时有效
 

assign data_out = max_8 ;



endmodule