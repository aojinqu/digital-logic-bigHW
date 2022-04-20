`timescale 1ns / 1ps

module bigHW(
    input CLK, 
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
	//blutooth part
    input get_bluetooth,//接pmod

	// display7 part
    output [6:0] display//对应数码管接口
	);

    //wire [31:0]out_bluetooth;//蓝牙数据传输
    wire[7:0]out_bluetooth;//蓝牙数据传输
    wire [11:0]score;
    wire [3:0]level;
    
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
	
//vga part
   vga_control VGA
  (
      .CLK (CLK)  		, // 系统50MHz时钟
      .I_rst_n(RST_n) 	, // 系统复位
      .O_red(O_RED)   	, // VGA红色分量
      .O_green(O_GREEN) 	, // VGA绿色分量
      .O_blue (O_BLUE) 	, // VGA蓝色分量
      .O_hs(O_HS)    		, // VGA行同步信号
      .O_vs(O_VS),			 // VGA场同步信号
      .out_bluetooth(out_bluetooth[3:0]),
	   .score(level)
  );

	//blutooth part	
    bluetooth bt(
	.CLK(CLK),
	.RST_n(RST_n),
	.get(get_bluetooth),
	.out(out_bluetooth)

	);

	display7 dp7(
	  	.CLK(CLK),
        .RST_n(RST_n),
	  	.in(out_bluetooth[3:0]),
	  	.oData(display),
        .score(score),
        .level(level)	
	  );


endmodule
