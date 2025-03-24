module conv_slide #(
    parameter CH_NUM = 6,
    parameter DATA_WIDTH = 6,
    parameter K = 3,
    parameter LEN = 9
)(
    input wire clk,
    input wire rstn,
    input wire ivalid,
    input wire [CH_NUM*DATA_WIDTH-1:0] idata,
    output wire [CH_NUM*K*K*DATA_WIDTH-1:0] dout,
    output wire ovalid
);
localparam NUM = LEN*(K-1)+K;
reg slide_en_reg;
reg [3:0] cur_state,nxt_state;
// reg [4:0] pre_cnt,pre_cnt_nxt;
reg ovalid_reg;
reg col_valid;
reg [3:0] shift_cnt,shift_cnt_nxt;
reg [3:0] line_cnt,line_cnt_nxt;
assign ovalid = ovalid_reg & col_valid;


localparam S_PRE = 4'b0001;
localparam S_NORMAL = 4'b0010;
localparam S_CHANGELINE = 4'b0100;
localparam S_END = 4'b1000;

always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        cur_state<= S_PRE;
        shift_cnt<=0;
        line_cnt<=0;
        ovalid_reg<=0;
    end
    else begin
        ovalid_reg <= slide_en_reg;
        cur_state<=nxt_state;
        shift_cnt<=shift_cnt_nxt;
        line_cnt<=line_cnt_nxt;
    end
end

always @(*) begin
    case(cur_state)
        S_PRE:begin
            if(line_cnt_nxt==K-1 && shift_cnt_nxt==1)begin
                nxt_state = S_NORMAL;
            end
            else begin
                nxt_state = S_PRE;
            end
        end
        S_NORMAL:begin
            if(shift_cnt_nxt==1 && shift_cnt!=shift_cnt_nxt)begin
                nxt_state = S_CHANGELINE;
            end
            else if(shift_cnt_nxt==LEN && line_cnt==LEN-1)begin
                nxt_state = S_END;
            end
            else begin
                nxt_state = S_NORMAL;
            end
        end
        S_CHANGELINE:begin
            if(shift_cnt_nxt==1 && shift_cnt!=shift_cnt_nxt )begin
                nxt_state = (line_cnt==LEN-1)?S_END:S_NORMAL;
            end
            else begin
                nxt_state = S_CHANGELINE;
            end
        end
        S_END:begin
            nxt_state = S_PRE;
        end
        default:begin
            nxt_state = S_PRE;
        end
    endcase
end


always @(*) begin
    case(cur_state)
        S_PRE:begin
            col_valid = 0;
            slide_en_reg = ivalid;
        end
        S_NORMAL:begin
            col_valid  = (shift_cnt[0]==1)&(shift_cnt>K-1) ;
            slide_en_reg = ivalid;
        end
        S_CHANGELINE:begin
            col_valid = 0;
            slide_en_reg = ivalid;
        end
        S_END:begin
            col_valid = (shift_cnt[0]==1)&(shift_cnt>K-1);
            slide_en_reg = ivalid;
        end
        default:begin
            col_valid = 0;
            slide_en_reg = 0;
        end
    endcase
end

always @(*) begin
    if(ivalid)begin
        shift_cnt_nxt=(shift_cnt==LEN)?1:shift_cnt+1;
        line_cnt_nxt=(shift_cnt==LEN)?line_cnt+1:line_cnt;
    end
    else begin
        shift_cnt_nxt=(cur_state==S_END)?0:shift_cnt;
        line_cnt_nxt=(cur_state==S_END)?0:line_cnt;
    end
end

generate
    genvar n;
    for(n=0;n<CH_NUM;n=n+1)begin:conv_slide_instance
        conv_single_slide #(
            .DATA_WIDTH(DATA_WIDTH),
            .K(K),
            .LEN(LEN)
        )u_conv_single_slide(
            .clk    (clk   ),
            .rstn   (rstn  ),
            .ivalid (slide_en_reg),
            .idata  (idata[n*DATA_WIDTH +: DATA_WIDTH]),
            .odata  (dout[n*K*K*DATA_WIDTH +: K*K*DATA_WIDTH])
        );
    end
endgenerate

endmodule