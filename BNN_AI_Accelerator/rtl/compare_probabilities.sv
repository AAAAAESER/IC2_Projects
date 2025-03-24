module compare_probabilities # (
    parameter DATA_WIDTH = 9    // 数据位宽
) (
    input clk,                  // 时钟信号
    input reset,                // 重置信号
    input [6*DATA_WIDTH-1:0] data_in,        // 输入的6个 10 位数据
    input data_valid,           // 数据有效标志，表示数据是否已经有效
    output wire [1:0] data_out, // 输出最大概率对应的数字索引，分两次，先是高位，再是低位
    output reg done            // 标志输出，表示比较完成
    // output reg soft_rst
);

    // 内部信号声明
    //reg signed [14:0] prob [9:0];   // 存储10个数据
    wire signed [DATA_WIDTH+4-1:0] sum ;
    reg signed [DATA_WIDTH+4-1:0] max_val,max_val_next ;
    reg [3:0] counter;      // 用于计数输入的次数
    reg [3:0] max_index_next; // 最大概率对应的数字索引
    reg [3:0] max_index;    // 最大概率对应的数字索引
    // wire [10*15-1:0] max_val_out_w;
    // wire [10*4-1:0] max_index_out_w;
    reg [6*DATA_WIDTH-1:0] data_in_r;
    reg data_valid_r;
    // 数据输入与处理
    // always @(posedge clk or negedge reset) begin
    //     if (~reset) begin
    //         // 复位时清除所有状态
    //         counter <= 0;
    //         sum<=0;
    //     end else if (data_valid) begin
    //         // 当数据有效时，存入prob数组
    //         //prob[counter] <= $signed(data_in[0+:10])+$signed(data_in[10+:10])+$signed(data_in[20+:10])+$signed(data_in[30+:10])
    //         //                    +$signed(data_in[40+:10])+$signed(data_in[50+:10]);
    //         counter <= counter + 1;
    //         sum <= $signed(data_in[0+:10])+$signed(data_in[10+:10])+$signed(data_in[20+:10])+$signed(data_in[30+:10])
    //                             +$signed(data_in[40+:10])+$signed(data_in[50+:10]);
                            
    //     end
    // end
    always @(posedge clk or negedge reset) begin
        if(!reset)begin
            data_valid_r <= 0;
        end
        else begin
            data_valid_r <= data_valid;
            data_in_r <= data_in;
        end
    end
    assign sum = $signed(data_in_r[0+:DATA_WIDTH])+$signed(data_in_r[DATA_WIDTH+:DATA_WIDTH])+$signed(data_in_r[DATA_WIDTH*2+:DATA_WIDTH])
                +$signed(data_in_r[DATA_WIDTH*3+:DATA_WIDTH])+$signed(data_in_r[DATA_WIDTH*4+:DATA_WIDTH])+$signed(data_in_r[DATA_WIDTH*5+:DATA_WIDTH]);
    always @(posedge clk or negedge reset) begin
        // 当收集完所有数据后，开始比较最大概率
        if(~reset)begin
            max_index <= 0;
            max_val<={1'b1,{(DATA_WIDTH+4-1){1'b0}}};
            done <= 0;
            counter <=0;
            // soft_rst<=0;
        end else begin
            if(counter<10)begin
                if(data_valid_r)begin
                    max_index <= max_index_next;
                    max_val<=max_val_next;
                    counter <= counter +1;
                end
            end
            else begin
                if(counter==10)begin
                    done<=1;
                    counter<=counter+1;
                end
                else if(counter==11)begin
                    counter<=counter+1;
                    // soft_rst<=1;
                end
                else begin
                    counter<=0;
                    max_index <= 0;
                    max_val<={1'b1,{(DATA_WIDTH+4-1){1'b0}}};
                    done <= 0;
                    // soft_rst<=0;
                end
            end
            // if (counter == 10) begin
            //     // max_index <= max_index_out_w[9*4+:4];
            // end
        end
    end
    assign data_out = (counter==11)?max_index[3:2]:(counter==12?max_index[1:0]:2'b0);
    // assign max_val_out_w[0+:15] =prob[0];
    // assign max_index_out_w[0+:4]=4'b0;
    // generate
    //     genvar j;
    //     for(j=1;j<10;j=j+1)begin:comp
    //         assign max_val_out_w[j*15+:15] = (prob[j] > $signed(max_val_out_w[(j-1)*15+:15])) ? prob[j] :max_val_out_w[(j-1)*15+:15];
    //         assign max_index_out_w[j*4+:4] = (prob[j] > $signed(max_val_out_w[(j-1)*15+:15])) ? j :max_index_out_w[(j-1)*4+:4];
    //     end
    // endgenerate
    
    // integer i;
    always@(*)begin
       // max_val = prob[0]; // 初始化最大值
        // max_val_next = 0;
        if ($signed(sum)>max_val) begin
            max_val_next =sum;
            max_index_next =counter;
        end
        else begin
            max_val_next =max_val;
            max_index_next =max_index;  
        end
    end
        // 比较所有数据，找出最大值对应的索引
        //for (i = 1; i < 10; i = i + 1) begin
        //    if (prob[i] > max_val) begin
        //      max_val_next = i;
        //        max_val = prob[i];
        //    end
        //   else begin
        //        max_val_next = max_val_next;
        //        max_val = max_val;
        //    end
        //end
    //end

endmodule

