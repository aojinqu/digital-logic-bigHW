`timescale 1ns / 1ps

//������ʾ����
module vga_control
(
    input                   CLK   , // ϵͳ100MHzʱ��
    input                   I_rst_n , // ϵͳ��λ
    output   reg   [3:0]    O_red   , // VGA��ɫ����
    output   reg   [3:0]    O_green , // VGA��ɫ����
    output   reg   [3:0]    O_blue  , // VGA��ɫ����
    output                  O_hs    , // VGA��ͬ���ź�
    output                  O_vs      // VGA��ͬ���ź�
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

//������ʼ����
parameter BAR_WIDTH=95,BAR_HEIGHT=60;
parameter x0=215,y0=85,ymax=405;      //������һ������,x1=,y1=
reg [9:0]y0_cnt;
//reg [9:0]y0_cnt;

wire R_clk_1M;
Divider #(.N(4)) CLKDIV1(CLK,R_clk_25M);
Divider #(.N(100)) CLKDIV2(CLK,R_clk_1M);

   blk_mem_gen_2 background(.clka(R_clk_25M), .addra(R_rom_addr[23:0]), .douta(W_rom_data[11:0]),.wea(0));
//////////////////////////////////////////////////////////////////
// ���ܣ�������ʱ��
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
        if(cut_lines==5)       //��25��ʱ�����ڷֳ�5��
        begin
            y0_cnt=y0_cnt+1'b10;       //����+2
            cut_lines=0;
        end

        cut_lines=cut_lines+1;
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
// wire line_clk;  //20hz
// Divider #(.N(5)) CLKDIV2(CLK,line_clk);
// always @(posedge line_clk ) begin
//     if(clk==1)


// end

//////////////////////////////////////////////////////////////////
// ���ܣ���ROM�����ͼƬ�������
//////////////////////////////////////////////////////////////////
always @(posedge R_clk_25M or negedge I_rst_n)
begin
    if(!I_rst_n) 
    begin
                R_rom_addr  <=  24'd0 ;
                y0_cnt=y0;      //��ʼ��
    end

    else if(W_active_flag)     
        begin
            if(R_h_cnt >= (C_H_SYNC_PULSE + C_H_BACK_PORCH                        )  && 
               R_h_cnt <= (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_IMAGE_WIDTH  - 1'b1)  &&
               R_v_cnt >= (C_V_SYNC_PULSE + C_V_BACK_PORCH                        )  && 
               R_v_cnt <= (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_IMAGE_HEIGHT - 1'b1)  )
                begin
                    //����
                    if(R_h_cnt>=x0&&R_h_cnt<=x0+BAR_WIDTH&&
                       R_v_cnt>=y0_cnt&&R_v_cnt<=y0_cnt+BAR_HEIGHT)
                    begin
                        O_red       <=  4'b1111        ;
                        O_green     <=  4'd0        ;
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


endmodule