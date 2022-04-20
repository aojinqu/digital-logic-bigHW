module vga_display(
    input clk_vga,//����vga��ʱ�ӣ�Ƶ��Ϊ25.175MHz
    input rst,//��λ�źţ��ߵ�ƽ��Ч
    input [11:0] color_data_in,//��RAM�ж�ȡ��������Ϣ
    output reg[18:0] ram_addr,//Ӧ�ö�ȡ��RAM��ͼƬ��ַ����vga_control����
    output x_valid,
    output y_valid,
    output reg[3:0] red,
    output reg[3:0] blue,
    output reg[3:0] green
);
    parameter x_before=11'd144;
    parameter y_before=11'd35;
    parameter x_size_pic=11'd640;
    parameter y_size_pic=11'd480;
    
    wire [11:0] x_poi;//�����ʱx������
    wire [11:0] y_poi;//�����ʱy������
    wire is_display;//������ʱ�Ƿ��ܹ����

    vga_control control(clk_vga,rst,x_poi,y_poi,is_display,x_valid,y_valid);

    always@ (*)
    begin
        red=0;
        blue=0;
        green=0;
        if(is_display)
        begin
            if(x_poi-x_before<=x_size_pic&&y_poi-y_before<=y_size_pic)
            begin
            ram_addr=(y_poi-y_before)*x_size_pic+(x_poi-x_before);
            red=color_data_in[11:8];
            green=color_data_in[7:4];
            blue=color_data_in[3:0];
            end
            else
            begin
            red=0;
            green=0;
            blue=0;
            end
        end
    end
endmodule