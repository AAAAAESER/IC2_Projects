`timescale 1ns/1ps

module top_tb;

// Parameter for clock period
parameter CLOCK_PERIOD = 20;

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
assign data_in = mode ? {weight_in[0], weight_in[1], weight_in[2], weight_in[3], weight_in[4], weight_in[5], weight_in[6], weight_in[7], weight_in[8], weight_in[9], weight_in[10], weight_in[11], weight_in[12], weight_in[13], weight_in[14], weight_in[15]}: map_in;
reg [3:0] result;
// Clock generation
initial clk = 0;
always #(CLOCK_PERIOD / 2) clk = ~clk; // Parameterized clock
// Declare filename as a string
reg [100*8:1] filename;
// Testbench logic
integer i,j,T;
reg [15:0] weight1 [6];
reg [15:0] weight2 [60];
reg [15:0] data [136];
reg [3:0] expected_label [0:0];
reg [3:0] ans_label[385];
integer cnt;
initial begin
    cnt = 0;
    result =0;
    rst_n = 1;
    mode = 0;
    valid = 0;
    map_in = 16'd0;
    $readmemb("./test/2/cov1_weight.txt", weight1);
    $readmemb("./test/2/fc1_weight.txt", weight2);
    $readmemh("./test/net_real_output.txt", ans_label);
    #CLOCK_PERIOD;
    rst_n = 0;
    #CLOCK_PERIOD;
    rst_n = 1;
    mode = 1;
    // Load weight1
    for (i = 0; i < 6; i = i + 1) begin
        @(negedge clk)begin
            valid = 1;
            weight_in = weight1[i];
        end
    end
    @(negedge clk)begin
        valid = 0;
    end
    #400;

    // Load weight2
    // @(negedge clk)valid = 1;
    for (i = 0; i < 10; i = i + 1) begin
        // wait(ready;
        for(j = 0; j < 6 ; j=j+1)begin
            @(negedge clk)begin
                valid = 1;
                weight_in = weight2[i*6+j];
            end
        end
    end
    @(negedge clk)begin
        valid = 0;
        mode = 0;
    end

    for(T=0;T<380;T=T+1)begin
        // Initialize signals

        // Load weights and data from files
        
        // $readmemb("./test/MNIST_images_0.txt", data);
        // Load multiple data files
        // for (i = 0; i < 10; i = i + 1) begin
        // $sformat(filename, "./test/1/data.txt");
        $sformat(filename, "./test2/MNIST_images_%0d.txt", T);
        $readmemb(filename, data);
        // end
            // Release reset
        
        // Load data
        for (i = 0; i < 136; i = i + 1) begin
            @(negedge clk)begin
                valid = 1;
                map_in = data[i];
            end
        end        
        @(negedge clk)begin
            valid = 0;
        end
        // Compare result with expected values from MNIST_label files
        // $sformat(filename, "./test/1/result.txt");
        $sformat(filename, "./test2/MNIST_label_%0d.txt", T);
        $readmemh(filename, expected_label);
        wait(out_en);
        @(posedge clk) begin
            result[3:2] = data_out;
        end
        @(posedge clk) begin
            result[1:0] = data_out;
        end
        if (result !== expected_label[0]) begin
            $display("Mismatch at test %2d: expected %3d, got %3d", T, expected_label[0], result);
            cnt=cnt+1;
        end else begin
            // $display("   Match at test %2d: expected %3d, got %3d", T, expected_label[0], result);
        end
        // if (result !== ans_label[T]) begin
        //     $display("Mismatch at test %2d: expected %3d, got %3d", T,ans_label[T], result);
        //     cnt=cnt+1;
        // end else begin
        //     // $display("   Match at test %2d: expected %3d, got %3d", T,ans_label[T], result);
        // end
        #CLOCK_PERIOD;
        // End simulation
            
    end
    $display("Simulation finished ,error:%d",cnt);
    $finish;
end

always @(posedge clk or negedge rst_n) begin

end
initial begin
    $fsdbDumpfile("sim_output_pluson.fsdb");
    $fsdbDumpvars(0, top_tb);
    $fsdbDumpMDA();
end

endmodule
