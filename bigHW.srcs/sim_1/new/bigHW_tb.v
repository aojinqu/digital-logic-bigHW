`timescale 1ns / 1ps


module bigHW_tb;
    reg CLK; 
    reg RST_n;            	 //vga显示有效信号
	wire O_HS;                 //行同步信号                      
    wire O_VS;                 //场同步信号 
    wire [3:0] O_RED;
    wire [3:0] O_GREEN;
    wire [3:0] O_BLUE;


    reg[7:0]out_bluetooth;//蓝牙数据传输
    reg get_bluetooth;//接pmod
    reg [6:0] display;//对应数码管接口

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

