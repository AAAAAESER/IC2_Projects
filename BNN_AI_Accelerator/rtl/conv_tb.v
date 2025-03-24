`timescale 1ns / 1ps
module conv_tb;

  // Parameters
  localparam  DATA_WIDTH = 4;
  localparam K = 4;

  //Ports
  reg  clk;
  reg  rstn;
  reg  ivalid;
  reg [K*K*DATA_WIDTH-1:0] idata;
  reg [K*K-1:0] weight;
  wire signed[DATA_WIDTH+4-1:0] dout;
  reg signed [DATA_WIDTH+4-1:0] expected_dout;
  

  conv # (
    .DATA_WIDTH(DATA_WIDTH),
    .K(K),
    .LOGK(4)
  )
  conv_inst (
    .idata(idata),
    .weight(weight),
    .dout(dout)
  );


always #5  clk = ! clk ;

initial begin
  // Initialize Inputs
  clk = 0;
  rstn = 0;
  ivalid = 0;
  idata = 0;
  weight = 0;

  // Reset the system
  #10;
  rstn = 1;

  // // Apply inputs
  // #10;
  // ivalid = 1;
  // idata = {8'd24, 8'd23, 8'd22, 8'd21, 8'd20, 8'd19, 8'd18, 8'd17, 8'd16, 8'd15, 8'd14, 8'd13, 8'd12, 8'd11, 8'd10, 8'd9, 8'd8, 8'd7, 8'd6, 8'd5, 8'd4, 8'd3, 8'd2, 8'd1, 8'd0};

  // #10;
  // ivalid = 1;
  // idata = 5*5*8'd0;
  // // Wait for some time
  // #100;
  // ivalid = 0;
  // // Generate random data and compare results
repeat (1000) begin
    // Generate random input data
    idata = $random;
    weight = $random;

    // Check for overflow condition and regenerate if necessary
    for (integer i = 0; i < K*K; i = i + 1) begin
        while (idata[i*DATA_WIDTH +: DATA_WIDTH] == {1'b1, {(DATA_WIDTH-1){1'b0}}}) begin
            idata[i*DATA_WIDTH +: DATA_WIDTH] = $random;
        end
    end

    // Apply inputs
    #10;
    ivalid = 1;
    // Calculate expected output
    expected_dout = 0;
    for (integer i = 0; i < K*K; i = i + 1) begin
        if (weight[i])
            expected_dout = expected_dout + $signed(idata[i*DATA_WIDTH +: DATA_WIDTH]);
        else
            expected_dout = expected_dout - $signed(idata[i*DATA_WIDTH +: DATA_WIDTH]);
    end

    // Wait for the output to be valid
    #10;
    if (dout !== expected_dout) begin
        $display("Test failed at time %t: expected %d, got %d", $time, expected_dout, dout);
    end else begin
        // $display("Test passed: expected %d, got %d", expected_dout, dout);
    end

    // Deassert ivalid
    ivalid = 0;
    #10;
end

  // Finish the simulation
  #100;
  $finish;
end


// `ifdef DUMP_VPD
//     initial
//     begin
//         $vcdpluson;
//     end
// `endif

// `ifdef DUMP_VCD
//     initial begin
//         $vcdplusfile("sim_output_pluson.vpd");
//         $vcdpluson(0, conv_55_inst); 
//     end
// `endif

`ifdef DUMP_FSDB
    initial
    begin
        $fsdbDumpfile("sim_output_pluson.fsdb");
        $fsdbDumpvars(0,conv_tb);
        $fsdbDumpMDA();
    end
`endif

endmodule