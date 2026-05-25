//This module is a test bench for the 16 bit ripple carry lookahead adder

module CLA_16bit();
    wire [15:0] Result;
    wire C_out;
    reg [15:0] Op1, Op2;
    reg C_in;
    
//instantiate 4 bit carry lookahead adder
Ripple_carry_adder16bit CLA_16_uut(.Op1(Op1), .Op2(Op2), .C_in(C_in), .C_out(C_out), .Result(Result));

initial begin
    //should raise C_out
    Op1 <= 16'h8000; Op2 <= 16'h8000; C_in <= 1'b0; #10;
    
    //Result and C_out should be all 1s
    Op1 <= 16'hffff; Op2 <= 16'hffff; C_in <= 1'b1; #10;
    
    //0+0+1 = 1, Result should be 1, C_out should be 0
    Op1 <= 16'h0000; Op2 <= 16'h0000; C_in <= 1'b1; #10;
    
    //5+7 returns a result of 7 and C_out of 0
    Op1 <= 16'h0005; Op2 <= 16'h0002; C_in <= 1'b0; #10;
    
    // Result should be 0 and C_out should be 1
    Op1 <= 16'hffff; Op2 <= 16'h0001; C_in <= 1'b0; #10;
    
    //should result in 0010              
    Op1 <= 16'h000f; Op2 <= 16'h0000; C_in <= 1'b1; #10;
    
    //should result in 0100              
    Op1 <= 16'h00f0; Op2 <= 16'h0010; C_in <= 1'b0; #10;    

    //should result in 1000              
    Op1 <= 16'h0f00; Op2 <= 16'h0100; C_in <= 1'b0; #10; 
end


endmodule