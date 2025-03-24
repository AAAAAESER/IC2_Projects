module compare_probabilities # (
    parameter DATA_WIDTH = 9    // ����λ��
) (
    input clk,                  // ʱ���ź�
    input reset,                // �����ź�
    input [6*DATA_WIDTH-1:0] data_in,        // �����6�� 10 λ����
    input data_valid,           // ������Ч��־����ʾ�����Ƿ��Ѿ���Ч
    output wire [1:0] data_out, // ��������ʶ�Ӧ�����������������Σ����Ǹ�λ�����ǵ�λ
    output reg done            // ��־�������ʾ�Ƚ����
    // output reg soft_rst
);

    // �ڲ��ź�����
    //reg signed [14:0] prob [9:0];   // �洢10������
    wire signed [DATA_WIDTH+4-1:0] sum ;
    reg signed [DATA_WIDTH+4-1:0] max_val,max_val_next ;
    reg [3:0] counter;      // ���ڼ�������Ĵ���
    reg [3:0] max_index_next; // �����ʶ�Ӧ����������
    reg [3:0] max_index;    // �����ʶ�Ӧ����������
    // wire [10*15-1:0] max_val_out_w;
    // wire [10*4-1:0] max_index_out_w;
    reg [6*DATA_WIDTH-1:0] data_in_r;
    reg data_valid_r;
    // ���������봦��
    // always @(posedge clk or negedge reset) begin
    //     if (~reset) begin
    //         // ��λʱ�������״̬
    //         counter <= 0;
    //         sum<=0;
    //     end else if (data_valid) begin
    //         // ��������Чʱ������prob����
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
        // ���ռ����������ݺ󣬿�ʼ�Ƚ�������
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
       // max_val = prob[0]; // ��ʼ�����ֵ
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
        // �Ƚ��������ݣ��ҳ����ֵ��Ӧ������
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

