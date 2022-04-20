module bluetooth(
    input CLK,
    input RST_n,
    input get,
    output reg [7:0] out
    );

    
    wire buffer_en;//检测到边沿
    parameter bps=10417;////对应9600波特率，如果要仿真可以设置为8
    // 或者更小,才能看到结果。
    reg [14:0] cn1;//每一位中的计数器
    reg [3:0] cn2;//每一组数据的计数器
    reg buffer_0,buffer_1,buffer_2;//除去滤波

    reg ena_add;//加法使能信号

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