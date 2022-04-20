`timescale 1ns / 1ps

//尝试显示彩条
module vga_control
(
    input                   CLK   , // 系统100MHz时钟
    input                   I_rst_n , // 系统复位
    input [3:0]             out_bluetooth,//蓝牙收到的信号
    output   reg   [3:0]    O_red   , // VGA红色分量
    output   reg   [3:0]    O_green , // VGA绿色分量
    output   reg   [3:0]    O_blue  , // VGA蓝色分量
    output                  O_hs    , // VGA行同步信号
    output                  O_vs,      // VGA场同步信号
    output   reg   [3:0]   score
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

reg     [11:0]      R_h_pos         ; // 图片在屏幕上显示的水平位置，当它为0时，图片贴紧屏幕的左边沿
reg     [11:0]      R_v_pos         ; // 图片在屏幕上显示的垂直位置，当它为0时，图片贴紧屏幕的上边沿
reg     [11:0]      R_h_pos_2         ; // 图片在屏幕上显示的水平位置，当它为0时，图片贴紧屏幕的左边沿
reg     [11:0]      R_v_pos_2         ; // 图片在屏幕上显示的垂直位置，当它为0时，图片贴紧屏幕的上边沿
reg     [11:0]      R_h_pos_3         ; // 图片在屏幕上显示的水平位置，当它为0时，图片贴紧屏幕的左边沿
reg     [11:0]      R_v_pos_3         ; // 图片在屏幕上显示的垂直位置，当它为0时，图片贴紧屏幕的上边沿



reg                 R_vs_reg1       ;
reg                 R_vs_reg2       ;
wire                W_vs_neg        ; // 场脉冲下降沿标志
reg     [1:0]       R_state         ;


//彩条起始坐标
parameter   BAR_WIDTH=95,
            BAR_HEIGHT=60;

parameter x0=70,y0=50,xmax=430,ymax=430,ybegin=350,x1=320,y1=50,x2=195,y2=50;//370;      //先做第一条音轨,x1=,y1=
reg R_press,G_press,B_press;

//reg [11:0]score;
reg [3:0]level;

wire R_clk_1M;
Divider #(.N(4)) CLKDIV1(CLK,R_clk_25M);
Divider #(.N(1000000)) CLKDIV2(CLK,R_clk_1M);

   blk_mem_gen_2 background(.clka(R_clk_25M), .addra(R_rom_addr[23:0]), .douta(W_rom_data[11:0]),.wea(0));
//////////////////////////////////////////////////////////////////
// 功能：产生行时序
//////////////////////////////////////////////////////////////////
always @(posedge R_clk_25M or negedge I_rst_n)
begin
    if(!I_rst_n)
    begin
        R_h_cnt <=  12'd0   ;
    end
    else if(R_h_cnt == C_H_LINE_PERIOD - 1'b1)
    begin
        R_h_cnt <=  12'd0   ;
    end 
    else
    begin
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
reg [12:0]tmp;
reg RST_move;

always @(posedge R_clk_1M) begin      //每隔2s来一个数字信号
    if(! I_rst_n&&RST_move==0)        //不许动！过一个时钟才能动
    begin
        tmp<=tmp+1;
        if(tmp==3)
        begin
        tmp<=0;
        RST_move<=1;
        end
    end
end

//////////////////////////////////////////////////////////////////
// 功能：产生场脉冲的下降沿标志，在这个标志用来修改R_h_pos和R_v_pos
//       两个参数，从而改变图片的位置
//////////////////////////////////////////////////////////////////
always @(posedge R_clk_25M or negedge I_rst_n)
begin
    if(!I_rst_n)
        begin
            R_vs_reg1   <=  1'b0        ;
            R_vs_reg2   <=  1'b0        ;
        end
    else
        begin
            R_vs_reg1   <=  O_vs        ;
            R_vs_reg2   <=  R_vs_reg1   ;
        end         
end

assign W_vs_neg = ~R_vs_reg1 & R_vs_reg2 ;
//////////////////////////////////////////////////////////////////
// 功能：把ROM里面的图片数据输出
//////////////////////////////////////////////////////////////////
//reg cnt_move;
always @(posedge R_clk_25M or negedge I_rst_n)
begin
    if(!I_rst_n) 
    begin
            R_rom_addr  <=  24'd0 ;
             RST_move<=1;
             tmp<=0;
             score<=0;
             level<=0;
             R_press<=0;
             G_press<=0;
             B_press<=0;
    end

    else if(W_active_flag)     
        begin
            if(R_h_cnt >= (C_H_SYNC_PULSE + C_H_BACK_PORCH                        )  && 
               R_h_cnt <= (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_IMAGE_WIDTH  - 1'b1)  &&
               R_v_cnt >= (C_V_SYNC_PULSE + C_V_BACK_PORCH                        )  && 
               R_v_cnt <= (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_IMAGE_HEIGHT - 1'b1)  )
                begin
                    if
                    (R_h_cnt >= (C_H_SYNC_PULSE + C_H_BACK_PORCH + R_h_pos)  && 
                    R_h_cnt <= (C_H_SYNC_PULSE + C_H_BACK_PORCH + R_h_pos+ BAR_WIDTH)  &&
                    R_v_cnt >= (C_V_SYNC_PULSE + C_V_BACK_PORCH + R_v_pos)  && 
                    R_v_cnt <= (C_V_SYNC_PULSE + C_V_BACK_PORCH + R_v_pos +BAR_HEIGHT) &&
                    RST_move==1)
                    begin                                    
                        O_red       <=  4'b1111        ;
                        O_green     <=  4'd0        ;
                        O_blue      <=  4'd0        ;
                            // y0_cnt<=y0_cnt+4'b1000;
                    end
                    else if
                    (R_h_cnt >= (C_H_SYNC_PULSE + C_H_BACK_PORCH + R_h_pos_2)  && 
                    R_h_cnt <= (C_H_SYNC_PULSE + C_H_BACK_PORCH + R_h_pos_2+ BAR_WIDTH)  &&
                    R_v_cnt >= (C_V_SYNC_PULSE + C_V_BACK_PORCH + R_v_pos_2)  && 
                    R_v_cnt <= (C_V_SYNC_PULSE + C_V_BACK_PORCH + R_v_pos_2 +BAR_HEIGHT) &&
                    RST_move==1)
                    begin                                    
                        O_red       <=  4'b0        ;
                        O_green     <=  4'd0        ;
                        O_blue      <=  4'b1111        ;
                    end                    
                     else if
                    (R_h_cnt >= (C_H_SYNC_PULSE + C_H_BACK_PORCH + R_h_pos_3)  && 
                    R_h_cnt <= (C_H_SYNC_PULSE + C_H_BACK_PORCH + R_h_pos_3+ BAR_WIDTH)  &&
                    R_v_cnt >= (C_V_SYNC_PULSE + C_V_BACK_PORCH + R_v_pos_3)  && 
                    R_v_cnt <= (C_V_SYNC_PULSE + C_V_BACK_PORCH + R_v_pos_3 +BAR_HEIGHT) &&
                    RST_move==1)
                    begin                                    
                        O_red       <=  4'b0        ;
                        O_green     <=  4'b1111        ;
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

//////////////////////////////////////////////////////////////////
// 功能：使图片移动的状态机
//////////////////////////////////////////////////////////////////
reg [1:0]c;
always@(posedge R_clk_25M or negedge I_rst_n)
begin
    if(!I_rst_n)
        begin
            R_h_pos <=  x0   ;
            R_v_pos <=  y0   ; 
            R_h_pos_2 <=  x1   ;
            R_v_pos_2 <=  y1  ; 
            R_h_pos_3 <=  x2   ;
            R_v_pos_3 <=  y2  ; 
            R_state <=  2'b00   ;
            c<=0;
        end
    else if(W_vs_neg)    
        begin 
            case(R_state)
                2'b00: // 图片往下方移动
                    begin 
                        if(c==2'b10)
                        begin
                        R_v_pos_2     <=  R_v_pos_2 + 2 ;
                        c<=0;                      
                        end
                        else if(c==2'b01)
                        begin
                        R_v_pos_3     <=  R_v_pos_3 + 4 ;
                        c<=c+1;
                        end
                        else
                        c<=c+1;



                        R_v_pos     <=  R_v_pos + 3 ;
                        if(R_v_pos +BAR_HEIGHT>=ymax)// C_IMAGE_HEIGHT) >= ymax)//C_V_ACTIVE_TIME) // 如果碰到下边框
                        begin
                            R_state <=  2'b01        ;  
                            R_h_pos <=  R_h_pos+125  ;
                            if(R_h_pos>=xmax)
                                R_h_pos <=x0; 
                            R_v_pos <=  y0   ;
                            R_press<=0;
                            RST_move<=0;     //落到底部了不许再动！
                            tmp<=0;
                        end 
                        else if((R_v_pos +BAR_HEIGHT>=ybegin)&&out_bluetooth==1)
                            //R_press<=1;
                           score<=score+1;
                          // out_bluetooth<=out_bluetooth+1

                        if(R_v_pos_2 +BAR_HEIGHT>=ymax)// C_IMAGE_HEIGHT) >= ymax)//C_V_ACTIVE_TIME) // 如果碰到下边框
                        begin
                            R_h_pos_2 <=  R_h_pos_2+125  ;
                            if(R_h_pos_2>=xmax)
                                R_h_pos_2 <=x0; 
                            R_v_pos_2 <=  y1   ;
                            B_press<=0;
                        end
                         else if(R_v_pos_2 +BAR_HEIGHT>=ybegin&&out_bluetooth[3:0]==4'b0010)
                            //R_press<=1;
                            score<=score+1;

                        if(R_v_pos_3 +BAR_HEIGHT>=ymax)// C_IMAGE_HEIGHT) >= ymax)//C_V_ACTIVE_TIME) // 如果碰到下边框
                        begin
                            R_h_pos_3 <=  R_h_pos_3+125  ;
                            if(R_h_pos_3>=xmax)
                                R_h_pos_3 <=x0; 
                            R_v_pos_3 <=  y1   ;
                            G_press<=0;
                        end                        
                        else if(R_v_pos_3 +BAR_HEIGHT>=ybegin&&out_bluetooth[3:0]==4'b0011)
                            //R_press<=1;
                            score<=score+1;
                    end
                default:R_state <=  2'b00;            
            endcase       
        end
end      

always @(posedge CLK) begin

     if(R_press&&out_bluetooth[3:0]==4'b0001)
    score<=score+1;
    else   if(G_press&&out_bluetooth[3:0]==4'b0010)
    score<=score+1;
    else  if(B_press&&out_bluetooth[3:0]==4'b0011)
    score<=score+1;
end

always @(posedge CLK) begin
    if(score/10==2)
    level<=2;
    else if(score/10==3)
    level<=3;
    else if(score/10==4)
    level<=4;
    else if(score/10==5)
    level<=5;
    else if(score/10==6)
    level<=6;
    else if(score/10==7)
    level<=7;
    else if(score/10==8)
    level<=8;
    else if(score/10==9)
    level<=9;
end


endmodule