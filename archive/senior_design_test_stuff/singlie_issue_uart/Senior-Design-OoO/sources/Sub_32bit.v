//This module takes in 2 32 bit operands, Op1 and Op2 and performs Op1-Op2. The result is stroed in 
//32 bit value named Result and a Borrow out single bit value used for SLT
module Sub_32_bit(
    output wire [31:0] Result,
    output wire Borrow_out,
    input wire [31:0] Op1, Op2    
);

//Wires to hold ones complement of Op2
wire [31:0] Ones_comp;

//wire to hold the carryout value to be inverted for Borrow_out
wire C_out;

//Xor Op2 and feed it into the 32 bit adder
Logical_xor Sub_xor(.Op1(Op2), .Op2(32'hffffffff), .Xor_result(Ones_comp));

//Perform Op1-Op2 by adding Op1 to Op2 and pulling C_in to 1 (to get the 2's complement of Op2)
Ripple_carry_lookahead_32bit Sub32(.C_out(C_out), .Op1(Op1), .Op2(Ones_comp), .Result(Result), .C_in(1'b1)); 


//Assign borrow_out to be the inverse of C_out
assign Borrow_out = ~C_out;


endmodule
