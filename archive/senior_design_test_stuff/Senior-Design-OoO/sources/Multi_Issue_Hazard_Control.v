`timescale 10ns / 1ps

module Multi_Issue_Hazard_Control(
    input wire Reset,
    // slot 0 (oldest in block)
    input  wire DE_MemRead0, E_branch0, E_pred_taken0, E_valid_branch0,
    input  wire Is_write0, Is_load0,
    input  wire [4:0] DE_Rd0, FD_Rs1_0, FD_Rs2_0, FD_Rd0,

    // slot 1
    input  wire DE_MemRead1, E_branch1, E_pred_taken1, E_valid_branch1,
    input  wire Is_write1, Is_load1,
    input  wire [4:0] DE_Rd1, FD_Rs1_1, FD_Rs2_1, FD_Rd1,

    // slot 2
    input  wire DE_MemRead2, E_branch2, E_pred_taken2, E_valid_branch2,
    input  wire Is_write2, Is_load2,
    input  wire [4:0] DE_Rd2, FD_Rs1_2, FD_Rs2_2, FD_Rd2,

    // slot 3 (youngest in block)
    input  wire DE_MemRead3, E_branch3, E_pred_taken3, E_valid_branch3,
    input  wire Is_write3, Is_load3,
    input  wire [4:0] DE_Rd3, FD_Rs1_3, FD_Rs2_3, FD_Rd3,

    // outputs per slot
    output reg Write0, Stall0, Flush, FD_write,
    output reg Write1, Stall1,
    output reg Write2, Stall2, 
    output reg Write3, Stall3,
    
    // Number of instructions that can issue (0-4)
    output reg [2:0] Num_issued
);

    // ------------------------------------------------------------------
    // helper: test whether Rd conflicts with (Rs1, Rs2)
    // ------------------------------------------------------------------
    function automatic raw_hazard;
        input [4:0] Rd;
        input [4:0] Rs1;
        input [4:0] Rs2;
        begin
            raw_hazard = (Rd != 5'b0) && ((Rd == Rs1) || (Rd == Rs2));
        end
    endfunction

    reg mem_blocked1, mem_blocked2, mem_blocked3;

    always @(DE_MemRead0, E_branch0, E_pred_taken0, E_valid_branch0, Is_write0, Is_load0, DE_Rd0, FD_Rs1_0, FD_Rs2_0, FD_Rd0,
             DE_MemRead1, E_branch1, E_pred_taken1, E_valid_branch1, Is_write1, Is_load1, DE_Rd1, FD_Rs1_1, FD_Rs2_1, FD_Rd1,
             DE_MemRead2, E_branch2, E_pred_taken2, E_valid_branch2, Is_write2, Is_load2, DE_Rd2, FD_Rs1_2, FD_Rs2_2, FD_Rd2,
             DE_MemRead3, E_branch3, E_pred_taken3, E_valid_branch3, Is_write3, Is_load3, DE_Rd3, FD_Rs1_3, FD_Rs2_3)
    begin
        // --- defaults (avoid floating outputs)
        Write0 = 1'b1; Stall0 = 1'b0; Flush = 1'b0; FD_write = 1'b1;
        Write1 = 1'b1; Stall1 = 1'b0;
        Write2 = 1'b1; Stall2 = 1'b0;
        Write3 = 1'b1; Stall3 = 1'b0;

        // --- 1) Branch misprediction flush (highest priority)
        if ((E_valid_branch0 && (E_branch0 != E_pred_taken0)) ||
           (E_valid_branch1 && (E_branch1 != E_pred_taken1)) ||
           (E_valid_branch2 && (E_branch2 != E_pred_taken2)) ||
           (E_valid_branch3 && (E_branch3 != E_pred_taken3))) begin
            Flush = 1'b1;
            FD_write = 1'b1;
        end

        // --- 2) Structural hazard: only one write & only one load per block
        mem_blocked1 = 1'b0; mem_blocked2 = 1'b0; mem_blocked3 = 1'b0;
        if (Is_write0 || Is_load0) begin
            if (Is_write1 || Is_load1) mem_blocked1 = 1'b1;
            if (Is_write2 || Is_load2) mem_blocked2 = 1'b1;
            if (Is_write3 || Is_load3) mem_blocked3 = 1'b1;
        end
        else if (Is_write1 || Is_load1) begin
            if (Is_write2 || Is_load2) mem_blocked2 = 1'b1;
            if (Is_write3 || Is_load3) mem_blocked3 = 1'b1;
        end
        else if (Is_write2 || Is_load2) begin
            if (Is_write3 || Is_load3) mem_blocked3 = 1'b1;
        end

        if (mem_blocked1) begin Write1 = 0; Stall1 = 1; end
        if (mem_blocked2) begin Write2 = 0; Stall2 = 1; end
        if (mem_blocked3) begin Write3 = 0; Stall3 = 1; end
        
        // --- 3) Inter-cycle (DE→FD) load-use RAW hazards
        if (DE_MemRead0) begin
            if (raw_hazard(DE_Rd0, FD_Rs1_0, FD_Rs2_0)) begin Write0 = 0; Stall0 = 1; end
            if (raw_hazard(DE_Rd0, FD_Rs1_1, FD_Rs2_1)) begin Write1 = 0; Stall1 = 1; end
            if (raw_hazard(DE_Rd0, FD_Rs1_2, FD_Rs2_2)) begin Write2 = 0; Stall2 = 1; end
            if (raw_hazard(DE_Rd0, FD_Rs1_3, FD_Rs2_3)) begin Write3 = 0; Stall3 = 1; end
        end
        if (DE_MemRead1) begin
            if (raw_hazard(DE_Rd1, FD_Rs1_0, FD_Rs2_0)) begin Write0 = 0; Stall0 = 1; end
            if (raw_hazard(DE_Rd1, FD_Rs1_1, FD_Rs2_1)) begin Write1 = 0; Stall1 = 1; end
            if (raw_hazard(DE_Rd1, FD_Rs1_2, FD_Rs2_2)) begin Write2 = 0; Stall2 = 1; end
            if (raw_hazard(DE_Rd1, FD_Rs1_3, FD_Rs2_3)) begin Write3 = 0; Stall3 = 1; end
        end
        if (DE_MemRead2) begin
            if (raw_hazard(DE_Rd2, FD_Rs1_0, FD_Rs2_0)) begin Write0 = 0; Stall0 = 1; end
            if (raw_hazard(DE_Rd2, FD_Rs1_1, FD_Rs2_1)) begin Write1 = 0; Stall1 = 1; end
            if (raw_hazard(DE_Rd2, FD_Rs1_2, FD_Rs2_2)) begin Write2 = 0; Stall2 = 1; end
            if (raw_hazard(DE_Rd2, FD_Rs1_3, FD_Rs2_3)) begin Write3 = 0; Stall3 = 1; end
        end
        if (DE_MemRead3) begin
            if (raw_hazard(DE_Rd3, FD_Rs1_0, FD_Rs2_0)) begin Write0 = 0; Stall0 = 1; end
            if (raw_hazard(DE_Rd3, FD_Rs1_1, FD_Rs2_1)) begin Write1 = 0; Stall1 = 1; end
            if (raw_hazard(DE_Rd3, FD_Rs1_2, FD_Rs2_2)) begin Write2 = 0; Stall2 = 1; end
            if (raw_hazard(DE_Rd3, FD_Rs1_3, FD_Rs2_3)) begin Write3 = 0; Stall3 = 1; end
        end

        // --- 4) Intra-block RAW checks (within same fetch group)
        if (raw_hazard(FD_Rd0, FD_Rs1_1, FD_Rs2_1)) begin Write1 = 0; Stall1 = 1; end
        if (raw_hazard(FD_Rd0, FD_Rs1_2, FD_Rs2_2) ||
            raw_hazard(FD_Rd1, FD_Rs1_2, FD_Rs2_2)) begin Write2 = 0; Stall2 = 1; end
        if (raw_hazard(FD_Rd0, FD_Rs1_3, FD_Rs2_3) ||
            raw_hazard(FD_Rd1, FD_Rs1_3, FD_Rs2_3) ||
            raw_hazard(FD_Rd2, FD_Rs1_3, FD_Rs2_3)) begin Write3 = 0; Stall3 = 1; end

        // --- 5) In-order stall propagation
        if (Stall0) begin
            Stall1 = 1; Stall2 = 1; Stall3 = 1;
            Write1 = 0; Write2 = 0; Write3 = 0;
        end
        else if (Stall1) begin
            Stall2 = 1; Stall3 = 1;
            Write2 = 0; Write3 = 0;
        end
        else if (Stall2) begin
            Stall3 = 1;
            Write3 = 0;
        end
        
        // Count how many instructions can actually be written (issued)
        if (Write0 && Write1 && Write2 && Write3)
            Num_issued = 3'd4;  // All 4 issue
        else if (Write0 && Write1 && Write2)
            Num_issued = 3'd3;  // First 3 issue
        else if (Write0 && Write1)
            Num_issued = 3'd2;  // First 2 issue
        else if (Write0)
            Num_issued = 3'd1;  // Only first issues
        else
            Num_issued = 3'd0;  // None issue (full stall)
            
        if (!Flush && Num_issued == 3'd0) begin
            FD_write = 1'b0;  // Don't advance FD pipeline
        end
    end
endmodule
