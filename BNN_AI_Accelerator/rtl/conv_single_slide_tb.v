`timescale 1ns / 1ps
module conv_single_slide_tb;
    parameter DATA_WIDTH = 6;
    parameter K = 3;
    parameter LEN = 9;
    reg clk;
    reg rstn;
    reg ivalid;
    reg [DATA_WIDTH-1 :0] idata;
    wire ovalid;
    wire [K*K*DATA_WIDTH-1:0] odata;

    // Instantiate the DUT (Device Under Test)
   conv_single_slide #(
    .DATA_WIDTH(DATA_WIDTH),
    .K(K),
    .LEN(LEN)
   )u_conv_single_slide(
       .clk    (clk   ),
       .rstn   (rstn  ),
       .ivalid (ivalid),
       .idata  (idata ),
       .odata  (odata )
   );
   

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period clock
    end

    // Testbench logic
    initial begin
        // Initialize signals
        rstn = 0;
        ivalid = 0;
        idata = 0;

        // Reset the DUT
        #20;
        rstn = 1;

        // Apply inputs
        for (integer i = 0; i < 81; i = i + 1) begin
            @(posedge clk);
            ivalid = 1;
            idata = i;
            @(posedge clk);
            ivalid = 0;
        end

        // Deassert ivalid after all inputs are applied
        @(posedge clk);
        ivalid = 0;

        // Wait for a few clock cycles to observe the output
        #100;

        // Finish simulation
        $finish;
    end

    initial
    begin
        $fsdbDumpfile("sim_output_pluson.fsdb");
        $fsdbDumpvars(0,conv_single_slide_tb);
        $fsdbDumpMDA();
    end


endmodule