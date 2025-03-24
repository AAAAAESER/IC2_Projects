module data(
    input clk,             // ʱ���ź�
    input rst_n,           // ��λ�źţ��͵�ƽ��Ч
    input mode,            // ģʽѡ���ź�,Ϊ1��Ȩ�ؼ��أ�Ϊ0�����ݼ��ؼ���	  
	input valid,			//�ⲿ�����źţ���ʾ��ʱ������Է����ź�
    input [15:0] data_in,  // ����ʮ���־���ˣ�ÿһ����25λ��������	  	 
	input weight_req,//��ʾȨ�ؾ���ʼ���¼���������	 
	output reg weight_OK,//��ʾ����Ȩ�ؼ���ȫ�����
    output reg [15:0] weight0,// ���������ģ��
	output reg [15:0] weight1,// ���������ģ��
	output reg [15:0] weight2,// ���������ģ��
	output reg [15:0] weight3,// ���������ģ��
	output reg [15:0] weight4,// ���������ģ��
	output reg [15:0] weight5,// ���������ģ��
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
	output  data15,
	output  ready//��ʾ��ʱ���Խ�����������
);

// �ڲ�����
//reg [95:0] weight_buffer; // ���ڴ洢����Ȩ�صĻ�����
reg [7:0] weight_count;// ���ڼ���Ȩ���Ѿ����͵�λ������������Ȩ�ؾ���
reg [9:0] data_count;//���ڼ������׶���28x28�����Ѿ������ݵ�5x29�Ĵ����ڲ� 
reg data_buffer[63:0];//3x20+4�Ĵ������㵥Ԫ
reg [3:0] flag1;//�����ж�ÿ�μ���ʱ��Ҫ��������������λ�ʹ������
reg [2:0] flag2;//�����ж���������̵���ֹ 
integer i;



// ��ʱ�������ش�������
always @(posedge clk or negedge rst_n)
begin  

	
// ��λ�߼�
if (!rst_n) begin
	    weight_OK<= 0;
        weight_count <= 0;
		weight0 <= 16'd0;
		weight1 <= 16'd0;
		weight2 <= 16'd0;
		weight3 <= 16'd0;
		weight4 <= 16'd0;
		weight5 <= 16'd0;
		flag1<=0;  
		flag2<=0; 
		data_buffer[0] <= 1'b0;
        data_buffer[1] <= 1'b0;
        data_buffer[2] <= 1'b0;
        data_buffer[3] <= 1'b0;
        data_buffer[4] <= 1'b0;
        data_buffer[5] <= 1'b0;
        data_buffer[6] <= 1'b0;
        data_buffer[7] <= 1'b0;
        data_buffer[8] <= 1'b0;
        data_buffer[9] <= 1'b0;
        data_buffer[10] <= 1'b0;
        data_buffer[11] <= 1'b0;
        data_buffer[12] <= 1'b0;
        data_buffer[13] <= 1'b0;
        data_buffer[14] <= 1'b0;
        data_buffer[15] <= 1'b0;
        data_buffer[16] <= 1'b0;
        data_buffer[17] <= 1'b0;
        data_buffer[18] <= 1'b0;
        data_buffer[19] <= 1'b0;
        data_buffer[20] <= 1'b0;
        data_buffer[21] <= 1'b0;
        data_buffer[22] <= 1'b0;
        data_buffer[23] <= 1'b0;
        data_buffer[24] <= 1'b0;
        data_buffer[25] <= 1'b0;
        data_buffer[26] <= 1'b0;
        data_buffer[27] <= 1'b0;
        data_buffer[28] <= 1'b0;
        data_buffer[29] <= 1'b0;
        data_buffer[30] <= 1'b0;
        data_buffer[31] <= 1'b0;
        data_buffer[32] <= 1'b0;
        data_buffer[33] <= 1'b0;
        data_buffer[34] <= 1'b0;
        data_buffer[35] <= 1'b0;
        data_buffer[36] <= 1'b0;
        data_buffer[37] <= 1'b0;
        data_buffer[38] <= 1'b0;
        data_buffer[39] <= 1'b0;
        data_buffer[40] <= 1'b0;
        data_buffer[41] <= 1'b0;
        data_buffer[42] <= 1'b0;
        data_buffer[43] <= 1'b0;
        data_buffer[44] <= 1'b0;
        data_buffer[45] <= 1'b0;
        data_buffer[46] <= 1'b0;
        data_buffer[47] <= 1'b0;
        data_buffer[48] <= 1'b0;
        data_buffer[49] <= 1'b0;
        data_buffer[50] <= 1'b0;
        data_buffer[51] <= 1'b0;
        data_buffer[52] <= 1'b0;
        data_buffer[53] <= 1'b0;
        data_buffer[54] <= 1'b0;
        data_buffer[55] <= 1'b0;
        data_buffer[56] <= 1'b0;
        data_buffer[57] <= 1'b0;
        data_buffer[58] <= 1'b0;
        data_buffer[59] <= 1'b0;
        data_buffer[60] <= 1'b0;
        data_buffer[61] <= 1'b0;
        data_buffer[62] <= 1'b0;
        data_buffer[63] <= 1'b0;
		data_count<=10'b0;	  
		conv_data_pass<=0;
