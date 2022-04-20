`timescale 1ns / 1ps

module vga_posrgb(
    input                   CLK   ,         // 系统100MHz时钟
    input                   RST_n ,       // 系统复位
    input            [11:0] XCOORD ,        //当前像素的横坐标
    input            [11:0] YCOORD ,        //当前像素的纵坐标  
    output reg       [11:0] CSEL           //rgb值，可任意改
    );


    wire clk;       //25mhz
    reg     [18:0]      R_rom_addr      ; // ROM的地址，原来16位
    wire    [11:0]      W_rom_data      ; // ROM中存储的数据

parameter       C_IMAGE_WIDTH       =   640     ,
                C_IMAGE_HEIGHT      =   480     ,
                C_IMAGE_PIX_NUM     =   307200   ;

//彩条起始坐标
parameter BAR_WIDTH=95,BAR_HEIGHT=60;
parameter x0=215,y0=85,ymax=405;      //先做第一条音轨,x1=,y1=
reg [9:0]y0_cnt;

    Divider #(.N(4)) CLKDIV4(CLK,clk);
    blk_mem_gen_2 background(.clka(clk), .addra(R_rom_addr), .douta(W_rom_data),.wea(0));

reg cnt;

always @(posedge clk ) begin
    if(!RST_n)
    begin
        if(cnt==1000)
        begin
            y0_cnt<=y0_cnt+10;
            cnt<=0;
        end
        cnt<=cnt+1;
    end
end

//判断该坐标是应该读取背景图片还是方框
always @(posedge clk or negedge RST_n) begin
    if(!RST_n)
    begin
        R_rom_addr  <=  19'd0 ; 
        y0_cnt<=y0;
        cnt<=0;
    end
    else
    begin
    if  (XCOORD>=x0  &&XCOORD<=x0+BAR_WIDTH  &&
        YCOORD>=y0_cnt&& YCOORD<=y0_cnt+BAR_HEIGHT)
    begin
        CSEL<=12'hf00;
    end
    else
        CSEL<=12'h000;
    // else        //背景
    // begin
    //     CSEL<=W_rom_data;
    //      R_rom_addr  <=  R_rom_addr;
    // end
    
    if(R_rom_addr == C_IMAGE_PIX_NUM - 1'b1)       
        R_rom_addr  <=  19'd0 ;    
    else        
        R_rom_addr  <=  R_rom_addr  +  1'b1 ;  
    end     
end


endmodule
