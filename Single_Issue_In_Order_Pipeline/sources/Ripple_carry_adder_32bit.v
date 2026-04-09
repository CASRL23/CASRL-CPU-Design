//This module is a 32 bit ripple carry lookahead adder. Takes in 2 32 bit inputs Op1 and Op2 and a 1 bit C_in
//Splits the 2 Ops into 16 bit values and ripples them through 2 instances of the 16 bit CLA_R adders
//Outputs a 32 bit value Result and a 1 bit value C_out
module Ripple_carry_lookahead_32bit(
    output wire [31:0] Result,
    output wire C_out,
    input wire [31:0] Op1, Op2,
    input wire C_in
);

//Connecting wire for carryover between the 2 adders
wire Carry;

//instantiate 2 16 bit adders
Ripple_carry_adder16bit Cla_r1(.Op1(Op1[15:0]), .Op2(Op2[15:0]), .C_in(C_in), .Result(Result[15:0]), .C_out(Carry));
Ripple_carry_adder16bit Cla_r2(.Op1(Op1[31:16]), .Op2(Op2[31:16]), .C_in(Carry), .Result(Result[31:16]), .C_out(C_out));

endmodule