`timescale 1ns / 1ps

//实现了一个移位寄存器来保存22位数据，
//根据移位寄存器的某些位输出两个十六进制值，
//从KB移入SDATA并在读取" F0"时发出选通信号
module keyboard(
    input clk,    //时钟信号
    input usbCLK,//同步usb信号
    input usbDATA,//同步usb数据
    input RST_n,        //是否从键盘中读取数据
    output [31:0] keycodeout,

   // output [3:0] HEX0,//16进制键码
    //output [3:0] HEX1,//16进制键码
    output wire keyup//返回是否读取到键的信息，1为读取到
    );
    
    wire kCLKf, kdataf;
    reg [31:0] keycode=0;
    reg [7:0] datacur;
    reg [7:0] dataprev;
    reg [3:0] cnt=0;
    reg flag=0,flag_old=0;
    reg key_up_f;
    integer con;
initial begin
      con=0;
      key_up_f=0;
    end
debouncer Deb(.clk(clk),.I0(usbCLK),.I1(usbDATA),.O0(kCLKf),.O1(kdataf));


always@(negedge kCLKf) begin
  case(cnt)
    0:;
    1:datacur[0]<=kdataf;
    2:datacur[1]<=kdataf;
    3:datacur[2]<=kdataf;
    4:datacur[3]<=kdataf;
    5:datacur[4]<=kdataf;
    6:datacur[5]<=kdataf;
    7:datacur[6]<=kdataf;
    8:datacur[7]<=kdataf;
    9:flag<=1'b1;
    10:flag<=1'b0;
  endcase
  if(cnt<=9) cnt<=cnt+1; else cnt<=0;
end

always @(posedge clk ) begin
  flag_old<=flag; 
  if (RST_n)
   begin 
   keycode<=0;
   con<=0;
   key_up_f=0;
   end
    
    else begin
      if (!flag_old&&flag) 
      begin
         if ((con==0)&&(datacur==8'h71)) 
         con=3;
         if (con==0) begin
           keycode[31:24]<=keycode[23:16];
           keycode[23:16]<=keycode[15:8];
           keycode[15:8]<=dataprev;
           keycode[7:0]<=datacur;
           dataprev<=datacur;
           key_up_f<=1;
         end
         else 
         con=con-1;
      end
    end
end

assign keycodeout=keycode;
//assign keyup=key_up_f;

endmodule
