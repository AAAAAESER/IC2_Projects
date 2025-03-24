`timescale 1ns/1ps

module top_tb;

// Parameter for clock period
parameter CLOCK_PERIOD = 80;

// Clock and reset signals
reg clk;
reg rst_n;

// Input signals
reg mode;
reg valid;
wire [15:0] data_in;
wire [3:0] inout_in;
// Output signals
wire ready;
wire out_en;

// Instantiate top module
top dut (
    .clk(clk),
    .rst_n(rst_n),
    .mode_port(mode),
    .data_inout_port(inout_in), 
    .data_in_port(data_in[15:4]),
    .in_valid_port(valid),
    .in_ready_port(ready),
    .out_en_port(out_en)
);

// Tristate buffer for inout_in
assign inout_in = out_en ? 4'bz : data_in[3:0];
wire [3:0] inout_out;
assign inout_out = inout_in;
reg [15:0] weight_in, map_in;
assign data_in = mode ? {weight_in[0], weight_in[1], weight_in[2], weight_in[3], weight_in[4], weight_in[5], weight_in[6], weight_in[7], weight_in[8], weight_in[9], weight_in[10], weight_in[11], weight_in[12], weight_in[13], weight_in[14], weight_in[15]}: map_in;

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
initial begin
    
    for(T=0;T<10;T=T+1)begin
        // Initialize signals
        rst_n = 0;
        mode = 0;
        valid = 0;
        map_in = 16'd0;

        // Load weights and data from files
        $readmemb("./test/2/cov1_weight.txt", weight1);
        $readmemb("./test/2/fc1_weight.txt", weight2);
        // $readmemb("./test/MNIST_images_0.txt", data);
        // Load multiple data files
        // for (i = 0; i < 10; i = i + 1) begin
        $sformat(filename, "./test/MNIST_images_%0d.txt", T);
        $readmemb(filename, data);
        // end
            // Release reset
        #40;
        rst_n = 1;

        // Load weight1
        mode = 1;
        for (i = 0; i < 6; i = i + 1) begin
            @(negedge clk)begin
                valid = 1;
                weight_in = weight1[i];
            end
        end
        @(negedge clk)begin
            mode = 0;
            valid = 0;
        end
        #400;

        // Load data
        for (i = 0; i < 136; i = i + 1) begin
            @(negedge clk)begin
                valid = 1;
                map_in = data[i];
            end
        end
        @(negedge clk)valid = 0;

        #400;

        // Load weight2
        @(negedge clk)mode = 1;
        for (i = 0; i < 10; i = i + 1) begin
            wait(ready);
            for(j = 0; j < 6 ; j=j+1)begin
                @(negedge clk)begin
                    valid = 1;
                    weight_in = weight2[i*6+j];
                end
            end
            @(negedge clk );
        end
        @(negedge clk)valid = 0;
        // Compare inout_out with expected values from MNIST_label files
        $sformat(filename, "./test/MNIST_label_%0d.txt", T);
        $readmemh(filename, expected_label);
        @(negedge clk);
        wait(out_en);
        @(negedge clk);
        if (inout_out !== expected_label[0]) begin
            $display("Mismatch at test %2d: expected %3d, got %3d", T, expected_label[0], inout_out);
        end else begin
            $display("   Match at test %2d: expected %3d, got %3d", T, expected_label[0], inout_out);
        end
        // End simulation
        #400;
    end

    $finish;
end

initial begin
    $fsdbDumpfile("sim_output_pluson.fsdb");
    $fsdbDumpvars(0, top_tb);
    $fsdbDumpMDA();
end

endmodule
