//This module compares 2 unsigned values Op1 and Op2. if Op1 < Op2, return 1, otherwise 0
//Set less than will be performed by subtracting Op1 from Op2 and checking the result
module Set_less_than_unsigned(
    output wire [31:0] Result,
    input wire [31:0] Op1, Op2
);



wire Borrow_out;

//instantiate subtractor, performing Op1-Op2. if returned value is negative (Borrow_out==1), return 1
Sub_32_bit Slt_sub(.Op1(Op1), .Op2(Op2), .Result(open), .Borrow_out(Borrow_out));


assign Result = {31'b0, Borrow_out};


endmodule