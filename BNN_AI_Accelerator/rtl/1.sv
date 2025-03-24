module pooling_layer (
   
input  clk,              // ʱ���ź�
  
input  rst,               // ��λ�ź�
   
input  valid,             // ������Ч�ź�
   
input  [6*2*2*4-1:0] data_in,  // �������ݣ�6��ͨ����ÿ��ͨ��2x2������λ��Ϊ4λ
   
input  reset_storage,     // �洢�������ź�
  
output logic [6*4*4*4-1:0] data_out  // ������ݣ�6��ͨ����ÿ��ͨ��һ��4λ�ĳػ����
);

    
// �洢����6��ͨ����ÿ��ͨ��16���ػ������4λ��
    
logic [3:0] storage [5:0][0:15];  // 6��ͨ����ÿ��ͨ��16���ػ����

  
// �����������ڸ��ٳػ������Ľ���
    
logic [3:0] count;  // 4λ�����������ֵΪ15

  
// 6�����гػ�ģ��ʵ��
  
pooling_channel channel0 (
     
.clk(clk),
       
.rst(rst),
      
.valid(valid),
      
.data_in(data_in[4*2*2-1:0]),  // ͨ��0����������
     
.data_out(storage[0][count])
    );

   

pooling_channel channel1 (
    
.clk(clk),
        
.rst(rst),
      
.valid(valid),
       
.data_in(data_in[2*4*2*2-1:4*2*2]),  // ͨ��1����������
     
.data_out(storage[1][count])
    );

  

pooling_channel channel2 (
    
.clk(clk),
      
.rst(rst),
       
.valid(valid),
       
.data_in(data_in[4*4*2*2-1:2*4*2*2]),  // ͨ��2����������
   
.data_out(storage[2][count])
    );

  

pooling_channel channel3 (
      
.clk(clk),
      
.rst(rst),
      
.valid(valid),
   
.data_in(data_in[6*4*2*2-1:4*4*2*2]),  // ͨ��3����������
     
.data_out(storage[3][count])
    );

  

pooling_channel channel4 (
      
.clk(clk),
       
.rst(rst),
     
.valid(valid),
     
.data_in(data_in[8*4*2*2-1:6*4*2*2]),  // ͨ��4����������
    
.data_out(storage[4][count])
    );

  

pooling_channel channel5 (
     
.clk(clk),
      
.rst(rst),
       
.valid(valid),
   
.data_in(data_in[10*4*2*2-1:8*4*2*2]),  // ͨ��5����������
     
.data_out(storage[5][count])
    );

    // �������߼�������ÿ���ػ�����
    

always_ff @(posedge clk or negedge rst) begin
   
if (!rst) begin
          
count <= 0;  // ��λʱ����������
      
end else if (reset_storage) begin
       
count <= 0;  // �洢������ʱ����������
      
end else if (valid) begin

	if(count==15)begin
		count<=0;
	end else begin
count <= count + 1;  // ÿ����Ч����ʱ����������
    
end
   
end

 
end// ����洢���
   
assign data_out = {
storage[5][15], storage[5][14], storage[5][13], storage[5][12], 
       
storage[5][11], storage[5][10], storage[5][9], storage[5][8], 
             
storage[5][7], storage[5][6], storage[5][5], storage[5][4], 
           
storage[5][3], storage[5][2], storage[5][1], storage[5][0],
 


storage[4][15], storage[4][14], storage[4][13], storage[4][12], 
                       
storage[4][11], storage[4][10], storage[4][9], storage[4][8], 
                       
storage[4][7], storage[4][6], storage[4][5], storage[4][4], 
                       
storage[4][3], storage[4][2], storage[4][1], storage[4][0],


                       
storage[3][15], storage[3][14], storage[3][13], storage[3][12], 
                       
storage[3][11], storage[3][10], storage[3][9], storage[3][8], 
                       
storage[3][7], storage[3][6], storage[3][5], storage[3][4], 
                       
storage[3][3], storage[3][2], storage[3][1], storage[3][0],


                       
storage[2][15], storage[2][14], storage[2][13], storage[2][12], 
                       
storage[2][11], storage[2][10], storage[2][9], storage[2][8], 
                       
storage[2][7], storage[2][6], storage[2][5], storage[2][4], 
                       
storage[2][3], storage[2][2], storage[2][1], storage[2][0],

                       
                       
storage[1][15], storage[1][14], storage[1][13], storage[1][12], 
                       
storage[1][11], storage[1][10], storage[1][9], storage[1][8], 
                       
storage[1][7], storage[1][6], storage[1][5], storage[1][4], 
                       
storage[1][3], storage[1][2], storage[1][1], storage[1][0],


                       
storage[0][15], storage[0][14], storage[0][13], storage[0][12], 
                       
storage[0][11], storage[0][10], storage[0][9], storage[0][8], 
                       
storage[0][7], storage[0][6], storage[0][5], storage[0][4], 
                      
storage[0][3], storage[0][2], storage[0][1], storage[0][0]};  // ���16���ػ����

endmodule

	  
module pooling_channel (
   
input  clk, // ʱ���ź�
    
input  rst,  // ��λ�ź�
    
input  valid,  // ������Ч�ź�
   
input  [2*2*4-1:0] data_in,  // �������ݣ�2x2����ÿ��Ԫ��Ϊ4λ����
   
output logic [3:0] data_out  // ������ݣ�4x4����ÿ��Ԫ��Ϊ4λ����

);

  	 
reg [2*2*4-1:0] data_reg;		   		
always@(posedge clk or negedge rst)begin
	if(!rst)begin
		data_reg <= 16'b0;
	end
	else begin
		data_reg <= data_in;
	end
end
wire [3:0] out_1,out_2,out_3;
assign out_1=(data_reg[3:0] > data_reg[7:4]) ? data_reg[3:0] : data_reg[7:4];
 	 
assign out_2=(data_reg[15:12] > data_reg[11:8]) ? data_reg[15:12] : data_reg[11:8];
  
assign out_3=(out_1 > out_2)?out_1:out_2;
assign data_out = out_3;
endmodule
