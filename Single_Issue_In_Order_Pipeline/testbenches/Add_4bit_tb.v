//This module is a test bench for the 4 bit carry lookahead adder

module CLA_4bit();
    wire [3:0] Result;
    wire C_out;
    reg [3:0] Op1, Op2;
    reg C_in;
    
//instantiate 4 bit carry lookahead adder
CLA_adder_4bit CLA_uut(.Op1(Op1), .Op2(Op2), .C_in(C_in), .C_out(C_out), .Result(Result));

initial begin
    //8+8 = 16, should raise C_out
    Op1 <= 4'h8; Op2 <= 4'h8; C_in <= 1'b0; #10;
    
    //15+15+1 = 31, Result and C_out should be all 1s
    Op1 <= 4'hf; Op2 <= 4'hf; C_in <= 1'b1; #10;
    
    //0+0+1 = 1, Result should be 1, C_out should be 0
    Op1 <= 4'h0; Op2 <= 4'h0; C_in <= 1'b1; #10;
    
    //5+7 returns a result of 7 and C_out of 0
    Op1 <= 4'h5; Op2 <= 4'h2; C_in <= 1'b0; #10;
    
    //15+1 returns 16, Result should be 0 and C_out should be 1
    Op1 <= 4'hf; Op2 <= 4'h1; C_in <= 1'b0; #10;              
end


endmodule