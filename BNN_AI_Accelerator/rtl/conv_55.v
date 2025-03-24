module conv_55 #(
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire rstn,
    input wire ivalid,
    input wire [5*5*DATA_WIDTH-1:0] idata, 
    input wire [25-1:0] weight, //0 1 2 3 4(top) / 5 6 7 8 9 / 10 11 12 13 14 / 15 16 17 18 19 / 20 21 22 23 24(bottom)
    output wire ovalid,
    output wire [31:0] dout
);

reg [DATA_WIDTH-1:0]data_reg[25-1:0];//input data 

integer i;
always @(posedge clk or negedge rstn) begin //1pat
    if(~rstn)begin
        for(i=0;i<25;i=i+1)begin
            data_reg[i] <= 0;
        end
    end
    else begin
        if(ivalid)begin
            for(i=0;i<25;i=i+1)begin
                data_reg[i] <= idata[i*DATA_WIDTH +: DATA_WIDTH];
            end
        end
    end
end

wire [DATA_WIDTH+6-1:0]data_mul[25-1:0];
wire [DATA_WIDTH+1-1:0]data_vert[25-1:0];
generate
    genvar j;
    for(j=0;j<25;j=j+1)begin
        assign data_vert[j]= weight[j] ? data_reg[j] : ~data_reg[j] +1;//invert
        // assign data_vert[j]= (data_reg[j] ^ {8{~(weight[j])}} + {{(DATA_WIDTH){1'b0}},~weight[j]} );//+ ~weight[j];//+ {{(DATA_WIDTH){1'b0}},~weight[j]}; //invert and add 1
        // assign data_vert[j]= data_reg[j] ^ {8{~weight[j]}} + {{(DATA_WIDTH-1){1'b0}},~weight[j]}; //invert and add 1
        assign data_mul[j]={{5{data_vert[j][DATA_WIDTH]}},data_vert[j]};//sign extension
    end
endgenerate

// reg [DATA_WIDTH+5-1:0]data_mul_reg[25-1:0];

// always@(posedge clk or negedge rstn)begin //2pat
//     if(~rstn)begin
//         for(integer i=0;i<25;i=i+1)begin
//             data_mul_reg[i] <= 0;
//         end
//     end
//     else begin
//         for(integer i=0;i<25;i=i+1)begin
//             data_mul_reg[i] <= data_vert[i];
//         end
//     end
// end

// wire [DATA_WIDTH+5-1:0]sum;
// assign sum=data_mul_reg[0]+data_mul_reg[1]+data_mul_reg[2]+data_mul_reg[3]+data_mul_reg[4]+
//             data_mul_reg[5]+data_mul_reg[6]+data_mul_reg[7]+data_mul_reg[8]+data_mul_reg[9]+
//             data_mul_reg[10]+data_mul_reg[11]+data_mul_reg[12]+data_mul_reg[13]+data_mul_reg[14]+
//             data_mul_reg[15]+data_mul_reg[16]+data_mul_reg[17]+data_mul_reg[18]+data_mul_reg[19]+
//             data_mul_reg[20]+data_mul_reg[21]+data_mul_reg[22]+data_mul_reg[23]+data_mul_reg[24];

wire [DATA_WIDTH+6-1:0]sum;
assign sum=data_mul[0]+data_mul[1]+data_mul[2]+data_mul[3]+data_mul[4]+
            data_mul[5]+data_mul[6]+data_mul[7]+data_mul[8]+data_mul[9]+
            data_mul[10]+data_mul[11]+data_mul[12]+data_mul[13]+data_mul[14]+
            data_mul[15]+data_mul[16]+data_mul[17]+data_mul[18]+data_mul[19]+
            data_mul[20]+data_mul[21]+data_mul[22]+data_mul[23]+data_mul[24];

reg valid_1_reg,valid_2_reg,valid_3_reg;
always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        valid_1_reg <= 0; 
        valid_2_reg <= 0;
        valid_3_reg <= 0;
    end 
    else begin
        valid_1_reg <= ivalid;
        // valid_2_reg <= valid_1_reg;
        // valid_3_reg <= valid_2_reg;
    end
end

assign ovalid = valid_1_reg;
assign dout = {{(32-DATA_WIDTH-6){sum[DATA_WIDTH+6-1]}},sum};
endmodule