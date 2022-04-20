`timescale 1ns / 1ps


module bigHW(
    input CLK, // out clk
	input RST, // active low 
	
	// mp3 part 
	input DREQ,      // sign for input
	output XDCS, // data control
	output XCS,  // cmd control 
	output RSET, 
	output SI,   // data input
	output SCLK  // clk for VS1003B 
    );

    // mp3 volume
    wire [15:0] vol;
    // current song
	wire [2: 0] current;
    // display rst
	wire display_rst;

    
    // mp3 board
	mp3 Mp3(
		.CLK(CLK), 
		.RST(RST), 
		.DREQ(DREQ),
		.vol(vol),
		.current(current),
		.XDCS(XDCS), 
		.XCS(XCS), 
		.RSET(RSET), 
		.SI(SI),
		.SCLK(SCLK),
		.MP3_RST(display_rst)
	);
	
	
	
endmodule
