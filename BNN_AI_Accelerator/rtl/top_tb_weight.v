`timescale 1ns/1ps

module top_tb;

// Parameter for clock period
parameter CLOCK_PERIOD = 7;
parameter DELAY = 0.5;
// parameter testnum = 100;
// Clock and reset signals
reg clk;
reg rst_n;

// Input signals
reg mode;
reg valid;
wire [15:0] data_in;
wire [1:0] data_out;
// Output signals
wire ready;
wire out_en;
`ifdef GATE_DEBUG
top_pad u_top_pad(
    .clk_pad      (clk      ),
    .rst_n_pad    (rst_n    ),
    .mode_pad     (mode     ),
    .data_in_pad  (data_in  ),
    .in_valid_pad (valid ),
    .data_out_pad (data_out ),
    .in_ready_pad (ready ),
    .out_en_pad   (out_en   )
);
`else
// Instantiate top module
top dut (
    .clk(clk),
    .rst_n(rst_n),
    .mode_port(mode),   
    .data_out_port(data_out), 
    .data_in_port(data_in),
    .in_valid_port(valid),
    .in_ready_port(ready),
    .out_en_port(out_en)
);
`endif

// Tristate buffer for inout_in
reg [15:0] weight_in, map_in;
assign data_in = mode ? {weight_in[0], weight_in[1], weight_in[2], weight_in[3], weight_in[4], weight_in[5], weight_in[6], weight_in[7], weight_in[8], weight_in[9], weight_in[10], weight_in[11], weight_in[12], weight_in[13], weight_in[14], weight_in[15]}
                        : map_in;
reg [3:0] result;
// Clock generation
initial clk = 0;
always #(CLOCK_PERIOD / 2.0) clk = ~clk; // Parameterized clock
// Declare filename as a string
reg [100*8:1] filename;
// Testbench logic
integer i,j,T;
reg [15:0] weight1 [6];
reg [15:0] weight2 [60];
reg [15:0] data [200];
reg [3:0] expected_label [0:0];
reg [3:0] ans_label[385];
integer cnt;
integer T_out;

initial begin
    
    rst_n = 1;
    mode = 0;
    valid = 0;
    map_in = 16'd0;
    $readmemb("./test/2/cov1_weight.txt", weight1);
    $readmemb("./test/2/fc1_weight.txt", weight2);
    $readmemh("./test/net_real_output.txt", ans_label);
    #CLOCK_PERIOD;
    rst_n = 0;
    weight_in = 0;
    #CLOCK_PERIOD;
    rst_n = 1;
    mode = 1;
    // Load weight1
    for (i = 0; i < 6; i = i + 1) begin
        @(posedge clk)begin
            #DELAY;
            valid = 1;
            weight_in = weight1[i];
        end
    end
    // Load weight2
    // @(negedge clk)valid = 1;
    for (i = 0; i < 10; i = i + 1) begin
        for(j = 0; j < 6 ; j=j+1)begin
            @(posedge clk)begin
                #DELAY;
                valid = 1;
                weight_in = weight2[i*6+j];
            end
        end
    end
    @(posedge clk)begin
        #DELAY;
        valid = 0;
        mode = 0;
    end
    for(T=0;T<100;T=T+1)begin
        $sformat(filename, "./test4/MNIST_images_%0d.txt", T);
        $readmemb(filename, data);
        
        // repeat(5)begin
        //     @(posedge clk)begin
        //     #DELAY;
        //     valid = 0;
        //     map_in = 16'hFFFF;
        //     end
        // end
        @(posedge clk)begin
            #DELAY;
            valid = 1;
            map_in = data[0];
        end
        i=1;
        while(i<200)begin
            @(posedge clk)begin
                if(valid&ready)begin
                    #DELAY;
                    map_in = data[i];
                    i=i+1;
                end
            end
        end
    end
    #(CLOCK_PERIOD*50);
    $display("Simulation finished %4d,error:%4d",T_out,cnt);
    // End simulation
    $finish;
end
reg isLow;
always @(posedge clk or negedge rst_n) begin    
    if(!rst_n)begin
        cnt <= 0;
        // out_cnt<=0;
        isLow<=0;
        T_out<=0;
        result<=0;
    end else begin
        if(out_en)begin
            if(isLow)begin
                result[1:0] = data_out;
                $sformat(filename, "./test4/MNIST_label_%0d.txt", T_out);
                $readmemh(filename, expected_label);
                // Compare result with expected values from MNIST_label files
                if (result !== expected_label[0]) begin
                    $display("Mismatch at test %2d: expected %3d, got %3d,at %t", T_out, expected_label[0], result,$time);
                    cnt=cnt+1;
                end else begin
                    // $display("   Match at test %2d: expected %3d, got %3d", T_out, expected_label[0], result);
                end

                // if (result !== ans_label[T_out]) begin
                //     $display("Mismatch at test %2d: expected %3d, got %3d", T_out,ans_label[T_out], result);
                //     cnt=cnt+1;
                // end else begin
                //     // $display("   Match at test %2d: expected %3d, got %3d", T_out,ans_label[T_out], result);
                // end
                
                isLow <= 1'b0;
                T_out<=T_out+1;
            end else begin
                result[3:2] = data_out;
                isLow <= 1'b1;
            end
            
        end
    end
end
initial begin
    $fsdbDumpfile("sim_output_pluson.fsdb");
    $fsdbDumpvars(0, top_tb);
    $fsdbDumpMDA();
end

endmodule
