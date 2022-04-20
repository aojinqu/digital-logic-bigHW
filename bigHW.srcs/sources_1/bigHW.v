`timescale 1ns / 1ps


module bigHW(
    input CLK, 
	//	input RST, // active low 

	// mp3 part 
	input DREQ,      		// sign for input
	output XDCS, 			// data control
	output XCS,  			// cmd control 
	output RSET, 
	output SI,  			// data input
	output SCLK,  			// clk for VS1003B 

    // vga part
	 input RST_n,            	 //vga显示有效信号
	output O_HS,                 //行同步信号                      
    output O_VS,                 //场同步信号 
    output [3:0] O_RED,
    output [3:0] O_GREEN,
    output [3:0] O_BLUE,
    //input loc_rst,          //图片运动偏移的使能信号
    // input rst_time,         //时间复位
    // input select,           //控制选择对秒分时的改变，三合一   //输出到数码管上显示
    // input time_cnt,         //为1时对应时间+1//作为位选信号
    // input change,           //change为1时表手动计时output [7:0] bit_sel,
    //output [7:0] bit_sel

	//keyboard part
	//input ARST_L,//控制信号，switch[15]为高电平时游戏运行
    input usbCLK,//usb时钟
    input usbDATA,//usb数据

	// display7 part
    output [6:0] display//对应数码管接口

	);

	wire keyup;			//是否显示
	wire [3:0]key_out;
	wire [31:0] keycode;

  //   mp3 board
	 mp3 Mp3(
	 	.CLK(CLK), 
	 	.DREQ(DREQ),
	 	.XDCS(XDCS), 
	 	.XCS(XCS),  
	 	.SI(SI),
	 	.XRSET(RSET),
	 	.SCLK(SCLK)
	 );
	
// vga part
//    vga_control VGA
//    (
//        .CLK (CLK)  		, // 系统50MHz时钟
//        .I_rst_n(RST_n) 	, // 系统复位
//        .O_red(O_RED)   	, // VGA红色分量
//        .O_green(O_GREEN) 	, // VGA绿色分量
//        .O_blue (O_BLUE) 	, // VGA蓝色分量
//        .O_hs(O_HS)    		, // VGA行同步信号
//        .O_vs(O_VS)			 // VGA场同步信号
//    );
    
		
	//keyboard
	keyboard Keyboard(
	.clk(usbCLK),
	.usbCLK(usbCLK),
	.usbDATA(usbDATA), 
	.RST_n(RST_n), 
	.keycodeout(keycode),
	.keyup(keyup)
	);

    
	deal_key Deal(
		.CLK(CLK),
		.keycode(keycode),
		.keyup(keyup),
		.key_out(key_out)
	);

//module deal_key(
//    input CLK,               //系统时钟
//    input [31:0] keycode,
//    input  keyup,             //是否接受到有效键码
//    output reg [3:0]key_out
//    );

	//display7
	display7 dp7(
		.iData(key_out),
		.oData(display)
	);
endmodule
