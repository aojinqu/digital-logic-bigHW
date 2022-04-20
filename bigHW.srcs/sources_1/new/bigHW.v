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
	 input RST_n,            	 //vga��ʾ��Ч�ź�
	output O_HS,                 //��ͬ���ź�                      
    output O_VS,                 //��ͬ���ź� 
    output [3:0] O_RED,
    output [3:0] O_GREEN,
    output [3:0] O_BLUE,
	//blutooth part
    input get_bluetooth,//��pmod

	// display7 part
    output [6:0] display//��Ӧ����ܽӿ�
	);

    //wire [31:0]out_bluetooth;//�������ݴ���
    wire[7:0]out_bluetooth;//�������ݴ���
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
      .CLK (CLK)  		, // ϵͳ50MHzʱ��
      .I_rst_n(RST_n) 	, // ϵͳ��λ
      .O_red(O_RED)   	, // VGA��ɫ����
      .O_green(O_GREEN) 	, // VGA��ɫ����
      .O_blue (O_BLUE) 	, // VGA��ɫ����
      .O_hs(O_HS)    		, // VGA��ͬ���ź�
      .O_vs(O_VS),			 // VGA��ͬ���ź�
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
