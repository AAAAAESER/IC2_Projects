module data(
    input clk,             // 时钟信号
    input rst_n,           // 复位信号，低电平有效
    input mode,            // 模式选择信号,为1是权重加载，为0是数据加载计算	  
	input valid,			//外部握手信号，表示此时外面可以发送信号
    input [15:0] data_in,  // 共有十二种卷积核，每一个有25位输入数据	  	 
	input weight_req,//表示权重矩阵开始重新加载数据量	 
	output reg weight_OK,//表示单次权重加载全部完成
    output reg [15:0] weight0,// 六个卷积核模块
	output reg [15:0] weight1,// 六个卷积核模块
	output reg [15:0] weight2,// 六个卷积核模块
	output reg [15:0] weight3,// 六个卷积核模块
	output reg [15:0] weight4,// 六个卷积核模块
	output reg [15:0] weight5,// 六个卷积核模块
	output reg conv_data_pass,//处理模块的准备信号
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
	output  ready//表示此时可以接受外面数据
);

// 内部变量
//reg [95:0] weight_buffer; // 用于存储输入权重的缓冲区
reg [7:0] weight_count;// 用于计数权重已经发送的位数（包含两个权重矩阵）
reg [9:0] data_count;//用于计数到底多少28x28数据已经被传递到5x29寄存器内部 
reg data_buffer[63:0];//3x20+4寄存器计算单元
reg [3:0] flag1;//用来判断每次计算时需要进行两次数据移位和打入操作
reg [2:0] flag2;//用来判断最后计算过程的终止 
integer i;



// 在时钟上升沿处理数据
always @(posedge clk or negedge rst_n)
begin  

	
// 复位逻辑
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



//当mode为1的时候进行权重加载
else if ((mode && valid && ready)||weight_OK) begin	
	 //全连接权重更新开始
	 //权重数据全部重新加载	
	 if (weight_count <16) begin
            weight0 <= data_in;// 将输入数据的低16位写入缓冲区
			weight_count <= weight_count + 16;	//已经写进去的位数不断加16  
	 end
	 else if (weight_count <32) begin
            weight1 <= data_in;// 将输入数据的低16位写入缓冲区
			weight_count <= weight_count + 16;	//已经写进去的位数不断加16  
	 end 
	 else if (weight_count <48) begin
            weight2 <= data_in;// 将输入数据的低16位写入缓冲区
			weight_count <= weight_count + 16;	//已经写进去的位数不断加16  
	 end 
	 else if (weight_count <64) begin
            weight3 <= data_in;// 将输入数据的低16位写入缓冲区
			weight_count <= weight_count + 16;	//已经写进去的位数不断加16  
	 end 
	 else if (weight_count <80) begin
            weight4 <= data_in;// 将输入数据的低16位写入缓冲区
			weight_count <= weight_count + 16;	//已经写进去的位数不断加16  
	 end 
	 else if (weight_count <96) begin
            weight5 <= data_in;// 将输入数据的低16位写入缓冲区
			weight_count <= weight_count + 16;	//已经写进去的位数不断加16  
            weight_OK<=1;   //全连接每次权重加载结束标志 
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
		 //weight_buffer[weight_count +: 10] <= data_in[9:0];//最后12个数据单独传递时，缓冲器仅仅只需要填入10个 ，注意输入高低位顺序	
		 //weight_count <= weight_count + 10;	//最后写进去的第一层卷积核的位数加10
	     //end

//将已经在缓存器当中存好的数据直接给对应卷积核		
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




