`timescale 1ns/1ps

module Forwarding_unit_tb;
    // inputs
    reg EX_MEM_RegWrite, MEM_WB_RegWrite;
    reg [4:0] EX_MEM_Rd, MEM_WB_Rd, DE_Rs1, DE_Rs2;

    // outputs
    wire [1:0] ForwardA, ForwardB;

    // Instantiate 
    Forwarding_unit fu (
        .EX_MEM_RegWrite(EX_MEM_RegWrite),
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .EX_MEM_Rd(EX_MEM_Rd),
        .MEM_WB_Rd(MEM_WB_Rd),
        .DE_Rs1(DE_Rs1),
        .DE_Rs2(DE_Rs2),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    initial begin
        // Default: no forwarding
        EX_MEM_RegWrite=0; MEM_WB_RegWrite=0;
        EX_MEM_Rd=0; MEM_WB_Rd=0;
        DE_Rs1=1; DE_Rs2=2;
        #10;

        // EX hazard on Rs1
        EX_MEM_RegWrite=1; EX_MEM_Rd=5; MEM_WB_RegWrite=0; MEM_WB_Rd=0;
        DE_Rs1=5; DE_Rs2=3;
        #10;

        // EX hazard on Rs2
        EX_MEM_RegWrite=1; EX_MEM_Rd=6;
        DE_Rs1=1; DE_Rs2=6;
        #10;

        // MEM hazard on Rs1
        EX_MEM_RegWrite=0; MEM_WB_RegWrite=1; MEM_WB_Rd=7;
        DE_Rs1=7; DE_Rs2=2;
        #10;

        // MEM hazard on Rs2
        MEM_WB_RegWrite=1; MEM_WB_Rd=8;
        DE_Rs1=1; DE_Rs2=8;
        #10;

        // EX hazard has priority over MEM hazard
        EX_MEM_RegWrite=1; EX_MEM_Rd=9;
        MEM_WB_RegWrite=1; MEM_WB_Rd=9;
        DE_Rs1=9; DE_Rs2=9;
        #10;

        $finish;
    end

endmodule
