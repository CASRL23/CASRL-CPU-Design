//test bench for logical and function
module xor_tb();
    reg [31:0] Op1, Op2;
    wire [31:0] Result;

//instatiate and module and explicitly tie module components to tb
Logical_xor xor_uut(.Op1(Op1), .Op2(Op2), .Xor_result(Result));

//begin simulation
initial begin
    //result should be 32'h00000000
    Op1 <= 32'h00000000; Op2 <= 32'h00000000; #10;
    
    //result should be 32'h00000000
    Op1 <= 32'hffffffff; Op2 <= 32'hffffffff; #10;

    //result should be 32'hffffffff
    Op1 <= 32'hffffffff; Op2 <= 32'h00000000; #10;
    
    //result should be 32'hffffffff
    Op1 <= 32'h00000000; Op2 <= 32'hffffffff; #10;

              
end

endmodule