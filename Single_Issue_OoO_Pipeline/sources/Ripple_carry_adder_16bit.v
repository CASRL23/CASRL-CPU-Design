//This module is a ripple C_out adder for 2 16 bit values. Takes in 2 16 bit values Op1 and Op2 and a single bit carry in (C_in)
//The values of Op1 and Op2 are split in 4 and sent to 4 CLA adders linked in ripple carry fashion
//Outputs a 16 bit value Result 
module Ripple_carry_adder16bit(
                     output wire [15:0] Result,
                     output wire C_out,
                     input wire [15:0] Op1, Op2,
                     input wire C_in
);
//connecting wires for carryout of each adder
wire c0, c1, c2;
                     
CLA_adder_4bit Cla_r1(.Op1(Op1[3:0]), .Op2(Op2[3:0]), .C_in(C_in), .Result(Result[3:0]), .C_out(c0));
CLA_adder_4bit Cla_r2(.Op1(Op1[7:4]), .Op2(Op2[7:4]), .C_in(c0), .Result(Result[7:4]), .C_out(c1));
CLA_adder_4bit Cla_r3(.Op1(Op1[11:8]), .Op2(Op2[11:8]), .C_in(c1), .Result(Result[11:8]), .C_out(c2));
CLA_adder_4bit Cla_r4(.Op1(Op1[15:12]), .Op2(Op2[15:12]), .C_in(c2), .Result(Result[15:12]), .C_out(C_out));                     
endmodule