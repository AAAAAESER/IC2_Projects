module data(
    input clk,             // ʱ���ź�
    input rst_n,           // ��λ�źţ��͵�ƽ��Ч
    input mode,            // ģʽѡ���ź�,Ϊ1��Ȩ�ؼ��أ�Ϊ0�����ݼ��ؼ���	  
	input valid,			//�ⲿ�����źţ���ʾ��ʱ������Է����ź�
    input [15:0] data_in,  // ��16λ��������	  	 
	input weight_req,//��ʾȨ�ؾ���ʼ���¼���������	
    output  reg[15:0] weight0,// ���������ģ��
	output  reg[15:0] weight1,// ���������ģ��
	output  reg[15:0] weight2,// ���������ģ��
	output  reg[15:0] weight3,// ���������ģ��
	output  reg[15:0] weight4,// ���������ģ��				
	output  reg[15:0] weight5,// ���������ģ��
	output reg conv_data_pass,//����ģ���׼���ź�
	output  data0,
	output  data1,
	output  data2,
	output  data3,
	output  data4,
	output  data5,
	output  data6,
	output  data7,
	output  data8,
	output  data9,
	output  data10,
	output  data11,
	output  data12,
	output  data13,
	output  data14,
	output  data15
);

// �ڲ�����
reg [95:0] conv_weight_buffer;
reg [959:0] weight_buffer; // ���ڴ洢����Ȩ�صĻ�����
reg [10:0] weight_count;// ���ڼ���Ȩ���Ѿ����͵�λ������������Ȩ�ؾ���
reg [8:0] data_count;//���ڼ������׶���20x20�����Ѿ������ݵ�5x29�Ĵ����ڲ� 
reg data_buffer[63:0];//3x20+4�Ĵ������㵥Ԫ
reg [3:0] flag1;//�����ж�ÿ�μ���ʱ��Ҫ��������������λ�ʹ������
reg [3:0] flag2;//�����ж���������̵���ֹ
reg [3:0] flag3;


always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
        weight_count<=0;
	end
	else begin
		if(mode && valid)begin
			if (weight_count < 6) begin
				// First 6 chunks go into conv_weight_buffer
				conv_weight_buffer[(weight_count*16) +: 16] <= data_in;
				weight_count <= weight_count + 1;
			end
			else begin
				// Remaining 60 chunks go into weight_buffer
				weight_buffer[((weight_count - 6)*16) +: 16] <= data_in;
				if (weight_count == 65)
					weight_count <= 0;
				else
					weight_count <= weight_count + 1;
			end
		end
	end
end

integer i,j,k;

