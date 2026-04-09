//This module is a test bench for the set less than unsigned module for the ALU
//if Op1 < Op2 (signified by borrow out being 1), the output will be 1. Otherwise the output will be 0
module SLTu_tb();
    wire [31:0] Result;
    reg [31:0] Op1, Op2;
    
//instantiate SLTu module
Set_less_than_unsigned SLTU_uut(.Op1(Op1), .Op2(Op2), .Result(Result));

initial begin


    //Op1 = Op2, Result should be 0
    Op1 = 32'hfff000ff; Op2 = 32'hfff000ff; #10;  
      
    //Op1 > Op2, Result should be 0
    Op1 = 32'h00001234; Op2 = 32'hffffffff; #10;    
    
    //Op1 < Op2, Result should be ffffffff
    Op1 = 32'hffffffff; Op2 = 32'h0005682; #10;
end
endmodule