module data(
    input clk,             // ʱ���ź�
    input rst_n,           // ��λ�źţ��͵�ƽ��Ч
    input mode,            // ģʽѡ���ź�,Ϊ1��Ȩ�ؼ��أ�Ϊ0�����ݼ��ؼ���	  
	input over,             //����12�־���˴�����ɵĽ����ź�
	input valid,			//�����ź�
    input [7:0] data_in,  // ����ʮ���־���ˣ�ÿһ����25λ��������
    output reg [24:0] weight0,// ʮ���������ģ��
	output reg [24:0] weight1,// ʮ���������ģ��
	output reg [24:0] weight2,// ʮ���������ģ��
	output reg [24:0] weight3,// ʮ���������ģ��
	output reg [24:0] weight4,// ʮ���������ģ��
	output reg [24:0] weight5,// ʮ���������ģ��
	output reg [24:0] weight6,// ʮ���������ģ��
	output reg [24:0] weight7,// ʮ���������ģ��
	output reg [24:0] weight8,// ʮ���������ģ��
	output reg [24:0] weight9,// ʮ���������ģ��
	output reg [24:0] weight10,// ʮ���������ģ��
	output reg [24:0] weight11,// ʮ���������ģ��
	output reg conv_process,//����ģ���׼���ź�
	output [7:0] data0,
	output [7:0] data1,
	output [7:0] data2,
	output [7:0] data3,
	output [7:0] data4,
	output [7:0] data5,
	output [7:0] data6,
	output [7:0] data7,
	output [7:0] data8,
	output [7:0] data9,
	output [7:0] data10,
	output [7:0] data11,
	output [7:0] data12,
	output [7:0] data13,
	output [7:0] data14,
	output [7:0] data15,
	output [7:0] data16,
	output [7:0] data17,
	output [7:0] data18,
	output [7:0] data19,
	output [7:0] data20,
	output [7:0] data21,
	output [7:0] data22,
	output [7:0] data23,
	output [7:0] data24,
	output  ready
);

// �ڲ�����
reg [299:0] weight_buffer; // ���ڴ洢����Ȩ�صĻ�����
reg [9:0] weight_count;// ���ڼ���Ȩ���Ѿ����͵�λ��
reg [9:0] data_count;//���ڼ������׶���28x28�����Ѿ������ݵ�5x29�Ĵ����ڲ�
reg [7:0] data_buffer[144:0];//5x29�Ĵ������㵥Ԫ
reg [1:0] flag1;//�����ж�ÿ�μ���ʱ��Ҫ��������������λ�ʹ������
reg [5:0] flag2;//�����ж���������̵���ֹ
integer i=0;
integer j=0;
integer k=0; 
integer a=0;

//ssaa
// ��ʱ�������ش�������
always @(posedge clk or negedge rst_n)
begin  
// ��λ�߼�
if (!rst_n) begin
        weight_buffer <= 0;
        weight_count <= 0;
		weight0 <= 25'd0;
		weight1 <= 25'd0;
		weight2 <= 25'd0;
		weight3 <= 25'd0;
		weight4 <= 25'd0;
		weight5 <= 25'd0;
		weight6 <= 25'd0;
		weight7 <= 25'd0;
		weight8 <= 25'd0;
		weight9 <= 25'd0;
		weight10 <= 25'd0;
		weight11 <= 25'd0;
		flag1<=0;  
		flag2<=0;
		for (a=0;a<145;a=a+1)begin
		data_buffer[a]<=8'b0;
		end		   
		data_count<=10'b0;
end 		   
//��modeΪ1��ʱ�����Ȩ�ؼ���
else if (mode&&valid) begin
	 if (weight_count <296) begin
            weight_buffer[weight_count +: 8] <= data_in;// ���������ݵĵ�8λд�뻺����
			weight_count <= weight_count + 8;	//�Ѿ�д��ȥ��λ�����ϼ�8  
	 end
	 if (weight_count==296) begin
		 weight_buffer[weight_count +: 4] <= data_in[3:0];//����ĸ����ݵ�������ʱ������������ֻ��Ҫ�����ĸ� ��ע������ߵ�λ˳��	
		 weight_count <= weight_count + 4;	//���д��ȥ��λ����4
	 end

