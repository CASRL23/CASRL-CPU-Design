//module for multi issue tomasulos fetch unit
module Fetch(
    input wire Clk, Reset, Stall, Branch_resolved, 
    input wire [3:0] PC_en, 
    input wire [31:0] PC_in,
    
    input wire [31:0] Branch_target0, Branch_target1, Branch_target2, Branch_target3, Branch_target4,
    input wire Mispredict0, Mispredict1, Mispredict2, Mispredict3, Mispredict4, 
    
    output reg [31:0] PC_out0, PC_out1, PC_out2, PC_out3
);

always @(posedge Clk) begin
    if (Reset) begin
        PC_out0 <= 32'd0;
        PC_out1 <= 32'd4;
        PC_out2 <= 32'd8;
        PC_out3 <= 32'd12;
    end
    //if not reset but stalled, dont change outputs 
    else begin
        
    end
end

endmodule