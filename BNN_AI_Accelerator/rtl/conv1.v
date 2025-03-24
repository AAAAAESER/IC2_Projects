module data(
    input clk,             // 时钟信号
    input rst_n,           // 复位信号，低电平有效
    input mode,            // 模式选择信号,为1是权重加载，为0是数据加载计算	  
	input over,             //单次12种卷积核处理完成的结束信号
	input valid,			//握手信号
    input [7:0] data_in,  // 共有十二种卷积核，每一个有25位输入数据
    output reg [24:0] weight0,// 十二个卷积核模块
	output reg [24:0] weight1,// 十二个卷积核模块
	output reg [24:0] weight2,// 十二个卷积核模块
	output reg [24:0] weight3,// 十二个卷积核模块
	output reg [24:0] weight4,// 十二个卷积核模块
	output reg [24:0] weight5,// 十二个卷积核模块
	output reg [24:0] weight6,// 十二个卷积核模块
	output reg [24:0] weight7,// 十二个卷积核模块
	output reg [24:0] weight8,// 十二个卷积核模块
	output reg [24:0] weight9,// 十二个卷积核模块
	output reg [24:0] weight10,// 十二个卷积核模块
	output reg [24:0] weight11,// 十二个卷积核模块
	output reg conv_process,//处理模块的准备信号
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

// 内部变量
reg [299:0] weight_buffer; // 用于存储输入权重的缓冲区
reg [9:0] weight_count;// 用于计数权重已经发送的位数
reg [9:0] data_count;//用于计数到底多少28x28数据已经被传递到5x29寄存器内部
reg [7:0] data_buffer[144:0];//5x29寄存器计算单元
reg [1:0] flag1;//用来判断每次计算时需要进行两次数据移位和打入操作
reg [5:0] flag2;//用来判断最后计算过程的终止
integer i=0;
integer j=0;
integer k=0; 
integer a=0;

//ssaa
// 在时钟上升沿处理数据
always @(posedge clk or negedge rst_n)
begin  
// 复位逻辑
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
//当mode为1的时候进行权重加载
else if (mode&&valid) begin
	 if (weight_count <296) begin
            weight_buffer[weight_count +: 8] <= data_in;// 将输入数据的低8位写入缓冲区
			weight_count <= weight_count + 8;	//已经写进去的位数不断加8  
	 end
	 if (weight_count==296) begin
		 weight_buffer[weight_count +: 4] <= data_in[3:0];//最后四个数据单独传递时，缓冲器仅仅只需要填入四个 ，注意输入高低位顺序	
		 weight_count <= weight_count + 4;	//最后写进去的位数加4
	 end

//将已经在缓存器当中存好的数据直接给对应卷积核		
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
//模式切换   
else if (!mode&&valid)begin
   //等待初始的145个数据全部被打入进来
   if (data_count<145)begin    
      for (i=0;i<144;i=i+1)begin 
        data_buffer[144-i]<=data_buffer[144-i-1];   
      end
      data_buffer[0]<=data_in;	//数据每八个打入进去
	  data_count<=data_count+1;//数据传送位数计数
   end
   
   else if ((data_count>144)&&(data_count<841))begin
	   if (flag1==0)begin
	   conv_process<=1'b1;//卷积核处理准备信号使能	   
	   end	 
	   else begin
	   conv_process<=1'b0;//卷积核处理准备信号关断
	   end
	   //在处理过程当中进行两次数据重新打入
	   if (flag1<2)begin
         for (j=0;j<144;j=j+1)begin 
           data_buffer[144-j]<=data_buffer[144-j-1]; 
	     end
         data_buffer[0]<=data_in;	//数据每八个打入进去    	  
	   //记录总共写入了多少数据，由于步长为2，故这里每次写入两个数据
	     data_count<=data_count+1;
	     flag1<=flag1+1;	
	   end				   
	   //当单次卷积核数据处理完成以后，需要指示原来的寄存器重新进行写入数据
	   //（over和process可以用一个变量0,1表示）
	   if (over==1)begin
	     flag1<=0;  
	   end	
   end
   //所有的数据已经全部写入到寄存器当中，只有移位和处理工作进行
   else if (data_count==841&&flag2<25)begin
	   //卷积核处理准备信号使能
	   if (flag1==0)begin
	   conv_process<=1'b1;
	   end				
       else begin
	   conv_process<=1'b0;//卷积核处理准备信号关断
	   end
	   //在重复数据进入最后的5x5计算单元前，仍然需要在计算中移位两格满足步长要求
	   if (flag1<2)begin
	   //flag2表示的是当已经没有新的数据更新这个5x29的寄存器组时，为了防止有错误重复的数据被卷积核混入计算
	   //需要在24次移位后结束寄存器移位操作并终止计算。
	     flag2<=flag2+1;
         for (k=0;k<144;k=k+1)begin 
           data_buffer[144-k]<=data_buffer[144-k-1];
		 end
		 flag1<=flag1+1;
	   end	
	   
	   //当计算结束的信号反馈时，需要将flag1重新置零进行计算
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