//���Ѿ��ڻ��������д�õ�����ֱ�Ӹ���Ӧ�����		
	        if (weight_count>24)begin
			weight0<=weight_buffer[24-:25];
			end
		    if (weight_count>49)begin
			weight1<=weight_buffer[49-:25];
			end
		    if (weight_count>74)begin
			weight2<=weight_buffer[74-:25];
			end
		    if (weight_count>99)begin
			weight3<=weight_buffer[99-:25];	
			end
		    if (weight_count>124)begin
			weight4<=weight_buffer[124-:25];
			end
		    if (weight_count>149)begin
			weight5<=weight_buffer[149-:25]; 
			end
		    if (weight_count>174)begin
			weight6<=weight_buffer[174-:25]; 
			end
		    if (weight_count>199)begin
			weight7<=weight_buffer[199-:25];
			end
		    if (weight_count>224)begin
			weight8<=weight_buffer[224-:25];
			end
		    if (weight_count>249)begin
			weight9<=weight_buffer[249-:25];
			end
		    if (weight_count>274)begin
			weight10<=weight_buffer[274-:25];
			end
		    if (weight_count>299) begin
			weight11<=weight_buffer[299-:25];
			end
end		
//ģʽ�л�   
else if (!mode&&valid)begin
   //�ȴ���ʼ��145������ȫ�����������
   if (data_count<145)begin    
      for (i=0;i<144;i=i+1)begin 
        data_buffer[144-i]<=data_buffer[144-i-1];   
      end
      data_buffer[0]<=data_in;	//����ÿ�˸������ȥ
	  data_count<=data_count+1;//���ݴ���λ������
   end
   
   else if ((data_count>144)&&(data_count<841))begin
	   if (flag1==0)begin
	   conv_process<=1'b1;//����˴���׼���ź�ʹ��	   
	   end	 
	   else begin
	   conv_process<=1'b0;//����˴���׼���źŹض�
	   end
	   //�ڴ�����̵��н��������������´���
	   if (flag1<2)begin
         for (j=0;j<144;j=j+1)begin 
           data_buffer[144-j]<=data_buffer[144-j-1]; 
	     end
         data_buffer[0]<=data_in;	//����ÿ�˸������ȥ    	  
	   //��¼�ܹ�д���˶������ݣ����ڲ���Ϊ2��������ÿ��д����������
	     data_count<=data_count+1;
	     flag1<=flag1+1;	
	   end				   
	   //�����ξ�������ݴ�������Ժ���Ҫָʾԭ���ļĴ������½���д������
	   //��over��process������һ������0,1��ʾ��
	   if (over==1)begin
	     flag1<=0;  
	   end	
   end
   //���е������Ѿ�ȫ��д�뵽�Ĵ������У�ֻ����λ�ʹ���������
   else if (data_count==841&&flag2<25)begin
	   //����˴���׼���ź�ʹ��
	   if (flag1==0)begin
	   conv_process<=1'b1;
	   end				
       else begin
	   conv_process<=1'b0;//����˴���׼���źŹض�
	   end
	   //���ظ����ݽ�������5x5���㵥Ԫǰ����Ȼ��Ҫ�ڼ�������λ�������㲽��Ҫ��
	   if (flag1<2)begin
	   //flag2��ʾ���ǵ��Ѿ�û���µ����ݸ������5x29�ļĴ�����ʱ��Ϊ�˷�ֹ�д����ظ������ݱ�����˻������
	   //��Ҫ��24����λ������Ĵ�����λ��������ֹ���㡣
	     flag2<=flag2+1;
         for (k=0;k<144;k=k+1)begin 
           data_buffer[144-k]<=data_buffer[144-k-1];
		 end
		 flag1<=flag1+1;
	   end	
	   
	   //������������źŷ���ʱ����Ҫ��flag1����������м���
	   if (over==1)begin
		   flag1<=0;
	   end
   end
   else begin 
	conv_process<=1'b0;
   end
	   	      
end   


end

assign data0=data_buffer[144];
assign data1=data_buffer[143];
assign data2=data_buffer[142];
assign data3=data_buffer[141];
assign data4=data_buffer[140];
assign data5=data_buffer[115];
assign data6=data_buffer[114];
assign data7=data_buffer[113];
assign data8=data_buffer[112];
assign data9=data_buffer[111];
assign data10=data_buffer[86];
assign data11=data_buffer[85];
assign data12=data_buffer[84];
assign data13=data_buffer[83];
assign data14=data_buffer[82];
assign data15=data_buffer[57];
assign data16=data_buffer[56];
assign data17=data_buffer[55];
assign data18=data_buffer[54];
assign data19=data_buffer[53];
assign data20=data_buffer[28];
assign data21=data_buffer[27];
assign data22=data_buffer[26];
assign data23=data_buffer[25];
assign data24=data_buffer[24];


assign ready=(flag1<2)?valid:0;
	 
endmodule