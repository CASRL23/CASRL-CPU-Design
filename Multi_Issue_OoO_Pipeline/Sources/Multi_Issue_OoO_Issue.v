module Multi_Issue_Issue #(
    parameter RS_SIZE = 128,
    parameter TAG_SIZE = 7
)(
    // Inputs
    input wire [RS_SIZE-1:0] Busy_Vector, // From RS
    input wire               IQ_Valid0, IQ_Valid1, IQ_Valid2, IQ_Valid3, // Instructions waiting
    
    //Inputs from decode on register statuses
    input wire [4:0] Rd0_rename, Rd1_rename, Rd2_rename, Rd3_rename, // Dest Regs
    input wire Rd0_valid, Rd1_valid, Rd2_valid, Rd3_valid,           // Does it write to Reg?
    
    // Source Register Inputs (Need these to check dependencies!)
    // You must add these inputs to your module port list
    input wire [4:0] Rs1_0, Rs2_0,
    input wire [4:0] Rs1_1, Rs2_1,
    input wire [4:0] Rs1_2, Rs2_2,
    input wire [4:0] Rs1_3, Rs2_3,

    // Original Tags from RAT (The "Old" Tags)
    input wire [TAG_SIZE:0] Rat_Rs1_0, Rat_Rs2_0,
    input wire [TAG_SIZE:0] Rat_Rs1_1, Rat_Rs2_1,
    input wire [TAG_SIZE:0] Rat_Rs1_2, Rat_Rs2_2,
    input wire [TAG_SIZE:0] Rat_Rs1_3, Rat_Rs2_3,

    // Outputs to RS (Corrected Tags)
    output reg [TAG_SIZE:0] Rs1_0_out, Rs2_0_out,
    output reg [TAG_SIZE:0] Rs1_1_out, Rs2_1_out,
    output reg [TAG_SIZE:0] Rs1_2_out, Rs2_2_out,
    output reg [TAG_SIZE:0] Rs1_3_out, Rs2_3_out,

    // Standard Outputs
    output reg [TAG_SIZE-1:0] Issue_Index0, Issue_Index1, Issue_Index2, Issue_Index3, 
    output reg                Issue_En0,    Issue_En1,    Issue_En2,    Issue_En3,
    output reg [4:0]          Rd_out0, Rd_out1, Rd_out2, Rd_out3,
    output reg Rd0_valid_out, Rd1_valid_out, Rd2_valid_out, Rd3_valid_out,
    
    // Stall Signal
    output reg                RS_Full 
);

    integer i;
    reg [2:0] free_count; 
    
    // Internal variables to hold the found indices (The New Tags)
    reg [TAG_SIZE-1:0] found_idx0, found_idx1, found_idx2, found_idx3;
    reg has_slot0, has_slot1, has_slot2, has_slot3;

    always @* begin
        // 1. Find Free Slots (Same as before)
        free_count = 0;
        has_slot0=0; has_slot1=0; has_slot2=0; has_slot3=0;
        found_idx0=0; found_idx1=0; found_idx2=0; found_idx3=0;
        
        for (i = 0; i < RS_SIZE; i = i + 1) begin
            if (Busy_Vector[i] == 1'b0) begin 
                if (free_count < 3'd4) begin
                    case (free_count)
                        3'd0: begin found_idx0 = i[TAG_SIZE-1:0]; has_slot0 = 1; end
                        3'd1: begin found_idx1 = i[TAG_SIZE-1:0]; has_slot1 = 1; end
                        3'd2: begin found_idx2 = i[TAG_SIZE-1:0]; has_slot2 = 1; end
                        3'd3: begin found_idx3 = i[TAG_SIZE-1:0]; has_slot3 = 1; end
                    endcase
                    free_count = free_count + 1;
                end
            end
        end

        // 2. Allocation & Forwarding Logic
        // We determine the FINAL tag for each operand.
        // Default: Use the tag from the RAT.
        // Override: If dependency found in current packet, use the newly allocated RS Index.
        // Note: {1'b0, Tag} means "Not Ready / Busy". {1'b1, ...} means Ready.

        // --- Lane 0 (Oldest - No dependencies in packet) ---
        Issue_En0 = IQ_Valid0 && has_slot0;
        Issue_Index0 = found_idx0;
        Rs1_0_out = Rat_Rs1_0;
        Rs2_0_out = Rat_Rs2_0;

        // --- Lane 1 (Can depend on Lane 0) ---
        Issue_En1 = IQ_Valid1 && has_slot1;
        Issue_Index1 = found_idx1;
        
        // Check Rs1 against Rd0
        if (Rd0_valid && Issue_En0 && (Rs1_1 == Rd0_rename) && (Rs1_1 != 0)) 
            Rs1_1_out = {1'b0, found_idx0}; // Forward Tag 0
        else 
            Rs1_1_out = Rat_Rs1_1;          // Use RAT Tag

        // Check Rs2 against Rd0
        if (Rd0_valid && Issue_En0 && (Rs2_1 == Rd0_rename) && (Rs2_1 != 0)) 
            Rs2_1_out = {1'b0, found_idx0};
        else 
            Rs2_1_out = Rat_Rs2_1;

        // --- Lane 2 (Can depend on Lane 1 OR Lane 0) ---
        Issue_En2 = IQ_Valid2 && has_slot2;
        Issue_Index2 = found_idx2;
        
        // Check Rs1 against Rd1 then Rd0 (Youngest priority)
        if (Rd1_valid && Issue_En1 && (Rs1_2 == Rd1_rename) && (Rs1_2 != 0))
            Rs1_2_out = {1'b0, found_idx1}; // Forward Tag 1
        else if (Rd0_valid && Issue_En0 && (Rs1_2 == Rd0_rename) && (Rs1_2 != 0))
            Rs1_2_out = {1'b0, found_idx0}; // Forward Tag 0
        else
            Rs1_2_out = Rat_Rs1_2;
            
        // Check Rs2 against Rd1 then Rd0
        if (Rd1_valid && Issue_En1 && (Rs2_2 == Rd1_rename) && (Rs2_2 != 0))
            Rs2_2_out = {1'b0, found_idx1};
        else if (Rd0_valid && Issue_En0 && (Rs2_2 == Rd0_rename) && (Rs2_2 != 0))
            Rs2_2_out = {1'b0, found_idx0};
        else
            Rs2_2_out = Rat_Rs2_2;

        // --- Lane 3 (Can depend on 2, 1, or 0) ---
        Issue_En3 = IQ_Valid3 && has_slot3;
        Issue_Index3 = found_idx3;
        
        // Check Rs1
        if (Rd2_valid && Issue_En2 && (Rs1_3 == Rd2_rename) && (Rs1_3 != 0))
            Rs1_3_out = {1'b0, found_idx2};
        else if (Rd1_valid && Issue_En1 && (Rs1_3 == Rd1_rename) && (Rs1_3 != 0))
            Rs1_3_out = {1'b0, found_idx1};
        else if (Rd0_valid && Issue_En0 && (Rs1_3 == Rd0_rename) && (Rs1_3 != 0))
            Rs1_3_out = {1'b0, found_idx0};
        else
            Rs1_3_out = Rat_Rs1_3;
            
        // Check Rs2
        if (Rd2_valid && Issue_En2 && (Rs2_3 == Rd2_rename) && (Rs2_3 != 0))
            Rs2_3_out = {1'b0, found_idx2};
        else if (Rd1_valid && Issue_En1 && (Rs2_3 == Rd1_rename) && (Rs2_3 != 0))
            Rs2_3_out = {1'b0, found_idx1};
        else if (Rd0_valid && Issue_En0 && (Rs2_3 == Rd0_rename) && (Rs2_3 != 0))
            Rs2_3_out = {1'b0, found_idx0};
        else
            Rs2_3_out = Rat_Rs2_3;


        // Stall Logic (RS_Full)
        RS_Full = (IQ_Valid0 && !has_slot0) || 
                  (IQ_Valid1 && !has_slot1) ||
                  (IQ_Valid2 && !has_slot2) ||
                  (IQ_Valid3 && !has_slot3);
                  
        // Rename Logic (For RAT Update)
        Rd_out0 = Rd0_rename; 
        Rd_out1 = Rd1_rename; 
        Rd_out2 = Rd2_rename; 
        Rd_out3 = Rd3_rename;
        
        Rd0_valid_out = Rd0_valid && Issue_En0; 
        Rd1_valid_out = Rd1_valid && Issue_En1;
        Rd2_valid_out = Rd2_valid && Issue_En2; 
        Rd3_valid_out = Rd3_valid && Issue_En3;
    end

endmodule