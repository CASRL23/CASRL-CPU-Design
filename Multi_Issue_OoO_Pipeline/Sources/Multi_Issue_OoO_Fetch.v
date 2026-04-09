module Multi_Issue_Fetch_unit(
    input wire Clk, Reset, Fetch_done, 
    input wire [2:0] Issued, // Number of valid instructions allowed to fetch (e.g. queue space)
    
    // Control Inputs
    input wire [3:0] Pred_taken, Pred_miss,
    input wire [31:0] PC_in, // MUST BE: Current_PC + 16
    
    // Target Inputs
    input wire [31:0] Pred_target0, Pred_target1, Pred_target2, Pred_target3,
    input wire [31:0] Miss_target0, Miss_target1, Miss_target2, Miss_target3,
    
    // Outputs
    output reg [31:0] PC0, PC1, PC2, PC3,
    output reg [3:0] Valid_Out // NEW: Mask to tell IQ which instructions are valid
);

    // 1. Combinational Logic: Calculate the Valid Mask for the CURRENT cycle
    // This tells the Instruction Queue: "Ignore slots 1, 2, and 3 if slot 0 branched."
    always @* begin
        // Default: All issued instructions are valid
        Valid_Out = 4'b1111; 

        // If we are recovering from a miss, the whole current fetch is likely garbage
        // (depending on your recovery timing, usually you flush the whole stage)
        if (Pred_miss != 4'b0000) begin
            Valid_Out = 4'b0000;
        end
        // Branch Shadow Logic
        else if (Pred_taken[0]) Valid_Out = 4'b0001; // Only inst 0 is valid
        else if (Pred_taken[1]) Valid_Out = 4'b0011; // Inst 0 & 1 valid
        else if (Pred_taken[2]) Valid_Out = 4'b0111; // Inst 0, 1 & 2 valid
        // If Pred_taken[3], all 4 are valid (branch is at the end)
    end

    // 2. Sequential Logic: Update PCs for NEXT cycle
    always @(posedge Clk) begin
        if (Reset) begin
            PC0 <= 32'd0;
            PC1 <= 32'd4;
            PC2 <= 32'd8;
            PC3 <= 32'd12; 
        end
        else if (!Fetch_done) begin
            // --- PRIORITY 1: MISPREDICT RECOVERY ---
            if (Pred_miss[0]) begin
                PC0 <= Miss_target0;
                PC1 <= Miss_target0 + 32'd4;
                PC2 <= Miss_target0 + 32'd8;
                PC3 <= Miss_target0 + 32'd12;
            end
            else if (Pred_miss[1]) begin
                PC0 <= Miss_target1;
                PC1 <= Miss_target1 + 32'd4;
                PC2 <= Miss_target1 + 32'd8;
                PC3 <= Miss_target1 + 32'd12;        
            end
            else if (Pred_miss[2]) begin
                PC0 <= Miss_target2;
                PC1 <= Miss_target2 + 32'd4;
                PC2 <= Miss_target2 + 32'd8;
                PC3 <= Miss_target2 + 32'd12;            
            end
            else if (Pred_miss[3]) begin
                PC0 <= Miss_target3;
                PC1 <= Miss_target3 + 32'd4;
                PC2 <= Miss_target3 + 32'd8;
                PC3 <= Miss_target3 + 32'd12;        
            end
            
            // --- PRIORITY 2: PREDICT TAKEN ---
            else if (Pred_taken[0] && (Issued >= 3'd1)) begin
                PC0 <= Pred_target0;
                PC1 <= Pred_target0 + 32'd4;
                PC2 <= Pred_target0 + 32'd8;
                PC3 <= Pred_target0 + 32'd12;
            end 
            else if (Pred_taken[1] && (Issued >= 3'd2)) begin
                PC0 <= Pred_target1;
                PC1 <= Pred_target1 + 32'd4;
                PC2 <= Pred_target1 + 32'd8;
                PC3 <= Pred_target1 + 32'd12;
            end 
            else if (Pred_taken[2] && (Issued >= 3'd3)) begin
                PC0 <= Pred_target2;
                PC1 <= Pred_target2 + 32'd4;
                PC2 <= Pred_target2 + 32'd8;
                PC3 <= Pred_target2 + 32'd12;
            end 
            else if (Pred_taken[3] && (Issued == 3'd4)) begin
                PC0 <= Pred_target3;
                PC1 <= Pred_target3 + 32'd4;
                PC2 <= Pred_target3 + 32'd8;
                PC3 <= Pred_target3 + 32'd12;
            end
            
            // --- DEFAULT: Sequential ---
            // Ensure PC_in is (Current_PC + 16) externally!
            else begin
                PC0 <= PC_in;
                PC1 <= PC_in + 32'd4;
                PC2 <= PC_in + 32'd8;
                PC3 <= PC_in + 32'd12;
            end        
        end
    end
endmodule