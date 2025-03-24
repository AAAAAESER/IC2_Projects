module conv_top#(
    parameter CONV_DATA_WIDTH = 1,
    parameter FC_DATA_WIDTH = 6,
    parameter K = 4,
    parameter LOGK = 4,
    parameter CH_NUM = 6
)(
    input wire clk,
    input wire rstn,

    input wire conv_valid,
    // output wire conv_ready,
    // input wire fc_valid,
    // output wire fc_ready,
    // input wire weight_ready,
    output wire weight_req,

    output wire out_conv_valid,
    output wire out_fc_valid,

    input wire [CH_NUM*K*K-1:0] weight,
    input wire [K*K*CONV_DATA_WIDTH-1:0] conv_data_in,
    output wire [CH_NUM*(CONV_DATA_WIDTH+LOGK+1-1) -1:0] conv_data_out,
    input wire [CH_NUM*K*K*FC_DATA_WIDTH-1:0] fc_data_in,
    output wire [CH_NUM*(FC_DATA_WIDTH+LOGK)-1:0] fc_data_out
);

reg mode; //0 for conv, 1 for fc

// wire [CH_NUM*K*K*FC_DATA_WIDTH-1:0] pad_conv_data_in;
wire [CH_NUM*K*K*FC_DATA_WIDTH-1:0] data_in;
wire [CH_NUM*(FC_DATA_WIDTH+LOGK)-1:0] data_out; 

//ready&req signal to:weight, conv_slide_input, fc_input
// reg conv_ready_r;
// reg fc_ready_r;
reg weight_req_r;
// assign conv_ready = conv_ready_r;
// assign fc_ready = fc_ready_r;
assign weight_req = weight_req_r;

//output valid signal for:conv_output, fc_output
reg out_conv_valid_r;
reg out_fc_valid_r;
assign out_conv_valid = out_conv_valid_r;
assign out_fc_valid = out_fc_valid_r;


//-------------FSM and Counter update--------------------
reg [6:0] conv_cnt,conv_cnt_nxt;
reg [3:0] fc_cnt,fc_cnt_nxt;

reg [2:0] cur_state,nxt_state;
localparam S_CONV = 3'b001;
localparam S_WEIGHT = 3'b010;
localparam S_FC = 3'b100;

always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        cur_state<= S_CONV;
        conv_cnt<=0;
        fc_cnt<=0;
    end
    else begin
        cur_state<=nxt_state;
        conv_cnt<=conv_cnt_nxt;
        fc_cnt<=fc_cnt_nxt;
    end
end

always @(*) begin
    case(cur_state)
        S_CONV:begin
            nxt_state = conv_cnt == 81 ? S_WEIGHT : S_CONV;
        end
        S_WEIGHT:begin
            // nxt_state = weight_ready ? S_FC : S_WEIGHT;
            nxt_state = (fc_cnt==10)?S_CONV:S_FC;
        end
        S_FC:begin
            nxt_state =  S_WEIGHT;
        end
        default:begin
            nxt_state = S_CONV;
        end
    endcase
end

always @(*) begin
    case(cur_state)
        S_CONV:begin
            mode = 0;
            // conv_ready_r = 1;
            // fc_ready_r = 0;
            weight_req_r = 0;

            out_conv_valid_r = conv_valid;
            out_fc_valid_r = 0;
        end
        S_WEIGHT:begin
            mode = 1;
            // conv_ready_r = 0;
            // fc_ready_r = 0;
            weight_req_r = 1;

            out_conv_valid_r = 0;
            out_fc_valid_r = 0;
        end
        S_FC:begin
            mode = 1;
            // conv_ready_r = 0;
            // fc_ready_r = 1;
            weight_req_r = 0;

            out_conv_valid_r = 0;
            out_fc_valid_r = 1;
        end
        default:begin
            mode = 0;
            // conv_ready_r = 0;
            // fc_ready_r = 0;
            weight_req_r = 0;

            out_conv_valid_r = 0;
            out_fc_valid_r = 0;
        end
    endcase
end

//counter update
always @(*) begin
    case(cur_state)
        S_CONV:begin
            conv_cnt_nxt = conv_valid ? conv_cnt+1 : conv_cnt;
            fc_cnt_nxt = 0;
        end
        S_WEIGHT:begin
            conv_cnt_nxt = 0;
            fc_cnt_nxt = fc_cnt;
        end
        S_FC:begin
            conv_cnt_nxt = 0;
            fc_cnt_nxt =  fc_cnt+1;
        end
        default:begin
            conv_cnt_nxt = 0;
            fc_cnt_nxt = 0;
        end
    endcase
end

// //conv_in_data copy and pad
// generate
//     genvar i0;
//     for(i0=0;i0<CH_NUM*K*K;i0=i0+1)begin:conv_in_pad
//         assign pad_conv_data_in[i0*FC_DATA_WIDTH +: FC_DATA_WIDTH] = conv_data_in[i0*CONV_DATA_WIDTH +: CONV_DATA_WIDTH];
//     end
// endgenerate
//input mux
generate
    genvar i1;
    for(i1=0;i1<CH_NUM*K*K;i1=i1+1)begin:data_in_mux_instance
        assign data_in[FC_DATA_WIDTH*i1 +:FC_DATA_WIDTH] =  mode ? fc_data_in[i1*FC_DATA_WIDTH +: FC_DATA_WIDTH]
                                   : {{(FC_DATA_WIDTH-CONV_DATA_WIDTH){1'b0}}, conv_data_in[(i1%(K*K))*CONV_DATA_WIDTH +:CONV_DATA_WIDTH]};
    end
endgenerate

//conv instance
generate
    genvar i2;
    for(i2=0;i2<CH_NUM;i2=i2+1)begin:conv_inst
        conv #(
            .DATA_WIDTH(FC_DATA_WIDTH),
            .K(K),
            .LOGK(LOGK)
        )conv_inst(
            .idata(data_in[i2*K*K*FC_DATA_WIDTH +: K*K*FC_DATA_WIDTH]),
            .weight(weight[i2*K*K +: K*K]),
            .dout(data_out[i2*(FC_DATA_WIDTH+LOGK) +: (FC_DATA_WIDTH+LOGK)])
        );
    end
endgenerate

//output change
generate
    genvar i3;
    for(i3=0;i3<CH_NUM;i3=i3+1)begin:data_out_mux_instance
        assign fc_data_out[i3*(FC_DATA_WIDTH+LOGK) +: (FC_DATA_WIDTH+LOGK)] = data_out[i3*(FC_DATA_WIDTH+LOGK) +: (FC_DATA_WIDTH+LOGK)];
        assign conv_data_out[i3*(CONV_DATA_WIDTH+LOGK+1-1) +: (CONV_DATA_WIDTH+LOGK+1-1) ] =
                             {data_out[i3*(FC_DATA_WIDTH+LOGK)+CONV_DATA_WIDTH+LOGK],data_out[i3*(FC_DATA_WIDTH+LOGK) +:CONV_DATA_WIDTH+LOGK+1-2]};
    end
endgenerate

endmodule
