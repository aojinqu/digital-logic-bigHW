`timescale 1ns / 1ps

//·À¶¶
module debouncer(  
    input clk,
    input I0,
    input I1,
    output reg O0,
    output reg O1
    );
integer cnt0,cnt1;
reg Iv0=0,Iv1=0;
reg out0, out1;
    
always@(posedge clk) begin
  if (I0==Iv0)
  begin
    if (cnt0==19) 
        O0<=I0;
    else 
        cnt0<=cnt0+1; 
  end
  else 
        cnt0<=0;
        Iv0<=I0;
  if (I1==Iv1) 
  begin 
    if (cnt1==19) 
        O1<=I1; 
    else 
        cnt1<=cnt1+1;
  end
  else 
  begin
  cnt1<=0;
  Iv1<=I1;
  end

end
    

endmodule
