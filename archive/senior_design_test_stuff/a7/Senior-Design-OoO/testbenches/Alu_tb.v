//This module is the testbench for the ALU. Takes in 2 operands and an Alu opcode and outputs a result
module Alu_tb();
    wire [31:0] Alu_result;
    reg [3:0] Alu_op;
    reg [31:0] Op1, Op2;
    
//instantiate ALU
Alu Alu_uut(.Alu_result(Alu_result), .Op1(Op1), .Op2(Op2), .Alu_op(Alu_op));

initial begin
    //add 2 to ffffffff. Output should be 1, good
    Op1 = 32'h00000002; Op2 = 32'hffffffff; Alu_op = 4'h0; #10;
    
    //subtract 3 from efffffff. Output should be effffffb, good
    Op1 = 32'hefffffff; Op2 = 32'h00000003; Alu_op = 4'h1; #10;
    
    //xor aaaaaaaa with 55550000. Output should be ffffaaaa, good
    Op1 = 32'haaaaaaaa; Op2 = 32'h55550000; Alu_op = 4'h2; #10;
    
    //or 5071000 from 23000025. Output should be 73710025, not good 
    Op1 = 32'h5071000; Op2 = 32'h23000025; Alu_op = 4'h3;#10;
    
    //and 55332211 to ffffffff. Output should be 55332211
    Op1 = 32'h55332211; Op2 = 32'hffffffff; Alu_op = 4'h4;#10;
    
    //shift 0000000f left by 8. Output should be 00000f00
    Op1 = 32'h0000000f; Op2 = 32'h00000008; Alu_op = 4'h5;#10;
    
    //logical shift 1000ffff right by 12. Output should be 0001000f
    Op1 = 32'h1000ffff; Op2 = 32'h0000000c; Alu_op = 4'h6; #10;
    
    //arithmetic shift ff000110 right by 24. Output should be ffffffff 
    Op1 = 32'hff000110; Op2 = 32'd24; Alu_op = 4'h7;#10;
    
    //set less than signed. Output should be ffffffff
    Op1 = 32'hf000000f; Op2 = 32'h00000008; Alu_op = 4'h8; #10;
    
    //set less than unsigned. Output should be 0
    Op1 = 32'hf000ffff; Op2 = 32'h0000000c; Alu_op = 4'h9;#10;
    
    //invalid opcode, output should be zzzzzzzz
    Op1 = 32'hff000110; Op2 = 32'd24; Alu_op = 4'ha; #10;   
    
    //invalid opcode, output should be zzzzzzzz
    Op1 = 32'hff000110; Op2 = 32'd24; Alu_op = 4'hb; #10; 
    
    //invalid opcode, output should be zzzzzzzz
    Op1 = 32'hff000110; Op2 = 32'd24; Alu_op = 4'hc; #10;   
    
    //invalid opcode, output should be zzzzzzzz
    Op1 = 32'hff000110; Op2 = 32'd24; Alu_op = 4'hd; #10;   
    
     //invalid opcode, output should be zzzzzzzz
    Op1 = 32'hff000110; Op2 = 32'd24; Alu_op = 4'he; #10;   
    
    //invalid opcode, output should be zzzzzzzz
    Op1 = 32'hff000110; Op2 = 32'd24; Alu_op = 4'hf; #10;                       

end
endmodule
