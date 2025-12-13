//This module is part of the ALU, performs the logical ANDing of 2 operands
//Takes in 2 32 bit operands Op1 and Op2, outputs 32 bit result And_result
module Logical_and(
    output wire [31:0] And_result,
    input wire [31:0] Op1, Op2
);

//And_result changes everytime either operand changes as this is an async operation

assign And_result = Op1 & Op2;

endmodule