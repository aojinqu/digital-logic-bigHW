`timescale 1ns / 1ps


module display7(
    input CLK,
    input RST_n,
	input [3:0] in,     //À¶ÑÀÎ²Êý
    input [11:0]score,
    input [3:0]level,
    output reg [6:0] oData
    );



Divider #(.N(1000000)) CLKDIV5(CLK,clk);


reg [3:0]iData;
reg [3:0]mid;
reg [3:0]tmp;
reg [11:0]cnt;

always @(posedge CLK ) begin
       if(!RST_n)
        begin
            tmp<=0;
            cnt<=1;
        end
       else if((in==1||in==2||in==3)&&in!=tmp)
       begin
           tmp<=in;
           iData<=cnt/10;
           cnt<=cnt+1;
        end

end




always @(posedge clk)
    begin
        if(iData==0)
            oData<=7'b1000000;
        else if(iData==1)
            oData<=7'b1111001;
        else if(iData==2)
            oData<=7'b0100100;
        else if(iData==3)
            oData<=7'b0110000;
        else if(iData==4)
            oData<=7'b0011001;
        else if(iData==5)
            oData<=7'b0010010;
        else if(iData==6)
            oData<=7'b0000010;
        else if(iData==7)
            oData<=7'b1111000;  
        else if(iData==8)
            oData<=7'b0000000;  
        else if(iData==9)
            oData<=7'b0010000;                                                      
    end

endmodule

