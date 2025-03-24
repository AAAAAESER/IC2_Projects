module storage_layer #(
    parameter DATA_WIDTH = 6,        // ÿ������λ��
    parameter NUM_ELEMENTS = 16      // �洢Ԫ�ص�����������ÿ���洢ģ��洢 16 ��Ԫ�أ�
)(
    input wire clk,                    // ʱ���ź�
    input wire reset,                  // ��λ�ź�
    input wire valid,           // дʹ���ź�
    input wire [DATA_WIDTH-1:0] data_in_0,  // �洢�ػ�ģ��0���������
    input wire [DATA_WIDTH-1:0] data_in_1,  // �洢�ػ�ģ��1���������
    input wire [DATA_WIDTH-1:0] data_in_2,  // �洢�ػ�ģ��2���������
    input wire [DATA_WIDTH-1:0] data_in_3,  // �洢�ػ�ģ��3���������
    input wire [DATA_WIDTH-1:0] data_in_4,  // �洢�ػ�ģ��4���������
    input wire [DATA_WIDTH-1:0] data_in_5,  // �洢�ػ�ģ��5���������
    
    output wire [DATA_WIDTH*NUM_ELEMENTS-1:0] memory_0,  // �洢ģ�� 0 ���
    output wire [DATA_WIDTH*NUM_ELEMENTS-1:0] memory_1,  // �洢ģ�� 1 ���
    output wire [DATA_WIDTH*NUM_ELEMENTS-1:0] memory_2,  // �洢ģ�� 2 ���
    output wire [DATA_WIDTH*NUM_ELEMENTS-1:0] memory_3,  // �洢ģ�� 3 ���
    output wire [DATA_WIDTH*NUM_ELEMENTS-1:0] memory_4,  // �洢ģ�� 4 ���
    output wire [DATA_WIDTH*NUM_ELEMENTS-1:0] memory_5   // �洢ģ�� 5 ���
);

    // ���� 6 ���洢ģ�飬���ڴ洢�ػ�������
    reg [DATA_WIDTH-1:0] memory_0_reg [0:NUM_ELEMENTS-1];
    reg [DATA_WIDTH-1:0] memory_1_reg [0:NUM_ELEMENTS-1];
    reg [DATA_WIDTH-1:0] memory_2_reg [0:NUM_ELEMENTS-1];
    reg [DATA_WIDTH-1:0] memory_3_reg [0:NUM_ELEMENTS-1];
    reg [DATA_WIDTH-1:0] memory_4_reg [0:NUM_ELEMENTS-1];
    reg [DATA_WIDTH-1:0] memory_5_reg [0:NUM_ELEMENTS-1];

    // ������������ȷ��ÿ��д���ĸ�λ��
    reg [4:0] write_address;

    // д����
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            write_address <= 0; // ��λʱ����������
        end else if (valid) begin
            // ���ػ�ģ����������д���Ӧ�Ĵ洢ģ��
            memory_0_reg[write_address] <= data_in_0;
            memory_1_reg[write_address] <= data_in_1;
            memory_2_reg[write_address] <= data_in_2;
            memory_3_reg[write_address] <= data_in_3;
            memory_4_reg[write_address] <= data_in_4;
            memory_5_reg[write_address] <= data_in_5;

            if (write_address == NUM_ELEMENTS-1)
                write_address <= 0;  // �ﵽ���һ��λ�ú󣬹��������
            else
                write_address <= write_address + 1;  // �������������
        end
    end

    // ���洢�Ľ�����������ģ��
genvar i;
 

generate
      

for (i = 0; i <NUM_ELEMENTS ; i = i + 1)
	begin :cunchu       
    assign memory_0[(i+1)*5-1:i*5] = memory_0_reg[i];
    assign memory_1[(i+1)*5-1:i*5] = memory_1_reg[i];
    assign memory_2[(i+1)*5-1:i*5] = memory_2_reg[i];
    assign memory_3[(i+1)*5-1:i*5] = memory_3_reg[i];
    assign memory_4[(i+1)*5-1:i*5] = memory_4_reg[i];
    assign memory_5[(i+1)*5-1:i*5] = memory_5_reg[i];
end
  

endgenerate


endmodule
