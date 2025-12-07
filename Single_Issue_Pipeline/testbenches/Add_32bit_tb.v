//This module is the test bench for the 32 bit ripple carry lookahead adder. 
//Follows the same format as the other adder testbenches

module Ripple_CLA_32bit();
    wire [31:0] Result;
    wire C_out;
    reg [31:0] Op1, Op2;
    reg C_in;
    
//instantiate the 32 bit adder
Ripple_carry_lookahead_32bit Adder_32uut(.Op1(Op1), .Op2(Op2), .C_in(C_in), .Result(Result), .C_out(C_out));

initial begin
    //should raise C_out
    Op1 <= 32'h80000000; Op2 <= 32'h80000000; C_in <= 1'b0; #10;
    
    //Result and C_out should be all 1s
    Op1 <= 32'hffffffff; Op2 <= 32'hffffffff; C_in <= 1'b1; #10;
    
    //0+0+1 = 1, Result should be 1, C_out should be 0
    Op1 <= 32'h00000000; Op2 <= 32'h00000000; C_in <= 1'b1; #10;
    
    //5+7 returns a result of 7 and C_out of 0
    Op1 <= 32'h00000005; Op2 <= 32'h00000002; C_in <= 1'b0; #10;
    
    // Result should be 0 and C_out should be 1
    Op1 <= 32'hffffffff; Op2 <= 32'h00000001; C_in <= 1'b0; #10;
    
    //should result in 0010              
    Op1 <= 32'h0000000f; Op2 <= 32'h00000000; C_in <= 1'b1; #10;
    
    //should result in 0100              
    Op1 <= 32'h000000f0; Op2 <= 32'h00000010; C_in <= 1'b0; #10;    

    //should result in 1000              
    Op1 <= 32'h00000f00; Op2 <= 32'h00000100; C_in <= 1'b0; #10;
    
    //should result in 10000              
    Op1 <= 32'h0000f000; Op2 <= 32'h00001000; C_in <= 1'b0; #10; 
    
    //should result in 100000              
    Op1 <= 32'h000f0000; Op2 <= 32'h00010000; C_in <= 1'b0; #10;  
    
    //should result in 1000000              
    Op1 <= 32'h00f00000; Op2 <= 32'h00100000; C_in <= 1'b0; #10; 
    
    //should result in 10000000              
    Op1 <= 32'h0f000000; Op2 <= 32'h01000000; C_in <= 1'b0; #10;                 
end

endmodule