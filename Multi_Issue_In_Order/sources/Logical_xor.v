//This module is part of the ALU, performs the logical XORing of 2 operands
//Takes in 2 32 bit operands Op1 and Op2, outputs 32 bit result Xor_result
module Logical_xor(
    output wire [31:0] Xor_result,
    input wire [31:0] Op1, Op2
);

//Xor_result changes everytime either operand changes as this is an async operation

assign Xor_result = Op1 ^ Op2;

endmodule
