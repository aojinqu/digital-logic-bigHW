module bluetooth(
    input CLK,
    input RST_n,
    input get,
    output reg [7:0] out
    );

    
    wire buffer_en;//��⵽����
    parameter bps=10417;////��Ӧ9600�����ʣ����Ҫ�����������Ϊ8
    // ���߸�С,���ܿ��������
    reg [14:0] cn1;//ÿһλ�еļ�����
    reg [3:0] cn2;//ÿһ�����ݵļ�����
    reg buffer_0,buffer_1,buffer_2;//��ȥ�˲�

    reg ena_add;//�ӷ�ʹ���ź�

    always @ (posedge CLK)
    begin
        if(!RST_n)
        begin
            buffer_0<=1;
            buffer_1<=1;
            buffer_2<=1;
        end
        else
        begin
            buffer_0<=get;
            buffer_1<=buffer_0;
            buffer_2<=buffer_1;
        end
    end

    assign buffer_en=buffer_2&~buffer_1;

    always @ (posedge CLK)
    begin
        if(!RST_n)
        begin
            cn1<=0;
        end
        else if(ena_add)
        begin
            if(cn1==bps-1)
            begin
                cn1<=0;
            end
            else
            begin
                cn1<=cn1+1;
            end
        end
    end

    always @ (posedge CLK)
    begin
        if(!RST_n)
        begin
            cn2<=0;
        end
        else if(ena_add&&cn1==bps-1)
        begin
            if(cn2==8)
            begin
                cn2<=0;
            end
            else
            begin
                cn2<=cn2+1;
            end
        end
    end

    always @ (posedge CLK)
    begin
        if(!RST_n)
        begin
            ena_add<=0;
        end
        else if(buffer_en)
        begin
            ena_add<=1;
        end
        else if(ena_add&&cn2==8&&cn1==bps-1)
        begin
            ena_add<=0;
        end
    end
    
    always @ (posedge CLK)
    begin
        if(!RST_n)
        begin
            out<=0;
        end
        else if(ena_add&&cn1==bps/2-1&&cn2!=0)
        begin
            out[cn2-1]<=get;
        end
    end



endmodule