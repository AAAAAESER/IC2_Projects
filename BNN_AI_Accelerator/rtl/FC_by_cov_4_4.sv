module FC_by_cov_4_4(
    input clk,rst_n,
    input [8:0]maxpool_out[15:0], //input and output are all 2's complement
    input [15:0]fc_bw,
    output reg[12:0]fc_out
);
    genvar i;
    reg [8:0]fc_out_con[15:0];
    reg [12:0]fc_out_temp[15:0];
    reg [12:0]D[3:0];
    reg [12:0]Q[3:0];
    integer j,k,m,n;

    generate 
        for(i=0;i<16;i=i+1) begin: fc_layer
            FC_by_cov_1_1 FC_by_cov_1_1_4(
                .single_pixel_in(maxpool_out[i]),
                .single_bw(fc_bw[i]),
                .single_pixel_out (fc_out_con[i])
            );
        end 
    endgenerate
    
    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
	    for (n=0;n<4;n=n+1) begin
	    	D[n]<=13'b0;
		    Q[n]<=13'b0;
	    end	     
            for (j=0;j<16;j=j+1) begin
                fc_out_temp[j]<=13'b0;
            end
        end else begin
	    for (m=0;m<16;m=m+1) begin
	    fc_out_temp[m][7:0]<=fc_out_con[m][7:0];
        fc_out_temp[m][12:8]<={8{fc_out_con[m][8]}};
        end
            D[0]<=fc_out_temp[0]+fc_out_temp[1]+fc_out_temp[2]+fc_out_temp[3];
            Q[0]<=D[0];
            for (k=1;k<4;k=k+1) begin
                D[k]<=Q[k-1]+fc_out_temp[3*k+1]+fc_out_temp[3*k+2]+fc_out_temp[3*k+3];
		Q[k]<=D[k];
            end
            fc_out<=Q[3]+fc_out_temp[13]+fc_out_temp[14]+fc_out_temp[15];
        end
    end

endmodule