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
	 input RST_n,            	 //vga��ʾ��Ч�ź�
	output O_HS,                 //��ͬ���ź�                      
    output O_VS,                 //��ͬ���ź� 
    output [3:0] O_RED,
    output [3:0] O_GREEN,
    output [3:0] O_BLUE,
    //input loc_rst,          //ͼƬ�˶�ƫ�Ƶ�ʹ���ź�
    // input rst_time,         //ʱ�临λ
    // input select,           //����ѡ������ʱ�ĸı䣬����һ   //��������������ʾ
    // input time_cnt,         //Ϊ1ʱ��Ӧʱ��+1//��Ϊλѡ�ź�
    // input change,           //changeΪ1ʱ���ֶ���ʱoutput [7:0] bit_sel,
    //output [7:0] bit_sel

	//keyboard part
	//input ARST_L,//�����źţ�switch[15]Ϊ�ߵ�ƽʱ��Ϸ����
    input usbCLK,//usbʱ��
    input usbDATA,//usb����

	// display7 part
    output [6:0] display//��Ӧ����ܽӿ�

	);

	wire keyup;			//�Ƿ���ʾ
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
//        .CLK (CLK)  		, // ϵͳ50MHzʱ��
//        .I_rst_n(RST_n) 	, // ϵͳ��λ
//        .O_red(O_RED)   	, // VGA��ɫ����
//        .O_green(O_GREEN) 	, // VGA��ɫ����
//        .O_blue (O_BLUE) 	, // VGA��ɫ����
//        .O_hs(O_HS)    		, // VGA��ͬ���ź�
//        .O_vs(O_VS)			 // VGA��ͬ���ź�
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
//    input CLK,               //ϵͳʱ��
//    input [31:0] keycode,
//    input  keyup,             //�Ƿ���ܵ���Ч����
//    output reg [3:0]key_out
//    );

	//display7
	display7 dp7(
		.iData(key_out),
		.oData(display)
	);
endmodule
