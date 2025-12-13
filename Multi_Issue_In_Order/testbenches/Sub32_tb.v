//This module is the testbench for the subtractor module
//should perform Result = Op1-Op2
module Sub32_tb();
    wire [31:0] Result;
    reg [31:0] Op1, Op2;
    
Sub_32_bit sub_uut(.Op1(Op1), .Op2(Op2), .Result(Result));    

initial begin
    //7-5 = 2
    Op1 = 32'h00000007; Op2 = 32'h00000005; #10;

    //Op1= Op2, should return 0
    Op1 = 32'hffffffff; Op2 = 32'hffffffff; #10;

    //5-32 = -27
    Op1 = 32'h00000005; Op2 = 32'd32; #10;

end
endmodule