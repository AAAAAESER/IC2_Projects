module pool_top (
    input wire clk,                          // ʱ���ź�
    input wire rst,                          // ��λ�ź�
    input wire valid,                 // дʹ���ź�
    input wire [5*3*3*6-1:0] data_in,       // �������ݣ�6��ͨ����3x3����ÿ������Ԫ��Ϊ6λ
    output wire [5*16-1:0] memory_0,              // �洢ģ�� 0 ���
    output wire [5*16-1:0] memory_1,              // �洢ģ�� 1 ���
    output wire [5*16-1:0] memory_2,              // �洢ģ�� 2 ���
    output wire [5*16-1:0] memory_3,              // �洢ģ�� 3 ���
    output wire [5*16-1:0] memory_4,              // �洢ģ�� 4 ���
    output wire [5*16-1:0] memory_5               // �洢ģ�� 5 ���
);

    // ������ݣ��ػ���Ľ��
    wire [4:0] pool_data_out_0;
    wire [4:0] pool_data_out_1;
    wire [4:0] pool_data_out_2;
    wire [4:0] pool_data_out_3;
    wire [4:0] pool_data_out_4;
    wire [4:0] pool_data_out_5;

    // ʵ�����ػ���ģ��
    pooling_layer #(
        .NUM_CHANNELS(6),
        .DATA_WIDTH(5),
        .MATRIX_DIM(3)
    ) pooling_inst (
        .data_in(data_in),                       // �������ݣ�6ͨ����ÿ��ͨ����һ��3x3����
        .data_out({pool_data_out_5, pool_data_out_4, pool_data_out_3, pool_data_out_2, pool_data_out_1, pool_data_out_0}) // �ػ�������
    );

    // ʵ�����洢ģ��
    storage_layer #(
        .DATA_WIDTH(5),
        .NUM_ELEMENTS(16)
    ) storage_inst (
        .clk(clk),                               // ʱ���ź�
        .reset(rst),                             // ��λ�ź�
        .valid(valid),             // дʹ���ź�
        .data_in_0(pool_data_out_0),            // �ӳػ���õ��ĵ�0ͨ������
        .data_in_1(pool_data_out_1),            // �ӳػ���õ��ĵ�1ͨ������
        .data_in_2(pool_data_out_2),            // �ӳػ���õ��ĵ�2ͨ������
        .data_in_3(pool_data_out_3),            // �ӳػ���õ��ĵ�3ͨ������
        .data_in_4(pool_data_out_4),            // �ӳػ���õ��ĵ�4ͨ������
        .data_in_5(pool_data_out_5),            // �ӳػ���õ��ĵ�5ͨ������
        .memory_0(memory_0),                    // �洢ģ�� 0 ���
        .memory_1(memory_1),                    // �洢ģ�� 1 ���
        .memory_2(memory_2),                    // �洢ģ�� 2 ���
        .memory_3(memory_3),                    // �洢ģ�� 3 ���
        .memory_4(memory_4),                    // �洢ģ�� 4 ���
        .memory_5(memory_5)                     // �洢ģ�� 5 ���
    );

endmodule