end 		   



//��modeΪ1��ʱ�����Ȩ�ؼ���
else if ((mode && valid && ready)||weight_OK) begin	
	 //ȫ����Ȩ�ظ��¿�ʼ
	 //Ȩ������ȫ�����¼���	
	 if (weight_count <16) begin
            weight0 <= data_in;// ���������ݵĵ�16λд�뻺����
			weight_count <= weight_count + 16;	//�Ѿ�д��ȥ��λ�����ϼ�16  
	 end
	 else if (weight_count <32) begin
            weight1 <= data_in;// ���������ݵĵ�16λд�뻺����
			weight_count <= weight_count + 16;	//�Ѿ�д��ȥ��λ�����ϼ�16  
	 end 
	 else if (weight_count <48) begin
            weight2 <= data_in;// ���������ݵĵ�16λд�뻺����
			weight_count <= weight_count + 16;	//�Ѿ�д��ȥ��λ�����ϼ�16  
	 end 
	 else if (weight_count <64) begin
            weight3 <= data_in;// ���������ݵĵ�16λд�뻺����
			weight_count <= weight_count + 16;	//�Ѿ�д��ȥ��λ�����ϼ�16  
	 end 
	 else if (weight_count <80) begin
            weight4 <= data_in;// ���������ݵĵ�16λд�뻺����
			weight_count <= weight_count + 16;	//�Ѿ�д��ȥ��λ�����ϼ�16  
	 end 
	 else if (weight_count <96) begin
            weight5 <= data_in;// ���������ݵĵ�16λд�뻺����
			weight_count <= weight_count + 16;	//�Ѿ�д��ȥ��λ�����ϼ�16  
            weight_OK<=1;   //ȫ����ÿ��Ȩ�ؼ��ؽ�����־ 
	 end 	  	
	 else if (weight_OK==1) begin
        if(weight_count == 97)begin
            weight_OK<=0;	  
            weight_count<=0;
        end
        else begin
            weight_count<=weight_count+1;
        end
    end
	 
	     //if (weight_count<64)begin
		 //weight_buffer[weight_count+:16]<=data_in;
		 //end
	     // if (weight_count==300) begin
		 //weight_buffer[weight_count +: 10] <= data_in[9:0];//���12�����ݵ�������ʱ������������ֻ��Ҫ����10�� ��ע������ߵ�λ˳��	
		 //weight_count <= weight_count + 10;	//���д��ȥ�ĵ�һ�����˵�λ����10
	     //end

//���Ѿ��ڻ��������д�õ�����ֱ�Ӹ���Ӧ�����		
	        // if (weight_count>15)begin
			//weight0<=weight_buffer[15-:16];
			//end
		    //if (weight_count>31)begin
			//weight1<=weight_buffer[31-:16];
			//end
		    //if (weight_count>47)begin
			//weight2<=weight_buffer[47-:16];
			//end
		    //if (weight_count>63)begin
			//weight3<=weight_buffer[63-:16];	
			//end
		    //if (weight_count>79)begin
			//weight4<=weight_buffer[79-:16];
			//end
		    //if (weight_count>95)begin
			//weight5<=weight_buffer[95-:16]; 
			//end
			
end		




