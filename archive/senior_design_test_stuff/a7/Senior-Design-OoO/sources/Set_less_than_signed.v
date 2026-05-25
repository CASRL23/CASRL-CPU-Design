//This module compares 2 32-bit input operands Op1 and Op2. 
//If Op1 is less than Op2, then return 32'ffffffff as the result. Otherwise, result is 32'h00000000
module Set_less_than_signed(
    output wire [31:0] Result,
    input wire [31:0] Op1, Op2
);

//Wire to hold output of subtraction operation
wire [31:0] Sub_result;

//since this is a gate level operation, Op1 will be subtracted from Op2 and if that result is negative output 0
Sub_32_bit SLTS(.Op1(Op1), .Op2(Op2), .Result(Sub_result));


//for the signed set les than, the result is either 32'hffffffff or 32'h00000000
assign Result = {32{Sub_result[31]}};

endmodule