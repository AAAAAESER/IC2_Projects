module conv_single_slide #(
    parameter DATA_WIDTH = 6,
    parameter K = 3,
    parameter LEN = 9
)(
    input wire clk,
    input wire rstn,
    input wire ivalid,
    input wire [DATA_WIDTH-1:0] idata,
    output wire [K*K*DATA_WIDTH-1:0] odata
);
localparam NUM = LEN*(K-1)+K;

reg [DATA_WIDTH-1:0] data[NUM];
// wire [DATA_WIDTH-1:0] data_nxt[NUM];

integer i;
always @(posedge clk) begin
    if(ivalid)begin
        for(i=0;i<NUM-1;i=i+1)begin
            data[i]<=data[i+1];
        end
        data[NUM-1]<=idata;
    end
end
// always @(posedge clk or negedge rstn) begin
//     if(~rstn)begin
//         integer i;
//         for(i=0;i<NUM;i=i+1)begin
//             data[i]<=0;
//         end
//     end
//     else begin
//         integer i;
//         for(i=0;i<NUM;i=i+1)begin
//             data[i]<=data_nxt[i];
//         end
//     end
// end

// generate
//     genvar j;
//     for(j=0;j<NUM-1;j=j+1)begin:in_data_assign
//         assign data_nxt[j] = ivalid?  data[j+1] : data[j];
//     end
// endgenerate

// assign data_nxt[NUM-1] = ivalid? idata : data[NUM-1];

assign odata = {data[20],data[19],data[18],data[11],data[10],data[9],data[2],data[1],data[0]};


endmodule