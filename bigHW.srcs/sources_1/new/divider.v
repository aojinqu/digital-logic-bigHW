`timescale 1ns / 1ps


//module Divider #(parameter Time=20)
//(
//    input I_CLK,
//    output reg O_CLK
//);
//    integer counter=0;
//    initial O_CLK = 0;
//    always @ (posedge I_CLK)
//    begin
//        if((counter+1)==Time/2)
//        begin
//            counter <= 0;
//            O_CLK <= ~O_CLK;
//        end
//        else
//            counter <= counter+1;
//    end
//endmodule

module Divider #(parameter N=1000000)
(
    input I_CLK,
    output reg O_CLK_1M
);
    integer i=0;
    always@(posedge I_CLK)
    begin
    if(i == N / 2 - 1) 
    begin
       O_CLK_1M <= ~O_CLK_1M;
       i <= 0;
    end
    else
       i <= i + 1;
    end         
endmodule