// �������봦��
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		flag1 <= 4'b0;
		flag2 <= 4'b0;
		data_count <= 9'd0;
		conv_data_pass <= 1'b0;
	end else begin
		// Only proceed in data mode when valid is high
		if ((!mode) && valid) begin

			// Reset conv_data_pass at the beginning of each new data sequence
			if (data_count == 0)
				conv_data_pass <= 1'b0;

			// First 64 bits load
			if (data_count < 64) begin
				// Shift
				// integer i;
				for (i = 63; i >= 2; i = i - 1)
					data_buffer[i] <= data_buffer[i - 2];
				
				// Quantize new bits
				data_buffer[1] <= (data_in[7:0] > 8'd127);
				data_buffer[0] <= (data_in[15:8] > 8'd127);

				data_count <= data_count + 2;

				if (data_count == 62) begin
					conv_data_pass <= 1'b1;
					flag1 <= flag1 + 1'b1;
				end

			// Next loads up to 400 bits
			end else if (data_count < 400) begin

				// Single-line shift
				if (flag1 < 9) begin
					flag2 <= 4'b0;
					// integer j;
					for (j = 63; j >= 2; j = j - 1)
						data_buffer[j] <= data_buffer[j - 2];
					
					data_buffer[1] <= (data_in[7:0] > 8'd127);
					data_buffer[0] <= (data_in[15:8] > 8'd127);

					if (data_count < 398) begin
						data_count <= data_count + 2;
						flag1 <= flag1 + 1'b1;
					end else begin
						data_count <= 9'd0;
						flag1 <= 4'b0;
					end

				// Double-line shift
				end else begin
					if (conv_data_pass)
						conv_data_pass <= 1'b0;

					// integer k;
					for (k = 63; k >= 2; k = k - 1)
						data_buffer[k] <= data_buffer[k - 2];
					
					data_buffer[1] <= (data_in[7:0] > 8'd127);
					data_buffer[0] <= (data_in[15:8] > 8'd127);

					data_count <= data_count + 2;
					flag2 <= flag2 + 1'b1;

					// After shifting two lines, re-enable conv_data_pass
					if (flag2 == 4'd11) begin
						flag1 <= 4'd1;
						conv_data_pass <= 1'b1;
					end
				end
			end
		end else if (data_count == 0)begin
			conv_data_pass <= 1'b0;
		end
	end
end




always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		flag3<=0;
	end else if (weight_req)begin	
		flag3<=flag3==10?0:flag3+1;
	end
end

always@(*)begin
		case (flag3)
		    0:begin
				weight0=conv_weight_buffer[15-:16];
				weight1=conv_weight_buffer[31-:16];
				weight2=conv_weight_buffer[47-:16];
				weight3=conv_weight_buffer[63-:16];
				weight4=conv_weight_buffer[79-:16];
				weight5=conv_weight_buffer[95-:16];
			end
			1:begin
				weight0=weight_buffer[15-:16];
				weight1=weight_buffer[31-:16];
				weight2=weight_buffer[47-:16];
				weight3=weight_buffer[63-:16];
				weight4=weight_buffer[79-:16];
				weight5=weight_buffer[95-:16];
			end 
			2:begin
				weight0=weight_buffer[111-:16];
				weight1=weight_buffer[127-:16];
				weight2=weight_buffer[143-:16];
				weight3=weight_buffer[159-:16];
				weight4=weight_buffer[175-:16];
				weight5=weight_buffer[191-:16];
			end
			3:begin
				weight0=weight_buffer[207-:16];
				weight1=weight_buffer[223-:16];
				weight2=weight_buffer[239-:16];
				weight3=weight_buffer[255-:16];
				weight4=weight_buffer[271-:16];
				weight5=weight_buffer[287-:16];
			end
			4:begin
				weight0=weight_buffer[303-:16];
				weight1=weight_buffer[319-:16];
				weight2=weight_buffer[335-:16];
				weight3=weight_buffer[351-:16];
				weight4=weight_buffer[367-:16];
				weight5=weight_buffer[383-:16];	
			end
			5:begin
				weight0=weight_buffer[399-:16];
				weight1=weight_buffer[415-:16];
				weight2=weight_buffer[431-:16];
				weight3=weight_buffer[447-:16];
				weight4=weight_buffer[463-:16];
				weight5=weight_buffer[479-:16];
			end
			6:begin
				weight0=weight_buffer[495-:16];
				weight1=weight_buffer[511-:16];
				weight2=weight_buffer[527-:16];
				weight3=weight_buffer[543-:16];
				weight4=weight_buffer[559-:16];
				weight5=weight_buffer[575-:16];
			end
			7:begin
				weight0=weight_buffer[591-:16];
				weight1=weight_buffer[607-:16];
				weight2=weight_buffer[623-:16];
				weight3=weight_buffer[639-:16];
				weight4=weight_buffer[655-:16];
				weight5=weight_buffer[671-:16];
			end
			8:begin
				weight0=weight_buffer[687-:16];
				weight1=weight_buffer[703-:16];
				weight2=weight_buffer[719-:16];
				weight3=weight_buffer[735-:16];
				weight4=weight_buffer[751-:16];
				weight5=weight_buffer[767-:16];
			end
			9:begin
				weight0=weight_buffer[783-:16];
				weight1=weight_buffer[799-:16];
				weight2=weight_buffer[815-:16];
				weight3=weight_buffer[831-:16];
				weight4=weight_buffer[847-:16];
				weight5=weight_buffer[863-:16];
			end
			10:begin
				weight0=weight_buffer[879-:16];
				weight1=weight_buffer[895-:16];
				weight2=weight_buffer[911-:16];
				weight3=weight_buffer[927-:16];
				weight4=weight_buffer[943-:16];
				weight5=weight_buffer[959-:16];
			end

			default: begin
				weight0=0;
				weight1=0;
				weight2=0;
				weight3=0;
				weight4=0;
				weight5=0;
			end
		endcase
end
		

assign data0=data_buffer[63];
assign data1=data_buffer[62];
assign data2=data_buffer[61];
assign data3=data_buffer[60];
assign data4=data_buffer[43];
assign data5=data_buffer[42];
assign data6=data_buffer[41];
assign data7=data_buffer[40];
assign data8=data_buffer[23];
assign data9=data_buffer[22];
assign data10=data_buffer[21];
assign data11=data_buffer[20];
assign data12=data_buffer[3];
assign data13=data_buffer[2];
assign data14=data_buffer[1];
assign data15=data_buffer[0];

  


	

endmodule