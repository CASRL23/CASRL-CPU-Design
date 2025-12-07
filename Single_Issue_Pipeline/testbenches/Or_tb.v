//test bench for logical and function
module Or_tb();
    reg [31:0] Op1, Op2;
    wire [31:0] Result;

//instatiate and module and explicitly tie module components to tb
Logical_or or_uut(.Op1(Op1), .Op2(Op2), .Or_result(Result));

//begin simulation
initial begin
    //result should be 32'hffffffff
    Op1 <= 32'hffff0000; Op2 <= 32'h0000ffff; #10;
    
    //result should be 32'aaaa5555
    Op1 <= 32'haaaa0000; Op2 <= 32'h00005555; #10;

    //result should be 32'h000000000
    Op1 <= 32'h00000000; Op2 <= 32'h00000000; #10;
    
    //result should be 32'hffffffff
    Op1 <= 32'haaaaaaaa; Op2 <= 32'h55555555; #10;
    
    //result should be 32'hfedcba98
    Op1 <= 32'h00000000; Op2 <= 32'hfedcba98; #10;
              
end

endmodule