//模式切换   
else if (!mode&&ready)begin		   
   //等待初始的64个数据全部被打入进来
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
	  //数据一口气打入4*4个进去,移位4次,低位是先传入的数据
	  //第一个数据量化1bit
	  if (data_in[3:0]>7) begin
	  data_buffer[3] <= 1'b1;
	  end
      else begin
	  data_buffer[3] <= 1'b0;
	  end
	  //第二个数据量化1bit
	  if (data_in[7:4]>7) begin
	  data_buffer[2] <= 1'b1;
	  end
      else begin
	  data_buffer[2] <= 1'b0;
	  end  
	  //第三个数据量化1bit
	  if (data_in[11:8]>7) begin
	  data_buffer[1] <= 1'b1;
	  end
      else begin
	  data_buffer[1] <= 1'b0;
	  end
	  //第四个数据量化1bit
	  if (data_in[15:12]>7) begin
	  data_buffer[0] <= 1'b1;
	  end
      else begin
	  data_buffer[0] <= 1'b0;
	  end  
	  
	  data_count<=data_count+4;//数据传送位数计数4次
	  if (data_count==60)begin
		  conv_data_pass<=1'b1;//卷积核传递信号拉高，表示当前后面寄存器组可以传递数据
	      flag1<= flag1+1;//传一次数据记录一次
	  end
  end 
   
   
   
   //将全部数据全部移入到寄存器组的过程
  else if ((data_count>63)&&(data_count<400))begin
	   
	  	 //每一行的数据传递
	 if (flag1<9)begin   	
		 //将flag2信号重新置零，为下次换行做准备
		 flag2<=0;
	     //在处理过程当中进行两次数据重新打入
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
	     //数据一口气打入2*1个进去,移位两次
         //第二个数据量化1bit
	     if (data_in[3:0]>7) begin
	     data_buffer[1] <= 1'b1;
	     end
         else begin
	     data_buffer[1] <= 1'b0;
	     end
	     //第一个数据量化1bit
	     if (data_in[7:4]>7) begin
	     data_buffer[0] <= 1'b1;
	     end
         else begin
	     data_buffer[0] <= 1'b0;
	     end  
	     data_count<=data_count+2;//数据传送位数计数2次 
		 //保存一行已经计算的次数，判断是否需要换行，换行需要传送8次
		 flag1<=flag1+1;
	  		 	   
	 end	 
	   
     else begin	  
	     
	   	 if (conv_data_pass==1'b1)begin
	     conv_data_pass<=1'b0;//卷积核传递信号拉低，表示当前可以更新数据
	     end 
	   
	     //在处理过程当中进行4次数据重新打入
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
	     //数据一口气打入4*4个进去,移位4次,低位是先传入的数据
	     //第一个数据量化1bit
	     if (data_in[3:0]>7) begin
	     data_buffer[3] <= 1'b1;
	     end
         else begin
	     data_buffer[3] <= 1'b0;
	     end
	     //第二个数据量化1bit
	     if (data_in[7:4]>7) begin
	     data_buffer[2] <= 1'b1;
	     end
         else begin
	     data_buffer[2] <= 1'b0;
	     end  
	     //第三个数据量化1bit
	     if (data_in[11:8]>7) begin
	     data_buffer[1] <= 1'b1;
	     end
         else begin
	     data_buffer[1] <= 1'b0;
	     end
	     //第四个数据量化1bit
	     if (data_in[15:12]>7) begin
	     data_buffer[0] <= 1'b1;
	     end
         else begin
	     data_buffer[0] <= 1'b0;
	     end  
	     data_count<=data_count+4;//数据传送位数计数4次
		 
		 //保存一行已经计算的次数，判断是否需要换行，换行需要传送4+20=24次
		 flag2<=flag2+1;  
		 
		 //标志连续换两行的操作全部结束
		 if (flag2==5)begin
	  	 //表换行结束以后重新开始进入单行移动
	   	 flag1<=1;
	     //当两次卷积核数据更新完成以后，需要将卷积核传递信号拉高提醒后面读入寄存器组，并更新flag1信号
	     conv_data_pass<=1'b1;//卷积核传递信号拉高，表示当前后面寄存器组可以传递数据	
	   	 end
	   
     end
   
  end
   
  
	   	      
end   
  //终止语句
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
