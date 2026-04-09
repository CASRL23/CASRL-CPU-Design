//This module compares 2 32-bit input operands Op1 and Op2.
//If Op1 is less than Op2, then return 32'ffffffff as the result.
//Otherwise, result is 32'h00000000
module Set_less_than_signed(
    output wire [31:0] Result,
    input wire [31:0] Op1, Op2
);

    // Wires to hold N and V bits from the subtraction
    wire [31:0] Sub_result;
    wire        N_bit;
    wire        V_bit;

    // This instantiation assumes Sub_32_bit is modified
    // to output the N bit (Sub_result[31]) and the V bit.
    Sub_32_bit SLTS(
        .Op1(Op1), 
        .Op2(Op2), 
        .Result(Sub_result),
        .Borrow_out(open),     // *** FIX: This line was missing ***
        .Overflow_out(V_bit)
    );

    assign N_bit = Sub_result[31];
    assign Result = {{31'b0, N_bit^V_bit}};

endmodule