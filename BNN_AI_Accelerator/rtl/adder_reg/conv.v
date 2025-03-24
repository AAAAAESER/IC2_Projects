module conv #(
    parameter DATA_WIDTH = 4,
    parameter K = 4,
    parameter LOGK = 4
)(
    input wire clk,
    input wire [K*K*DATA_WIDTH -1:0] idata, 
    input wire [K*K -1:0] weight, //0 1 2 3 4(top) / 5 6 7 8 9 / 10 11 12 13 14 / 15 16 17 18 19 / 20 21 22 23 24(bottom) like that
    output wire [DATA_WIDTH+LOGK -1:0] dout
);


wire [DATA_WIDTH-1 :0]data_vert[K*K-1:0];
wire [DATA_WIDTH + LOGK -1:0]data_mul[K*K-1:0];
wire [DATA_WIDTH + LOGK -1:0]sum;

reg [DATA_WIDTH-1 :0]data_vert_r[K*K-1:0];
// reg [DATA_WIDTH + LOGK-1 :0]data_sum1[3:0];
generate
    genvar j;
    for(j=0;j<K*K;j=j+1)begin
        assign data_vert[j] = ({DATA_WIDTH{weight[j]}} ~^ idata[((j+1)*DATA_WIDTH-1):j*DATA_WIDTH]) + {{(DATA_WIDTH-1){1'b0}}, ~weight[j]};
        // assign data_mul[j] = weight[j]? $signed(idata[((j+1)*DATA_WIDTH-1):j*DATA_WIDTH]): -$signed(idata[((j+1)*DATA_WIDTH-1):j*DATA_WIDTH]);
        assign data_mul[j] = {{LOGK{data_vert_r[j][DATA_WIDTH-1]}}, data_vert_r[j]};
    end
endgenerate
integer  i;
always @(posedge clk) begin
    for(int i=0;i<K*K;i=i+1)begin
        data_vert_r[i]<=data_vert[i];
    end
end
// assign data_sum1[0]=data_mul[0]+data_mul[1]+data_mul[2]+data_mul[3];
// assign data_sum1[1]=data_mul[4]+data_mul[5]+data_mul[6]+data_mul[7];
// assign data_sum1[2]=data_mul[8]+data_mul[9]+data_mul[10]+data_mul[11];
// assign data_sum1[3]=data_mul[12]+data_mul[13]+data_mul[14]+data_mul[15];

// // always @(posedge clk) begin
// //     for(int i=0;i<4;i=i+1)begin
// //         data_sum1[i]<=data_sum1[i];
// //     end    
// // end
// wire [DATA_WIDTH+LOGK-1:0]sum;
// assign sum=data_sum1[0]+data_sum1[1]+data_sum1[2]+data_sum1[3]; 
assign sum=data_mul[0]+data_mul[1]+data_mul[2]+data_mul[3]+data_mul[4]+
            data_mul[5]+data_mul[6]+data_mul[7]+data_mul[8]+data_mul[9]+
            data_mul[10]+data_mul[11]+data_mul[12]+data_mul[13]+data_mul[14]+
            data_mul[15];//+data_mul[16]+data_mul[17]+data_mul[18]+data_mul[19]+
            //data_mul[20]+data_mul[21]+data_mul[22]+data_mul[23]+data_mul[24];

assign dout = sum;
endmodule