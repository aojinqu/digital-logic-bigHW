`timescale 1ns / 1ps

//处理收到的建码，转化成数字钟输出
//用于调试

module deal_key(
    input CLK,               //系统时钟
    input [31:0] keycode,
    input  keyup,             //是否接受到有效键码
    output reg [3:0]key_out
    );
    //计数器和参数
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
