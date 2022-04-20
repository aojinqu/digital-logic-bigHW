`timescale 1ns / 1ps

//尝试显示彩条
module vga_control
(
    input                   CLK   , // 系统100MHz时钟
    input                   I_rst_n , // 系统复位
    output   reg   [3:0]    O_red   , // VGA红色分量
    output   reg   [3:0]    O_green , // VGA绿色分量
    output   reg   [3:0]    O_blue  , // VGA蓝色分量
    output                  O_hs    , // VGA行同步信号
    output                  O_vs      // VGA场同步信号
);


// 分辨率为640*480时行时序各个参数定义
parameter       C_H_SYNC_PULSE      =   96  , 
                C_H_BACK_PORCH      =   48  ,
                C_H_ACTIVE_TIME     =   640 ,
                C_H_FRONT_PORCH     =   16  ,
                C_H_LINE_PERIOD     =   800 ;

// 分辨率为640*480时场时序各个参数定义               
parameter       C_V_SYNC_PULSE      =   2   , 
                C_V_BACK_PORCH      =   33  ,
                C_V_ACTIVE_TIME     =   480 ,
                C_V_FRONT_PORCH     =   10  ,
                C_V_FRAME_PERIOD    =   525 ;
                
parameter       C_IMAGE_WIDTH       =   640     ,
                C_IMAGE_HEIGHT      =   480     ,
                C_IMAGE_PIX_NUM     =   307200   ;

reg [11:0]      R_h_cnt         ; // 行时序计数器
reg [11:0]      R_v_cnt         ; // 列时序计数器
reg     [23:0]      R_rom_addr      ; // ROM的地址，原来16位
wire    [11:0]      W_rom_data      ; // ROM中存储的数据
wire            R_clk_25M       ;
wire            W_active_flag   ; // 激活标志，当这个信号为1时RGB的数据可以显示在屏幕上

//彩条起始坐标
parameter BAR_WIDTH=95,BAR_HEIGHT=60;
parameter x0=215,y0=85,ymax=405;      //先做第一条音轨,x1=,y1=
reg [9:0]y0_cnt;
//reg [9:0]y0_cnt;

wire R_clk_1M;
Divider #(.N(4)) CLKDIV1(CLK,R_clk_25M);
Divider #(.N(100)) CLKDIV2(CLK,R_clk_1M);

   blk_mem_gen_2 background(.clka(R_clk_25M), .addra(R_rom_addr[23:0]), .douta(W_rom_data[11:0]),.wea(0));
//////////////////////////////////////////////////////////////////
// 功能：产生行时序
//////////////////////////////////////////////////////////////////
reg cut_lines;
always @(posedge R_clk_25M or negedge I_rst_n)
begin
    if(!I_rst_n)
    begin
        R_h_cnt <=  12'd0   ;
        cut_lines=0;
    end
    else if(R_h_cnt == C_H_LINE_PERIOD - 1'b1)
    begin
        R_h_cnt <=  12'd0   ;
        cut_lines=0;
    end
    else
    begin
        if(cut_lines==5)       //把25个时钟周期分成5个
        begin
            y0_cnt=y0_cnt+1'b10;       //坐标+2
            cut_lines=0;
        end

        cut_lines=cut_lines+1;
        R_h_cnt <=  R_h_cnt + 1'b1  ;
    end                
end                

assign O_hs =   (R_h_cnt < C_H_SYNC_PULSE) ? 1'b0 : 1'b1    ; 
//////////////////////////////////////////////////////////////////
// 功能：产生场时序
//////////////////////////////////////////////////////////////////
always @(posedge R_clk_25M or negedge I_rst_n)
begin
    if(!I_rst_n)
        R_v_cnt <=  12'd0   ;
    else if(R_v_cnt == C_V_FRAME_PERIOD - 1'b1)
        R_v_cnt <=  12'd0   ;
    else if(R_h_cnt == C_H_LINE_PERIOD - 1'b1)
        R_v_cnt <=  R_v_cnt + 1'b1  ;
    else
        R_v_cnt <=  R_v_cnt ;                        
end                

assign O_vs =   (R_v_cnt < C_V_SYNC_PULSE) ? 1'b0 : 1'b1    ; 
//////////////////////////////////////////////////////////////////  
// 产生有效区域标志，当这个信号为高时往RGB送的数据才会显示到屏幕上
assign W_active_flag =  (R_h_cnt >= (C_H_SYNC_PULSE + C_H_BACK_PORCH                  ))  &&
                        (R_h_cnt <= (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_H_ACTIVE_TIME))  && 
                        (R_v_cnt >= (C_V_SYNC_PULSE + C_V_BACK_PORCH                  ))  &&
                        (R_v_cnt <= (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_V_ACTIVE_TIME))  ;                     

//////////////////////////////////////////////////////////////////
// 功能：行数移动
//////////////////////////////////////////////////////////////////
// wire line_clk;  //20hz
// Divider #(.N(5)) CLKDIV2(CLK,line_clk);
// always @(posedge line_clk ) begin
//     if(clk==1)


// end

//////////////////////////////////////////////////////////////////
// 功能：把ROM里面的图片数据输出
//////////////////////////////////////////////////////////////////
always @(posedge R_clk_25M or negedge I_rst_n)
begin
    if(!I_rst_n) 
    begin
                R_rom_addr  <=  24'd0 ;
                y0_cnt=y0;      //初始化
    end

    else if(W_active_flag)     
        begin
            if(R_h_cnt >= (C_H_SYNC_PULSE + C_H_BACK_PORCH                        )  && 
               R_h_cnt <= (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_IMAGE_WIDTH  - 1'b1)  &&
               R_v_cnt >= (C_V_SYNC_PULSE + C_V_BACK_PORCH                        )  && 
               R_v_cnt <= (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_IMAGE_HEIGHT - 1'b1)  )
                begin
                    //彩条
                    if(R_h_cnt>=x0&&R_h_cnt<=x0+BAR_WIDTH&&
                       R_v_cnt>=y0_cnt&&R_v_cnt<=y0_cnt+BAR_HEIGHT)
                    begin
                        O_red       <=  4'b1111        ;
                        O_green     <=  4'd0        ;
                        O_blue      <=  4'd0        ;
                    end
                    else
                    begin
                   //若为正常背景色
                        O_red       <= W_rom_data[11:8]    ; // 红色分量
                        O_green     <= W_rom_data[7:4]     ; // 绿色分量
                        O_blue      <= W_rom_data[3:0]      ; // 蓝色分量
                    end  

                    if(R_rom_addr == C_IMAGE_PIX_NUM - 1'b1)
                        R_rom_addr  <=  24'd0 ;
                    else
                        R_rom_addr  <=  R_rom_addr  +  1'b1 ;          
                                    
                end
            else
                begin
                    O_red       <=  4'b1111        ;
                    O_green     <=  4'b1111        ;
                    O_blue      <=  4'b1111        ;
                    R_rom_addr  <=  R_rom_addr  ;
                end                          
        end
    else
        begin
            O_red       <=  4'd0        ;
            O_green     <=  4'd0        ;
            O_blue      <=  4'd0        ;
            R_rom_addr  <=  R_rom_addr  ;
        end          
end


endmodule