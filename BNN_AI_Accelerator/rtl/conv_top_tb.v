`timescale 1ns/1ps

module conv_top_tb;

parameter CONV_DATA_WIDTH = 1;
parameter FC_DATA_WIDTH = 6;
parameter K = 4;
parameter LOGK = 4;
parameter CH_NUM = 6;

reg clk;
reg rstn;
reg conv_valid;
reg fc_valid;
reg weight_ready;

wire conv_ready;
wire fc_ready;
wire weight_req;
wire out_conv_valid;
wire out_fc_valid;

reg [CH_NUM*K*K-1:0] weight;
reg [K*K*CONV_DATA_WIDTH-1:0] conv_data_in;
wire [CH_NUM*(CONV_DATA_WIDTH+LOGK+1)-1:0] conv_data_out;
reg [CH_NUM*K*K*FC_DATA_WIDTH-1:0] fc_data_in;
wire [CH_NUM*(FC_DATA_WIDTH+LOGK)-1:0] fc_data_out;

reg [CH_NUM*(CONV_DATA_WIDTH+LOGK+1)-1:0] conv_data_out_expect;
reg [CH_NUM*(FC_DATA_WIDTH+LOGK)-1:0] fc_data_out_expect;
conv_top #(
    .CONV_DATA_WIDTH(CONV_DATA_WIDTH),
    .FC_DATA_WIDTH(FC_DATA_WIDTH),
    .K(K),
    .LOGK(LOGK),
    .CH_NUM(CH_NUM)
) uut (
    .clk(clk),
    .rstn(rstn),
    .conv_valid(conv_valid),
    .conv_ready(conv_ready),
    .fc_valid(fc_valid),
    .fc_ready(fc_ready),
    .weight_ready(weight_ready),
    .weight_req(weight_req),
    .out_conv_valid(out_conv_valid),
    .out_fc_valid(out_fc_valid),
    .weight(weight),
    .conv_data_in(conv_data_in),
    .conv_data_out(conv_data_out),
    .fc_data_in(fc_data_in),
    .fc_data_out(fc_data_out)
);

initial begin
    clk = 0;
    rstn = 0;
    conv_valid = 0;
    fc_valid = 0;
    weight_ready = 0;
    weight = 0;
    conv_data_in = 0;
    fc_data_in = 0;

    #10 rstn = 1;
    #10 load_weights();
    #10 start_conv();
    #10 start_fc();
    #10 $finish;
end

always #5 clk = ~clk;

task load_weights;
    integer i;
    begin
        weight = 0;
        for (i = 0; i < CH_NUM*K*K; i = i + 1) begin
            weight[i] = $random % 2;
        end
        // #10 weight_ready = 1;
        // #10 weight_ready = 0;
    end
endtask

task start_conv;
    integer i;
    begin
        for (i = 0; i < 81; i = i + 1) begin
            conv_data_in = $random % (1 << (K*K*CONV_DATA_WIDTH));
            conv_valid = 1;
            #5;
            // Add verification logic here
            conv_data_out_expect = expected_conv_data_out(conv_data_in);
            if (conv_data_out !== conv_data_out_expect) begin
                $display("Error: conv_data_out mismatch at time %t", $time);
            end
            #5;
            conv_valid = 0;
            #10;
        end
       
    end
endtask

reg [CONV_DATA_WIDTH+LOGK+1-1:0] single_conv_data;
function [CH_NUM*(CONV_DATA_WIDTH+LOGK+1)-1:0] expected_conv_data_out;
    input [K*K*CONV_DATA_WIDTH-1:0] data_in;
    integer j,k;
    begin
        expected_conv_data_out = 0;
        for (j = 0; j < CH_NUM; j = j + 1) begin
            single_conv_data =0;
            for (k=0;k<K*K;k=k+1)begin
                if (weight[j*K*K+k])
                    single_conv_data = single_conv_data + $signed(data_in[k*CONV_DATA_WIDTH +: CONV_DATA_WIDTH]);
                else
                    single_conv_data = single_conv_data - $signed(data_in[k*CONV_DATA_WIDTH +: CONV_DATA_WIDTH]);
            end
            expected_conv_data_out[j*(CONV_DATA_WIDTH+LOGK+1) +: (CONV_DATA_WIDTH+LOGK+1)] = single_conv_data; // Simplified example
        end
    end
endfunction

task start_fc;
    integer i, j, k;
    begin
        for (j = 0; j < 10; j = j + 1) begin
            for (k = 0; k < CH_NUM*K*K; k = k + 1) begin
                weight[k] = $random % 2;
            end
            #10;
            #10 weight_ready = 1;
            #10 weight_ready = 0;
            for (i = 0; i < CH_NUM*K*K; i = i + 1) begin
                fc_data_in[i*FC_DATA_WIDTH +: FC_DATA_WIDTH] = $random % (1 << FC_DATA_WIDTH);
            end
            fc_valid = 1;
            #5;
            // Add verification logic here
            fc_data_out_expect = expected_fc_data_out(fc_data_in);
            if (fc_data_out !== fc_data_out_expect) begin
                $display("Error: fc_data_out mismatch at time %t,expect:%d ,got %d", $time,fc_data_out_expect[9:0],fc_data_out[9:0]);
            end
            #5;
            fc_valid = 0;
        end
    end
endtask
reg signed [FC_DATA_WIDTH+LOGK-1:0] single_fc_data;
function [CH_NUM*(FC_DATA_WIDTH+LOGK)-1:0] expected_fc_data_out;
    input [CH_NUM*K*K*FC_DATA_WIDTH-1:0] data_in_fc;
    integer l,m;
    begin
        expected_fc_data_out = 0;
        for (l = 0; l < CH_NUM; l = l + 1) begin
            single_fc_data = 0;
            for(m=0; m<K*K; m=m+1)begin
                if (weight[l*K*K+m])
                    single_fc_data = single_fc_data + $signed(data_in_fc[(l*K*K+m)*FC_DATA_WIDTH +: FC_DATA_WIDTH]);
                else
                    single_fc_data = single_fc_data - $signed(data_in_fc[(l*K*K+m)*FC_DATA_WIDTH +: FC_DATA_WIDTH]);
            end
            expected_fc_data_out[l*(FC_DATA_WIDTH+LOGK) +: (FC_DATA_WIDTH+LOGK)] = single_fc_data; // Simplified example
        end
    end
endfunction
initial
begin
    $fsdbDumpfile("sim_output_pluson.fsdb");
    $fsdbDumpvars(0,conv_top_tb);
    $fsdbDumpMDA();
end


endmodule