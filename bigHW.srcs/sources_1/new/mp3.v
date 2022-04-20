`timescale 1ns / 1ps
module mp3(
    input CLK,//ϵͳʱ��
    input DREQ,//��������
    //input RST_n;//��λ,�˴����Լӿ��Բ��ӣ�Ϊ��Ȥζ�Բ���
    output reg XRSET = 1,//Ӳ����λ
    output reg XCS = 1,//�͵�ƽ��ЧƬѡ����
    output reg XDCS = 1,////����Ƭѡ/�ֽ�ͬ��
    output reg SI = 0,//������������
    output reg SCLK = 0//SPIʱ��
);
    parameter  CMD_START = 0;//��ʼдָ��
    parameter  WRITE_CMD = 1;//��һ��ָ��ȫ��д��
    parameter  DATA_START = 2;//��ʼд����
    parameter  WRITE_DATA = 3;//дһ������Ƶ


    reg [16:0]addrr = 0;
    reg [31:0] tmp;
    wire clk_1M; //��Ƶ1MHz
    wire [31:0] data1;
    
    Divider #(.N(100)) CLKDIV1(CLK,clk_1M);

    blk_mem_gen_1 flower_dance(.clka(CLK), .addra(addrr[16:0]), .douta(data1[31:0]),.wea(0));
    reg [127:0]cmd_mode = {32'h02000804, 32'h02020055, 32'h02039800, 32'h020B2020, 32'hffffffff};
    integer cmd_cnt = 0;
    integer cnt = 0;
    integer status = CMD_START;
    always @(posedge clk_1M) 
    begin
//        if(!RST_n)
//        begin
//            MP3_RST <= 0;
//			RSET <= 0;
//			SCLK <= 0;
//			XCS <= 1;
//			XDCS <= 1;
//            status<=0;
//        end        
       // else
        begin
        case(status)
        CMD_START:
        begin
            SCLK <= 0;
            if(cmd_cnt >= 5)
                status <= DATA_START;
            else if(DREQ) 
            begin
                XCS <= 0;
                status <= WRITE_CMD;  
                SI <= cmd_mode[127];
                cmd_mode <= {cmd_mode[126:0], cmd_mode[127]};
                cnt <= 1;
            end
        end
        WRITE_CMD:
        begin
            if(DREQ)
            begin
                if(SCLK) 
                begin
                    if(cnt >= 32)
                    begin
                        XCS <= 1;
                        cnt <= 0;
                        cmd_cnt <= cmd_cnt + 1;
                        status <= CMD_START;
                    end
                    else 
                    begin
                        SI <= cmd_mode[127];
                        cmd_mode <= {cmd_mode[126:0], cmd_mode[127]};
                        cnt <= cnt + 1; 
                    end
                end
                SCLK <= ~SCLK;
            end
        end
        DATA_START:
        begin
            if(DREQ)
            begin
                XDCS <= 0;
                SCLK <= 0;
                cnt <= 1;
                SI <= data1[31];    
                tmp <= {data1[30:0], data1[31]};
                status <= WRITE_DATA;  
            end
        end
        WRITE_DATA:
        begin
            if(SCLK)
            begin
                if(cnt >= 32)
                begin
                    XDCS <= 1;
                    addrr <= addrr + 1;
                    status <= DATA_START;
                end
                else 
                begin
                    cnt <= cnt + 1;
                    tmp <= {tmp[30:0],tmp[31]};
                    SI <= tmp[31];
                end
            end
            SCLK <= ~SCLK;
        end
        default:;
        endcase
        end;
    end
endmodule

