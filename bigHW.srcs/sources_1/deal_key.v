`timescale 1ns / 1ps

//�����յ��Ľ��룬ת�������������
//���ڵ���

module deal_key(
    input CLK,               //ϵͳʱ��
    input [31:0] keycode,
    input  keyup,             //�Ƿ���ܵ���Ч����
    output reg [3:0]key_out
    );
    //�������Ͳ���
    integer clk_cnt=0;
    wire clk;

Divider #(.N(100)) CLKDIV3(CLK,clk);        //1MHz

always @(posedge clk) 
begin
   // if(keyup)
   // begin
        key_out<=keycode[31:28];//3'b011;//HEX0;
       // clk_cnt=clk_cnt+1;
   // end
end

endmodule
