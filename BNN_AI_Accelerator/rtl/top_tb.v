`timescale 1ns/1ps

module top_tb;

// Clock and reset signals
reg clk;
reg rst_n;

// Input signals
reg mode;
reg valid;
reg [15:0] data_in;
wire [3:0]inout_in;
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

// Clock generation
initial clk = 0;
always #5 clk = ~clk; // 100MHz clock

// Testbench logic
integer i,j;
reg [3:0] data_group [3:0];
initial begin
    // Initialize signals
    rst_n = 0;
    mode = 0;
    valid = 0;
    data_in = 16'd0;

    // Release reset
    #20;
    rst_n = 1;

    // Mode = 1, load 96-bit weights
    mode = 1;
    #10;
    repeat (6) begin
        @(posedge clk);
        valid <= 1;
        data_in <= $random;
    end
    @(posedge clk);
    // @(posedge clk);
    valid<=0;
    // Mode = 0, send data
    mode <= 0;
    #100;


    for (i = 0; i < 150; i = i + 1) begin
        // Prepare data_in with incrementing 4-bit groups from 0 to 15
        for (j = 0; j < 4; j = j + 1) begin
            data_group[j] = (i+j)%16;
        end
        data_in <= {data_group[3], data_group[2], data_group[1], data_group[0]};
        // Send data when ready and valid are high
        @(negedge clk);  
        valid = 1;
       
    end
    @(negedge clk);
    valid = 0;
    
    #100;
    // Wait for ready to go high
    mode =1;
    repeat(10)begin
        wait(ready);
        repeat (6) begin
            @(negedge clk);
            valid = 1;
            data_in = $random;
        end
        @(negedge clk);
        valid=0;
    end
    


    // End simulation
    #100;
    $finish;
end
initial
begin
    $fsdbDumpfile("sim_output_pluson.fsdb");
    $fsdbDumpvars(0,top_tb);
    $fsdbDumpMDA();
end
endmodule