//ģʽ�л�   
else if (!mode&&ready)begin		   
   //�ȴ���ʼ��64������ȫ�����������
  if (data_count<64)begin    
      data_buffer[63] <= data_buffer[59];
      data_buffer[62] <= data_buffer[58];
      data_buffer[61] <= data_buffer[57];
      data_buffer[60] <= data_buffer[56];
      data_buffer[59] <= data_buffer[55];
      data_buffer[58] <= data_buffer[54];
      data_buffer[57] <= data_buffer[53];
      data_buffer[56] <= data_buffer[52];
      data_buffer[55] <= data_buffer[51];
      data_buffer[54] <= data_buffer[50];
      data_buffer[53] <= data_buffer[49];
      data_buffer[52] <= data_buffer[48];
      data_buffer[51] <= data_buffer[47];
      data_buffer[50] <= data_buffer[46];
      data_buffer[49] <= data_buffer[45];
      data_buffer[48] <= data_buffer[44];
      data_buffer[47] <= data_buffer[43];
      data_buffer[46] <= data_buffer[42];
      data_buffer[45] <= data_buffer[41];
      data_buffer[44] <= data_buffer[40];
      data_buffer[43] <= data_buffer[39];
      data_buffer[42] <= data_buffer[38];
      data_buffer[41] <= data_buffer[37];
      data_buffer[40] <= data_buffer[36];
      data_buffer[39] <= data_buffer[35];
      data_buffer[38] <= data_buffer[34];
      data_buffer[37] <= data_buffer[33];
      data_buffer[36] <= data_buffer[32];
      data_buffer[35] <= data_buffer[31];
      data_buffer[34] <= data_buffer[30];
      data_buffer[33] <= data_buffer[29];
      data_buffer[32] <= data_buffer[28];
      data_buffer[31] <= data_buffer[27];
      data_buffer[30] <= data_buffer[26];
      data_buffer[29] <= data_buffer[25];
      data_buffer[28] <= data_buffer[24];
      data_buffer[27] <= data_buffer[23];
      data_buffer[26] <= data_buffer[22];
      data_buffer[25] <= data_buffer[21];
      data_buffer[24] <= data_buffer[20];
      data_buffer[23] <= data_buffer[19];
	  data_buffer[22] <= data_buffer[18];
	  data_buffer[21] <= data_buffer[17];
	  data_buffer[20] <= data_buffer[16];
	  data_buffer[19] <= data_buffer[15];
	  data_buffer[18] <= data_buffer[14];
	  data_buffer[17] <= data_buffer[13];
	  data_buffer[16] <= data_buffer[12];
	  data_buffer[15] <= data_buffer[11];
	  data_buffer[14] <= data_buffer[10];
	  data_buffer[13] <= data_buffer[9];
      data_buffer[12] <= data_buffer[8];
	  data_buffer[11] <= data_buffer[7];
	  data_buffer[10] <= data_buffer[6];
	  data_buffer[9] <= data_buffer[5];
	  data_buffer[8] <= data_buffer[4];
	  data_buffer[7] <= data_buffer[3];
	  data_buffer[6] <= data_buffer[2];
	  data_buffer[5] <= data_buffer[1];
	  data_buffer[4] <= data_buffer[0];
	  //����һ��������4*4����ȥ,��λ4��,��λ���ȴ��������
	  //��һ����������1bit
	  if (data_in[3:0]>7) begin
	  data_buffer[3] <= 1'b1;
	  end
      else begin
	  data_buffer[3] <= 1'b0;
	  end
	  //�ڶ�����������1bit
	  if (data_in[7:4]>7) begin
	  data_buffer[2] <= 1'b1;
	  end
      else begin
	  data_buffer[2] <= 1'b0;
	  end  
	  //��������������1bit
	  if (data_in[11:8]>7) begin
	  data_buffer[1] <= 1'b1;
	  end
      else begin
	  data_buffer[1] <= 1'b0;
	  end
	  //���ĸ���������1bit
	  if (data_in[15:12]>7) begin
	  data_buffer[0] <= 1'b1;
	  end
      else begin
	  data_buffer[0] <= 1'b0;
	  end  
	  
	  data_count<=data_count+4;//���ݴ���λ������4��
	  if (data_count==60)begin
		  conv_data_pass<=1'b1;//����˴����ź����ߣ���ʾ��ǰ����Ĵ�������Դ�������
	      flag1<= flag1+1;//��һ�����ݼ�¼һ��
	  end
  end 
   
   
   
   //��ȫ������ȫ�����뵽�Ĵ�����Ĺ���
  else if ((data_count>63)&&(data_count<400))begin
	   
	  	 //ÿһ�е����ݴ���
	 if (flag1<9)begin   	
		 //��flag2�ź��������㣬Ϊ�´λ�����׼��
		 flag2<=0;
	     //�ڴ�����̵��н��������������´���
         data_buffer[63] <= data_buffer[61];
         data_buffer[62] <= data_buffer[60];
         data_buffer[61] <= data_buffer[59];
         data_buffer[60] <= data_buffer[58];
         data_buffer[59] <= data_buffer[57];
         data_buffer[58] <= data_buffer[56];
         data_buffer[57] <= data_buffer[55];
         data_buffer[56] <= data_buffer[54];
         data_buffer[55] <= data_buffer[53];
         data_buffer[54] <= data_buffer[52];
         data_buffer[53] <= data_buffer[51];
         data_buffer[52] <= data_buffer[50];
         data_buffer[51] <= data_buffer[49];
         data_buffer[50] <= data_buffer[48];
         data_buffer[49] <= data_buffer[47];
         data_buffer[48] <= data_buffer[46];
         data_buffer[47] <= data_buffer[45];
         data_buffer[46] <= data_buffer[44];
         data_buffer[45] <= data_buffer[43];
         data_buffer[44] <= data_buffer[42];
         data_buffer[43] <= data_buffer[41];
         data_buffer[42] <= data_buffer[40];
         data_buffer[41] <= data_buffer[39];
         data_buffer[40] <= data_buffer[38];
         data_buffer[39] <= data_buffer[37];
         data_buffer[38] <= data_buffer[36];
         data_buffer[37] <= data_buffer[35];
         data_buffer[36] <= data_buffer[34];
         data_buffer[35] <= data_buffer[33];
         data_buffer[34] <= data_buffer[32];
         data_buffer[33] <= data_buffer[31];
         data_buffer[32] <= data_buffer[30];
         data_buffer[31] <= data_buffer[29];
         data_buffer[30] <= data_buffer[28];
         data_buffer[29] <= data_buffer[27];
         data_buffer[28] <= data_buffer[26];
         data_buffer[27] <= data_buffer[25];
         data_buffer[26] <= data_buffer[24];
         data_buffer[25] <= data_buffer[23];
         data_buffer[24] <= data_buffer[22];
         data_buffer[23] <= data_buffer[21];
         data_buffer[22] <= data_buffer[20];
         data_buffer[21] <= data_buffer[19];
         data_buffer[20] <= data_buffer[18];
         data_buffer[19] <= data_buffer[17];
         data_buffer[18] <= data_buffer[16];
         data_buffer[17] <= data_buffer[15];
         data_buffer[16] <= data_buffer[14];
         data_buffer[15] <= data_buffer[13];
         data_buffer[14] <= data_buffer[12];
         data_buffer[13] <= data_buffer[11];
         data_buffer[12] <= data_buffer[10];
         data_buffer[11] <= data_buffer[9];
         data_buffer[10] <= data_buffer[8];
         data_buffer[9] <= data_buffer[7];
         data_buffer[8] <= data_buffer[6];
         data_buffer[7] <= data_buffer[5];
         data_buffer[6] <= data_buffer[4];
         data_buffer[5] <= data_buffer[3];
         data_buffer[4] <= data_buffer[2];
         data_buffer[3] <= data_buffer[1];
         data_buffer[2] <= data_buffer[0]; 
	     //����һ��������2*1����ȥ,��λ����
         //�ڶ�����������1bit
	     if (data_in[3:0]>7) begin
	     data_buffer[1] <= 1'b1;
	     end
         else begin
	     data_buffer[1] <= 1'b0;
	     end
	     //��һ����������1bit
	     if (data_in[7:4]>7) begin
	     data_buffer[0] <= 1'b1;
	     end
         else begin
	     data_buffer[0] <= 1'b0;
	     end  
	     data_count<=data_count+2;//���ݴ���λ������2�� 
		 //����һ���Ѿ�����Ĵ������ж��Ƿ���Ҫ���У�������Ҫ����8��
		 flag1<=flag1+1;
	  		 	   
	 end	 
	   
     else begin	  
	     
	   	 if (conv_data_pass==1'b1)begin
	     conv_data_pass<=1'b0;//����˴����ź����ͣ���ʾ��ǰ���Ը�������
	     end 
	   
	     //�ڴ�����̵��н���4���������´���
          data_buffer[63] <= data_buffer[59];
          data_buffer[62] <= data_buffer[58];
          data_buffer[61] <= data_buffer[57];
          data_buffer[60] <= data_buffer[56];
          data_buffer[59] <= data_buffer[55];
          data_buffer[58] <= data_buffer[54];
          data_buffer[57] <= data_buffer[53];
          data_buffer[56] <= data_buffer[52];
          data_buffer[55] <= data_buffer[51];
          data_buffer[54] <= data_buffer[50];
          data_buffer[53] <= data_buffer[49];
          data_buffer[52] <= data_buffer[48];
          data_buffer[51] <= data_buffer[47];
          data_buffer[50] <= data_buffer[46];
          data_buffer[49] <= data_buffer[45];
          data_buffer[48] <= data_buffer[44];
          data_buffer[47] <= data_buffer[43];
          data_buffer[46] <= data_buffer[42];
          data_buffer[45] <= data_buffer[41];
          data_buffer[44] <= data_buffer[40];
          data_buffer[43] <= data_buffer[39];
          data_buffer[42] <= data_buffer[38];
          data_buffer[41] <= data_buffer[37];
          data_buffer[40] <= data_buffer[36];
          data_buffer[39] <= data_buffer[35];
          data_buffer[38] <= data_buffer[34];
          data_buffer[37] <= data_buffer[33];
          data_buffer[36] <= data_buffer[32];
          data_buffer[35] <= data_buffer[31];
          data_buffer[34] <= data_buffer[30];
          data_buffer[33] <= data_buffer[29];
          data_buffer[32] <= data_buffer[28];
          data_buffer[31] <= data_buffer[27];
          data_buffer[30] <= data_buffer[26];
          data_buffer[29] <= data_buffer[25];
          data_buffer[28] <= data_buffer[24];
          data_buffer[27] <= data_buffer[23];
          data_buffer[26] <= data_buffer[22];
          data_buffer[25] <= data_buffer[21];
          data_buffer[24] <= data_buffer[20];
          data_buffer[23] <= data_buffer[19];
	      data_buffer[22] <= data_buffer[18];
	      data_buffer[21] <= data_buffer[17];
	      data_buffer[20] <= data_buffer[16];
	      data_buffer[19] <= data_buffer[15];
	      data_buffer[18] <= data_buffer[14];
	      data_buffer[17] <= data_buffer[13];
	      data_buffer[16] <= data_buffer[12];
	      data_buffer[15] <= data_buffer[11];
	      data_buffer[14] <= data_buffer[10];
	      data_buffer[13] <= data_buffer[9];
          data_buffer[12] <= data_buffer[8];
	      data_buffer[11] <= data_buffer[7];
	      data_buffer[10] <= data_buffer[6];
	      data_buffer[9] <= data_buffer[5];
	      data_buffer[8] <= data_buffer[4];
	      data_buffer[7] <= data_buffer[3];
	      data_buffer[6] <= data_buffer[2];
	      data_buffer[5] <= data_buffer[1];
	      data_buffer[4] <= data_buffer[0];
	     //����һ��������4*4����ȥ,��λ4��,��λ���ȴ��������
	     //��һ����������1bit
	     if (data_in[3:0]>7) begin
	     data_buffer[3] <= 1'b1;
	     end
         else begin
	     data_buffer[3] <= 1'b0;
	     end
	     //�ڶ�����������1bit
	     if (data_in[7:4]>7) begin
	     data_buffer[2] <= 1'b1;
	     end
         else begin
	     data_buffer[2] <= 1'b0;
	     end  
	     //��������������1bit
	     if (data_in[11:8]>7) begin
	     data_buffer[1] <= 1'b1;
	     end
         else begin
	     data_buffer[1] <= 1'b0;
	     end
	     //���ĸ���������1bit
	     if (data_in[15:12]>7) begin
	     data_buffer[0] <= 1'b1;
	     end
         else begin
	     data_buffer[0] <= 1'b0;
	     end  
	     data_count<=data_count+4;//���ݴ���λ������4��
		 
		 //����һ���Ѿ�����Ĵ������ж��Ƿ���Ҫ���У�������Ҫ����4+20=24��
		 flag2<=flag2+1;  
		 
		 //��־���������еĲ���ȫ������
		 if (flag2==5)begin
	  	 //���н����Ժ����¿�ʼ���뵥���ƶ�
	   	 flag1<=1;
	     //�����ξ�������ݸ�������Ժ���Ҫ������˴����ź��������Ѻ������Ĵ����飬������flag1�ź�
	     conv_data_pass<=1'b1;//����˴����ź����ߣ���ʾ��ǰ����Ĵ�������Դ�������	
	   	 end
	   
     end
   
  end
   
  
	   	      
end   
  //��ֹ���
else begin 
	conv_data_pass<=1'b0; 
end

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


assign ready=(data_count<400)?valid:(weight_req & weight_count<96);
	

// count=96 ok=1 req=1 ready=0
// count=97  ok=1 req=0 ready=0
// count=0  ok=0  req=0 ready=0

endmodule
