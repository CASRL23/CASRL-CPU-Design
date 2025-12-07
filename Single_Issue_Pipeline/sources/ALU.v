//This module conatains the Arithmetic Logic Unit according to the RISCV 32 bit base standard
//takes 2 operands of 32 bits Op1 and Op2 as inputs as well as a 4 bit ALU op_code
//outputs a 32 bit value Alu_result
module Alu(
    output reg [31:0] Alu_result,
    input wire [3:0] Alu_op,
    input wire [31:0] Op1, Op2
    );
    
    
//***Create wires for each result of the ALU. These will be fed into a mux. ***//
wire [31:0] Add_result, 
            Sub_result, 
            Xor_result, 
            Or_result, 
            And_result, 
            LSL_result, 
            LSR_result, 
            ASR_result,
            SLTS_result,
            SLTU_result;


//***instantiate every module in the ALU to be run at the same time***//

//32 bit add operation
Ripple_carry_lookahead_32bit Alu_add(.Op1(Op1), .Op2(Op2), .Result(Add_result), .C_out(open), .C_in(1'b0));

//32 bit subtract operation
Sub_32_bit Alu_sub(.Borrow_out(open), .Op1(Op1), .Op2(Op2), .Result(Sub_result));

//XOR
Logical_xor Alu_xor(.Op1(Op1), .Op2(Op2), .Xor_result(Xor_result));

//OR
Logical_or Alu_or(.Op1(Op1), .Op2(Op2), .Or_result(Or_result));

//AND
Logical_and Alu_and(.Op1(Op1), .Op2(Op2), .And_result(And_result));

//Logical shift left
assign LSL_result = Op1 << Op2;

//Logical shift right
assign LSR_result = Op1 >> Op2;

//arithmetic shift right
assign ASR_result = $signed(Op1) >>> Op2;

//Set less than Unsigned
Set_less_than_unsigned Alu_SLTU(.Op1(Op1), .Op2(Op2), .Result(SLTU_result));

//Set less than signed
Set_less_than_signed Alu_SLTS(.Op1(Op1), .Op2(Op2), .Result(SLTS_result));


    
//ALU acts asynchronously. The output changes whenever the opcode or either operand changes
//Below is the mux that outputs the correct ALU operation corresponding to the ALU opcode
always @(Alu_op, 
                Op1, 
                Op2,                
                Add_result,
                Sub_result,
                Xor_result,
                Or_result,
                And_result,
                LSL_result,
                LSR_result,
                ASR_result,
                SLTS_result,
                SLTU_result) 
begin
    case(Alu_op)
        //if ALU opcode is 0, add the operands and return result
        4'h0: Alu_result = Add_result;
        
        //if opcode is 1, subtract Op2 from Op1
        4'h1: Alu_result = Sub_result;
        
        //if opcode is 2, XOR the 2 values
        4'h2: Alu_result = Xor_result;
        
        //if opcode is 3, OR the 2 values
        4'h3: Alu_result = Or_result;
        
        //if opcode is 4, AND the 2 values together
        4'h4: Alu_result = And_result;        
        
        //if opcode is 5, logical shift left Op1 by Op2 bits
        4'h5: Alu_result = LSL_result;
        
        //if opcode is 6, logical shift right Op1 by Op2 bits (0 extended shift right)
        4'h6: Alu_result = LSR_result;
        
        //if opcode is 7, arithmetic shift right Op1 by Op2 bits (sign extended right)
        4'h7: Alu_result = ASR_result;
        
        //if opcode is 8, set Result to 1 if Op1 < Op2, set Result to 0 otherwise 
        4'h8: Alu_result = SLTS_result;
        
        //if opcode is 9, set Result to 1 if Op1 < Op2, set Result to 0 otherwise
        4'h9: Alu_result = SLTU_result;  
        
        //if no valid opcodes are sent, alu is not going to output anything
        default: Alu_result = 32'h00000000;               
    endcase
end
endmodule