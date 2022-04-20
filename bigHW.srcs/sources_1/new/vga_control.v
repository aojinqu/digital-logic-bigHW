`timescale 1ns / 1ps

//������ʾ����
module vga_control
(
    input                   CLK   , // ϵͳ100MHzʱ��
    input                   I_rst_n , // ϵͳ��λ
    input [3:0]             out_bluetooth,//�����յ����ź�
    output   reg   [3:0]    O_red   , // VGA��ɫ����
    output   reg   [3:0]    O_green , // VGA��ɫ����
    output   reg   [3:0]    O_blue  , // VGA��ɫ����
    output                  O_hs    , // VGA��ͬ���ź�
    output                  O_vs,      // VGA��ͬ���ź�
    output   reg   [3:0]   score
);


// �ֱ���Ϊ640*480ʱ��ʱ�������������
parameter       C_H_SYNC_PULSE      =   96  , 
                C_H_BACK_PORCH      =   48  ,
                C_H_ACTIVE_TIME     =   640 ,
                C_H_FRONT_PORCH     =   16  ,
                C_H_LINE_PERIOD     =   800 ;

// �ֱ���Ϊ640*480ʱ��ʱ�������������               
parameter       C_V_SYNC_PULSE      =   2   , 
                C_V_BACK_PORCH      =   33  ,
                C_V_ACTIVE_TIME     =   480 ,
                C_V_FRONT_PORCH     =   10  ,
                C_V_FRAME_PERIOD    =   525 ;
                
parameter       C_IMAGE_WIDTH       =   640     ,
                C_IMAGE_HEIGHT      =   480     ,
                C_IMAGE_PIX_NUM     =   307200   ;

reg [11:0]      R_h_cnt         ; // ��ʱ�������
reg [11:0]      R_v_cnt         ; // ��ʱ�������
reg     [23:0]      R_rom_addr      ; // ROM�ĵ�ַ��ԭ��16λ
wire    [11:0]      W_rom_data      ; // ROM�д洢������
wire            R_clk_25M       ;
wire            W_active_flag   ; // �����־��������ź�Ϊ1ʱRGB�����ݿ�����ʾ����Ļ��

reg     [11:0]      R_h_pos         ; // ͼƬ����Ļ����ʾ��ˮƽλ�ã�����Ϊ0ʱ��ͼƬ������Ļ�������
reg     [11:0]      R_v_pos         ; // ͼƬ����Ļ����ʾ�Ĵ�ֱλ�ã�����Ϊ0ʱ��ͼƬ������Ļ���ϱ���
reg     [11:0]      R_h_pos_2         ; // ͼƬ����Ļ����ʾ��ˮƽλ�ã�����Ϊ0ʱ��ͼƬ������Ļ�������
reg     [11:0]      R_v_pos_2         ; // ͼƬ����Ļ����ʾ�Ĵ�ֱλ�ã�����Ϊ0ʱ��ͼƬ������Ļ���ϱ���
reg     [11:0]      R_h_pos_3         ; // ͼƬ����Ļ����ʾ��ˮƽλ�ã�����Ϊ0ʱ��ͼƬ������Ļ�������
reg     [11:0]      R_v_pos_3         ; // ͼƬ����Ļ����ʾ�Ĵ�ֱλ�ã�����Ϊ0ʱ��ͼƬ������Ļ���ϱ���



reg                 R_vs_reg1       ;
reg                 R_vs_reg2       ;
wire                W_vs_neg        ; // �������½��ر�־
reg     [1:0]       R_state         ;


//������ʼ����
parameter   BAR_WIDTH=95,
            BAR_HEIGHT=60;

parameter x0=70,y0=50,xmax=430,ymax=430,ybegin=350,x1=320,y1=50,x2=195,y2=50;//370;      //������һ������,x1=,y1=
reg R_press,G_press,B_press;

//reg [11:0]score;
reg [3:0]level;

wire R_clk_1M;
Divider #(.N(4)) CLKDIV1(CLK,R_clk_25M);
Divider #(.N(1000000)) CLKDIV2(CLK,R_clk_1M);

   blk_mem_gen_2 background(.clka(R_clk_25M), .addra(R_rom_addr[23:0]), .douta(W_rom_data[11:0]),.wea(0));
//////////////////////////////////////////////////////////////////
// ���ܣ�������ʱ��
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
// ���ܣ�������ʱ��
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
// ������Ч�����־��������ź�Ϊ��ʱ��RGB�͵����ݲŻ���ʾ����Ļ��
assign W_active_flag =  (R_h_cnt >= (C_H_SYNC_PULSE + C_H_BACK_PORCH                  ))  &&
                        (R_h_cnt <= (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_H_ACTIVE_TIME))  && 
                        (R_v_cnt >= (C_V_SYNC_PULSE + C_V_BACK_PORCH                  ))  &&
                        (R_v_cnt <= (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_V_ACTIVE_TIME))  ;                     

//////////////////////////////////////////////////////////////////
// ���ܣ������ƶ�
//////////////////////////////////////////////////////////////////
reg [12:0]tmp;
reg RST_move;

always @(posedge R_clk_1M) begin      //ÿ��2s��һ�������ź�
    if(! I_rst_n&&RST_move==0)        //��������һ��ʱ�Ӳ��ܶ�
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
// ���ܣ�������������½��ر�־���������־�����޸�R_h_pos��R_v_pos
//       �����������Ӷ��ı�ͼƬ��λ��
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
// ���ܣ���ROM�����ͼƬ�������
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
                   //��Ϊ��������ɫ
                        O_red       <= W_rom_data[11:8]    ; // ��ɫ����
                        O_green     <= W_rom_data[7:4]     ; // ��ɫ����
                        O_blue      <= W_rom_data[3:0]      ; // ��ɫ����
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
// ���ܣ�ʹͼƬ�ƶ���״̬��
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
                2'b00: // ͼƬ���·��ƶ�
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
                        if(R_v_pos +BAR_HEIGHT>=ymax)// C_IMAGE_HEIGHT) >= ymax)//C_V_ACTIVE_TIME) // ��������±߿�
                        begin
                            R_state <=  2'b01        ;  
                            R_h_pos <=  R_h_pos+125  ;
                            if(R_h_pos>=xmax)
                                R_h_pos <=x0; 
                            R_v_pos <=  y0   ;
                            R_press<=0;
                            RST_move<=0;     //�䵽�ײ��˲����ٶ���
                            tmp<=0;
                        end 
                        else if((R_v_pos +BAR_HEIGHT>=ybegin)&&out_bluetooth==1)
                            //R_press<=1;
                           score<=score+1;
                          // out_bluetooth<=out_bluetooth+1

                        if(R_v_pos_2 +BAR_HEIGHT>=ymax)// C_IMAGE_HEIGHT) >= ymax)//C_V_ACTIVE_TIME) // ��������±߿�
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

                        if(R_v_pos_3 +BAR_HEIGHT>=ymax)// C_IMAGE_HEIGHT) >= ymax)//C_V_ACTIVE_TIME) // ��������±߿�
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