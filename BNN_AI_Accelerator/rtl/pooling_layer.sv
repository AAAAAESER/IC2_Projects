module pooling_layer #(
    parameter NUM_CHANNELS = 6,        // ͨ����
    parameter DATA_WIDTH = 6,          // ÿ������λ��
    parameter MATRIX_DIM = 3           // ��������ά�ȣ�3x3��
)(
    input wire [NUM_CHANNELS * MATRIX_DIM * MATRIX_DIM * DATA_WIDTH - 1:0] data_in, // �������ݣ�ÿ��ͨ����3x3����
    output wire [NUM_CHANNELS * DATA_WIDTH - 1:0] data_out    // ����ػ������ÿ��ͨ��һ���ػ�ֵ��
);

    // ���ɶ�����еĳػ�ģ��
    genvar i;
    generate
        for (i = 0; i < NUM_CHANNELS; i = i + 1) begin : gen_pooling_channel
            pooling_channel #(
                .DATA_WIDTH(DATA_WIDTH),
                .MATRIX_DIM(MATRIX_DIM)
            ) channel_inst (
                .data_in(data_in[(i+1)*MATRIX_DIM*MATRIX_DIM*DATA_WIDTH-1:i*MATRIX_DIM*MATRIX_DIM*DATA_WIDTH]),
                .data_out(data_out[(i+1)*DATA_WIDTH-1:i*DATA_WIDTH])
            );
        end
    endgenerate

endmodule
