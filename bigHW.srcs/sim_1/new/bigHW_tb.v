`timescale 1ns / 1ps


module bigHW_tb;
    reg CLK; 
    reg RST_n;            	 //vga��ʾ��Ч�ź�
	wire O_HS;                 //��ͬ���ź�                      
    wire O_VS;                 //��ͬ���ź� 
    wire [3:0] O_RED;
    wire [3:0] O_GREEN;
    wire [3:0] O_BLUE;


    reg[7:0]out_bluetooth;//�������ݴ���
    reg get_bluetooth;//��pmod
    reg [6:0] display;//��Ӧ����ܽӿ�

initial begin
    RST_n=0;
    CLK=0;
    out_bluetooth=18;
end

always @(*) begin
   //#40 CLK<=~CLK;
    out_bluetooth<=out_bluetooth+1;
    if(out_bluetooth==28)
    out_bluetooth<=18;
end

always #20 CLK=~CLK;
always #40 out_bluetooth=out_bluetooth+1;

	display7 uut(
		.CLK(CLK),
		.iData(out_bluetooth[3:0]),
		.oData(display)
	);

endmodule

