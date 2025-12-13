module Multi_Issue_Forwarding_Unit(
    // EX/MEM stage - all 4 lanes
    input wire EX_MEM_RegWrite0,
    input wire EX_MEM_RegWrite1,
    input wire EX_MEM_RegWrite2,
    input wire EX_MEM_RegWrite3,
    input wire [4:0] EX_MEM_Rd0,
    input wire [4:0] EX_MEM_Rd1,
    input wire [4:0] EX_MEM_Rd2,
    input wire [4:0] EX_MEM_Rd3,
    
    // MEM/WB stage - all 4 lanes
    input wire MEM_WB_RegWrite0,
    input wire MEM_WB_RegWrite1,
    input wire MEM_WB_RegWrite2,
    input wire MEM_WB_RegWrite3,
    input wire [4:0] MEM_WB_Rd0,
    input wire [4:0] MEM_WB_Rd1,
    input wire [4:0] MEM_WB_Rd2,
    input wire [4:0] MEM_WB_Rd3,
    
    // Current instruction's source registers
    input wire [4:0] DE_Rs1,
    input wire [4:0] DE_Rs2,
    
    // Outputs
    output reg [1:0] ForwardA,      // 00=no forward, 01=EX/MEM, 10=MEM/WB
    output reg [1:0] ForwardB,
    output reg [1:0] ForwardA_lane, // Which lane to forward from (0-3)
    output reg [1:0] ForwardB_lane
);

    // Forwarding logic for Rs1 (Operand A)
    always @(EX_MEM_RegWrite0, EX_MEM_RegWrite1, EX_MEM_RegWrite2, EX_MEM_RegWrite3,
             EX_MEM_Rd0, EX_MEM_Rd1, EX_MEM_Rd2, EX_MEM_Rd3,
             MEM_WB_RegWrite0, MEM_WB_RegWrite1, MEM_WB_RegWrite2, MEM_WB_RegWrite3,
             MEM_WB_Rd0, MEM_WB_Rd1, MEM_WB_Rd2, MEM_WB_Rd3,
             DE_Rs1) begin
        // Default: no forwarding
        ForwardA = 2'b00;
        ForwardA_lane = 2'b00;
        
        // Check EX/MEM stage (lanes 0-3, prioritize 3->2->1->0)
        if (EX_MEM_RegWrite3 && (EX_MEM_Rd3 != 5'b0) && (EX_MEM_Rd3 == DE_Rs1)) begin
            ForwardA = 2'b01;
            ForwardA_lane = 2'b11;
        end
        else if (EX_MEM_RegWrite2 && (EX_MEM_Rd2 != 5'b0) && (EX_MEM_Rd2 == DE_Rs1)) begin
            ForwardA = 2'b01;
            ForwardA_lane = 2'b10;
        end
        else if (EX_MEM_RegWrite1 && (EX_MEM_Rd1 != 5'b0) && (EX_MEM_Rd1 == DE_Rs1)) begin
            ForwardA = 2'b01;
            ForwardA_lane = 2'b01;
        end
        else if (EX_MEM_RegWrite0 && (EX_MEM_Rd0 != 5'b0) && (EX_MEM_Rd0 == DE_Rs1)) begin
            ForwardA = 2'b01;
            ForwardA_lane = 2'b00;
        end
        // Check MEM/WB stage if no EX/MEM match (lanes 3->2->1->0)
        else if (MEM_WB_RegWrite3 && (MEM_WB_Rd3 != 5'b0) && (MEM_WB_Rd3 == DE_Rs1)) begin
            ForwardA = 2'b10;
            ForwardA_lane = 2'b11;
        end
        else if (MEM_WB_RegWrite2 && (MEM_WB_Rd2 != 5'b0) && (MEM_WB_Rd2 == DE_Rs1)) begin
            ForwardA = 2'b10;
            ForwardA_lane = 2'b10;
        end
        else if (MEM_WB_RegWrite1 && (MEM_WB_Rd1 != 5'b0) && (MEM_WB_Rd1 == DE_Rs1)) begin
            ForwardA = 2'b10;
            ForwardA_lane = 2'b01;
        end
        else if (MEM_WB_RegWrite0 && (MEM_WB_Rd0 != 5'b0) && (MEM_WB_Rd0 == DE_Rs1)) begin
            ForwardA = 2'b10;
            ForwardA_lane = 2'b00;
        end
    end
    
    // Forwarding logic for Rs2 (Operand B)
    always @(EX_MEM_RegWrite0, EX_MEM_RegWrite1, EX_MEM_RegWrite2, EX_MEM_RegWrite3,
             EX_MEM_Rd0, EX_MEM_Rd1, EX_MEM_Rd2, EX_MEM_Rd3,
             MEM_WB_RegWrite0, MEM_WB_RegWrite1, MEM_WB_RegWrite2, MEM_WB_RegWrite3,
             MEM_WB_Rd0, MEM_WB_Rd1, MEM_WB_Rd2, MEM_WB_Rd3,
             DE_Rs2) begin
        // Default: no forwarding
        ForwardB = 2'b00;
        ForwardB_lane = 2'b00;
        
        // Check EX/MEM stage (lanes 0-3, prioritize 3->2->1->0)
        if (EX_MEM_RegWrite3 && (EX_MEM_Rd3 != 5'b0) && (EX_MEM_Rd3 == DE_Rs2)) begin
            ForwardB = 2'b01;
            ForwardB_lane = 2'b11;
        end
        else if (EX_MEM_RegWrite2 && (EX_MEM_Rd2 != 5'b0) && (EX_MEM_Rd2 == DE_Rs2)) begin
            ForwardB = 2'b01;
            ForwardB_lane = 2'b10;
        end
        else if (EX_MEM_RegWrite1 && (EX_MEM_Rd1 != 5'b0) && (EX_MEM_Rd1 == DE_Rs2)) begin
            ForwardB = 2'b01;
            ForwardB_lane = 2'b01;
        end
        else if (EX_MEM_RegWrite0 && (EX_MEM_Rd0 != 5'b0) && (EX_MEM_Rd0 == DE_Rs2)) begin
            ForwardB = 2'b01;
            ForwardB_lane = 2'b00;
        end
        // Check MEM/WB stage if no EX/MEM match (lanes 3->2->1->0)
        else if (MEM_WB_RegWrite3 && (MEM_WB_Rd3 != 5'b0) && (MEM_WB_Rd3 == DE_Rs2)) begin
            ForwardB = 2'b10;
            ForwardB_lane = 2'b11;
        end
        else if (MEM_WB_RegWrite2 && (MEM_WB_Rd2 != 5'b0) && (MEM_WB_Rd2 == DE_Rs2)) begin
            ForwardB = 2'b10;
            ForwardB_lane = 2'b10;
        end
        else if (MEM_WB_RegWrite1 && (MEM_WB_Rd1 != 5'b0) && (MEM_WB_Rd1 == DE_Rs2)) begin
            ForwardB = 2'b10;
            ForwardB_lane = 2'b01;
        end
        else if (MEM_WB_RegWrite0 && (MEM_WB_Rd0 != 5'b0) && (MEM_WB_Rd0 == DE_Rs2)) begin
            ForwardB = 2'b10;
            ForwardB_lane = 2'b00;
        end
    end

endmodule