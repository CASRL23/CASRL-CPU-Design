module Tomasulos_Multi_Issue_HDU(
    input wire Clk, Reset,
    
    // ------------------------------------------------------------
    // 1. Status Inputs
    // ------------------------------------------------------------
    input wire RS_full, 
    input wire IQ_full, 
    input wire D_cache_miss, // Optional: Can be used to stall Issue if needed
    
    // ------------------------------------------------------------
    // 2. Branch Detection Inputs (From Decode/IQ)
    // ------------------------------------------------------------
    // Bitmask: Which lanes contain Branch Opcodes?
    input wire [3:0] Branch_decode,    
    // Bitmask: Which lanes actually contain valid instructions?
    input wire [3:0] Branch_valid,     
    
    // ------------------------------------------------------------
    // 3. Resolution Inputs (From Execute/CDB)
    // ------------------------------------------------------------
    input wire Branch_resolve,         // Pulse: A branch just finished executing
    input wire Branch_mispredict,      // Pulse: The branch result was wrong
    input wire [31:0] Branch_correction, // (Pass-through if needed)
    
    // ------------------------------------------------------------
    // 4. Outputs
    // ------------------------------------------------------------
    output reg Stall_fetch, 
    output reg Stall_Decode, 
    output reg Flush,
    
    // Bitmask to AND with Issue Valid bits. 
    // 1 = Allow Issue, 0 = Kill/Stall this lane
    output reg [3:0] Issue_Mask 
);

    // ============================================================
    // Internal State: Branch Pending Flag
    // ============================================================
    // This acts as a "Traffic Light". 
    // 0 = Green (Flow), 1 = Red (Stop until Branch Resolves)
    reg branch_pending;
    
    // Helper: Is there a valid branch in the current packet?
    wire any_branch_decoding;
    assign any_branch_decoding = (Branch_decode[0] & Branch_valid[0]) |
                                 (Branch_decode[1] & Branch_valid[1]) |
                                 (Branch_decode[2] & Branch_valid[2]) |
                                 (Branch_decode[3] & Branch_valid[3]);

    always @(posedge Clk) begin
        if (Reset || Branch_mispredict) begin
            // On Reset or Flush, clear the lock
            branch_pending <= 1'b0;
        end
        else begin
            // 1. LOCK: If valid branch seen in current packet
            // We check !Stall_Decode so we don't re-trigger on the same 
            // instruction if the pipeline is stalled for other reasons (RS Full).
            if (any_branch_decoding && !Stall_Decode && !branch_pending) begin
                branch_pending <= 1'b1;
            end
            
            // 2. UNLOCK: If branch resolves (CDB broadcast)
            // This happens when the branch finishes execution.
            else if (Branch_resolve) begin
                branch_pending <= 1'b0;
            end
        end
    end

    // ============================================================
    // Combinational Logic: Kill Mask (Intra-Cycle Stall)
    // ============================================================
    // This logic enforces program order WITHIN the packet.
    // If Lane 1 is a branch, Lanes 2 and 3 must be killed.
    always @* begin
        // Default: Allow everyone
        Issue_Mask = 4'b1111;

        // Priority 1: Global Stalls
        // If RS is full or we are already waiting on an older branch, nothing moves.
        if (RS_full || branch_pending) begin
            Issue_Mask = 4'b0000;
        end
        else begin
            // Priority 2: Branch Shadowing
            // Find the FIRST valid branch and kill everything after it.
            
            if (Branch_decode[0] && Branch_valid[0]) begin
                Issue_Mask = 4'b0001; // Keep Lane 0, Kill 1, 2, 3
            end
            else if (Branch_decode[1] && Branch_valid[1]) begin
                Issue_Mask = 4'b0011; // Keep 0, 1, Kill 2, 3
            end
            else if (Branch_decode[2] && Branch_valid[2]) begin
                Issue_Mask = 4'b0111; // Keep 0, 1, 2, Kill 3
            end
            else if (Branch_decode[3] && Branch_valid[3]) begin
                Issue_Mask = 4'b1111; // Branch is last, keep all
            end
        end
    end

    // ============================================================
    // Combinational Logic: Global Stalls & Flushes
    // ============================================================
    always @* begin
        // Defaults
        Stall_fetch  = 1'b0;
        Stall_Decode = 1'b0;
        Flush        = 1'b0;

        // --- 1. Flush Logic (Highest Priority) ---
        if (Branch_mispredict) begin
            Flush = 1'b1;
            // Flushes override stalls. We want to clear the pipe immediately.
        end
        else begin
            // --- 2. Decode/Issue Stall Logic ---
            // We stall Decode/Issue if:
            // A. RS is Full.
            // B. We are waiting for an OLDER branch (branch_pending).
            
            if (RS_full || branch_pending) begin
                Stall_Decode = 1'b1;
            end

            // --- 3. Fetch Stall Logic ---
            // We stall Fetch if:
            // A. IQ is Full.
            // B. Decode is Stalled (Backpressure).
            // C. We see a NEW branch right now (any_branch_decoding).
            //    Stopping Fetch immediately prevents filling the IQ with 
            //    speculative instructions that we might just flush anyway.
            
            if (IQ_full || Stall_Decode || any_branch_decoding) begin
                Stall_fetch = 1'b1;
            end
        end
    end

endmodule