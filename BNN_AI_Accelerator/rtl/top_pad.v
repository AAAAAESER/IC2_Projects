module top_pad(
    input clk_pad,
    input rst_n_pad,
    input mode_pad,
    input [15:0]data_in_pad,
    input in_valid_pad,
    output [1:0]data_out_pad,
    output in_ready_pad,
    output out_en_pad
);

wire clk          ;
wire rst_n        ;
wire mode_port    ;
wire [15:0]data_in_port ;
wire in_valid_port;
wire [1:0]data_out_port;
wire in_ready_port;
wire out_en_port  ;

PIW IO_PAD1(.PAD(clk_pad),.C(clk));
PISW IO_PAD2(.PAD(rst_n_pad),.C(rst_n));
PIW IO_PAD3(.PAD(mode_pad),.C(mode_port));
PIW IO_PAD4(.PAD(data_in_pad[0]),.C(data_in_port[0]));
PIW IO_PAD5(.PAD(data_in_pad[1]),.C(data_in_port[1]));
PIW IO_PAD6(.PAD(data_in_pad[2]),.C(data_in_port[2]));
PIW IO_PAD7(.PAD(data_in_pad[3]),.C(data_in_port[3]));
PIW IO_PAD8(.PAD(data_in_pad[4]),.C(data_in_port[4]));
PIW IO_PAD9(.PAD(data_in_pad[5]),.C(data_in_port[5]));
PIW IO_PAD10(.PAD(data_in_pad[6]),.C(data_in_port[6]));
PIW IO_PAD11(.PAD(data_in_pad[7]),.C(data_in_port[7]));
PIW IO_PAD12(.PAD(data_in_pad[8]),.C(data_in_port[8]));
PIW IO_PAD13(.PAD(data_in_pad[9]),.C(data_in_port[9]));
PIW IO_PAD14(.PAD(data_in_pad[10]),.C(data_in_port[10]));
PIW IO_PAD15(.PAD(data_in_pad[11]),.C(data_in_port[11]));
PIW IO_PAD16(.PAD(data_in_pad[12]),.C(data_in_port[12]));
PIW IO_PAD17(.PAD(data_in_pad[13]),.C(data_in_port[13]));
PIW IO_PAD18(.PAD(data_in_pad[14]),.C(data_in_port[14]));
PIW IO_PAD19(.PAD(data_in_pad[15]),.C(data_in_port[15]));
PIW IO_PAD20(.PAD(in_valid_pad),.C(in_valid_port));

PO12W IO_PAD21(.I(data_out_port[0]),.PAD(data_out_pad[0]));
PO12W IO_PAD22(.I(data_out_port[1]),.PAD(data_out_pad[1]));
PO12W IO_PAD23(.I(in_ready_port),.PAD(in_ready_pad));
PO12W IO_PAD24(.I(out_en_port),.PAD(out_en_pad));

top u_top(
    .clk           (clk           ),
    .rst_n         (rst_n         ),
    .mode_port     (mode_port     ),
    .data_in_port  (data_in_port  ),
    .in_valid_port (in_valid_port ),
    .data_out_port (data_out_port ),
    .in_ready_port (in_ready_port ),
    .out_en_port   (out_en_port   )
);



endmodule