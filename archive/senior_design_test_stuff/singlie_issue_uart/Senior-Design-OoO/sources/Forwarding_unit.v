module Forwarding_unit (
    input  wire EX_MEM_RegWrite, MEM_WB_RegWrite,
    input  wire [4:0] EX_MEM_Rd, MEM_WB_Rd, DE_Rs1, DE_Rs2,
    output reg  [1:0] ForwardA, ForwardB
);

    always @(EX_MEM_RegWrite or EX_MEM_Rd or MEM_WB_RegWrite or MEM_WB_Rd or DE_Rs1 or DE_Rs2) begin

        // Default: no forwarding
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        // ForwardA
        if (EX_MEM_RegWrite && (EX_MEM_Rd != 5'b00000) && (EX_MEM_Rd == DE_Rs1))
            ForwardA = 2'b01; // EX hazard
        else if (MEM_WB_RegWrite && (MEM_WB_Rd != 5'b00000) && (MEM_WB_Rd == DE_Rs1))
            ForwardA = 2'b10; // MEM hazard

        // ForwardB
        if (EX_MEM_RegWrite && (EX_MEM_Rd != 5'b00000) && (EX_MEM_Rd == DE_Rs2))
            ForwardB = 2'b01; // EX hazard
        else if (MEM_WB_RegWrite && (MEM_WB_Rd != 5'b00000) && (MEM_WB_Rd == DE_Rs2))
            ForwardB = 2'b10; // MEM hazard
    end

endmodule
