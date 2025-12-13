//This module is part of the ALU, performs the logical ORing of 2 operands
//Takes in 2 32 bit operands Op1 and Op2, outputs 32 bit result Or_result
module Logical_or(
    output wire [31:0] Or_result,
    input wire [31:0] Op1, Op2
);

//Xor_result changes everytime either operand changes as this is an async operation

assign  Or_result = Op1 | Op2;

endmodule
