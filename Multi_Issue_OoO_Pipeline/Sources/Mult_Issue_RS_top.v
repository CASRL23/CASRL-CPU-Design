module Multi_Issue_RS_top #(
    parameter RS_SIZE = 128,
    parameter DATA_SIZE = 32,
    parameter TAG_SIZE = 7
)(
    input wire Clk, Reset,

    // ============================================================
    // 1. INPUTS FROM DECODE (To Issue Logic & RS Write Ports)
    // ============================================================
    // Validity bits for the Allocator (Issue Logic)
    input wire IQ_Valid0, IQ_Valid1, IQ_Valid2, IQ_Valid3,

    // Data Payload for Lane 0
    input wire [DATA_SIZE-1:0] Vj_in0, Vk_in0, PC_in0, Mem_offset_in0,
    input wire [4:0]           Instr_type_in0,
    input wire [TAG_SIZE:0]    Rs1_0_tag, Rs2_0_tag, // {Valid, Tag}
    input wire [4:0]           Rd0,        // Destination register
    input wire [4:0]           Rs1_0, Rs2_0,
    input wire                 Has_Rd0,    // Does this instruction write a register?
    input wire                 Pred_take_in0,

    // Data Payload for Lane 1
    input wire [DATA_SIZE-1:0] Vj_in1, Vk_in1, PC_in1, Mem_offset_in1,
    input wire [4:0]           Instr_type_in1,
    input wire [TAG_SIZE:0]    Rs1_1_tag, Rs2_1_tag,
    input wire [4:0]           Rd1,        
    input wire [4:0]           Rs1_1, Rs2_1,
    input wire                 Has_Rd1,    
    input wire                 Pred_take_in1,

    // Data Payload for Lane 2
    input wire [DATA_SIZE-1:0] Vj_in2, Vk_in2, PC_in2, Mem_offset_in2,
    input wire [4:0]           Instr_type_in2,
    input wire [TAG_SIZE:0]    Rs1_2_tag, Rs2_2_tag,
    input wire [4:0]           Rd2,        
    input wire [4:0]           Rs1_2, Rs2_2,
    input wire                 Has_Rd2,    
    input wire                 Pred_take_in2,

    // Data Payload for Lane 3
    input wire [DATA_SIZE-1:0] Vj_in3, Vk_in3, PC_in3, Mem_offset_in3,
    input wire [4:0]           Instr_type_in3,
    input wire [TAG_SIZE:0]    Rs1_3_tag, Rs2_3_tag,
    input wire [4:0]           Rd3,  
    input wire [4:0]           Rs1_3, Rs2_3,          
    input wire                 Has_Rd3,    
    input wire                 Pred_take_in3,

    // ============================================================
    // 2. INPUTS FROM CDB (For RS Wakeup)
    // ============================================================
    input wire [DATA_SIZE-1:0] CDB_result0, CDB_result1, CDB_result2, CDB_result3, CDB_result4,
    input wire [TAG_SIZE-1:0]  CDB_tag0,    CDB_tag1,    CDB_tag2,    CDB_tag3,    CDB_tag4,
    input wire                 CDB_valid0,  CDB_valid1,  CDB_valid2,  CDB_valid3,  CDB_valid4,

    // ============================================================
    // 3. OUTPUTS TO EXECUTE (From RS Read Ports)
    // ============================================================
    // ALU 0 Output
    output wire [DATA_SIZE-1:0] Vj_out0, Vk_out0, PC_out0, Mem_offset_out0,
    output wire [6:0]           ALU_tag0,
    output wire [4:0]           Instr_type_out0, 
    output wire                 Valid_dispatch0,
    output wire                 Pred_taken_out0,

    // ALU 1 Output
    output wire [DATA_SIZE-1:0] Vj_out1, Vk_out1, PC_out1, Mem_offset_out1,
    output wire [6:0]           ALU_tag1,
    output wire [4:0]           Instr_type_out1, 
    output wire                 Valid_dispatch1,
    output wire                 Pred_taken_out1,    

    // ALU 2 Output
    output wire [DATA_SIZE-1:0] Vj_out2, Vk_out2, PC_out2, Mem_offset_out2,
    output wire [6:0]           ALU_tag2,
    output wire [4:0]           Instr_type_out2, 
    output wire                 Valid_dispatch2,
    output wire                 Pred_taken_out2,
    
    // ALU 3 Output
    output wire [DATA_SIZE-1:0] Vj_out3, Vk_out3, PC_out3, Mem_offset_out3,
    output wire [6:0]           ALU_tag3,
    output wire [4:0]           Instr_type_out3, 
    output wire                 Valid_dispatch3,
    output wire                 Pred_taken_out3,

    // Mem Output
    output wire [DATA_SIZE-1:0] Vj_out4, Vk_out4, PC_out4, Mem_offset_out4,
    output wire [6:0]           Mem_tag,
    output wire [4:0]           Instr_type_out4, 
    output wire                 Valid_dispatch4,

    // ============================================================
    // 4. OUTPUTS TO REGISTER FILE (For Renaming)
    // ============================================================
    output wire [4:0]           Rd_out0, Rd_out1, Rd_out2, Rd_out3,
    output wire [TAG_SIZE-1:0]  Rename_Tag0, Rename_Tag1, Rename_Tag2, Rename_Tag3,
    output wire                 Rename_Valid0, Rename_Valid1, Rename_Valid2, Rename_Valid3,

    // ============================================================
    // 5. GLOBAL STATUS
    // ============================================================
    output wire RS_Full
);

    // ============================================================
    // INTERNAL WIRES
    // ============================================================
    
    // --- RS Status Vectors (Feedback Loop) ---
    wire [RS_SIZE-1:0] w_busy_vector;
    wire [RS_SIZE-1:0] w_ready_vector;
    wire [RS_SIZE-1:0] w_is_mem_vector;

    // --- Issue Logic -> RS (Allocation info) ---
    wire [TAG_SIZE-1:0] w_iss_idx0, w_iss_idx1, w_iss_idx2, w_iss_idx3;
    wire                w_iss_en0,  w_iss_en1,  w_iss_en2,  w_iss_en3;

    // --- Issue Logic -> RegFile (Rename info) ---
    wire [4:0]          w_rename_rd0, w_rename_rd1, w_rename_rd2, w_rename_rd3;
    // Note: Rename Tags ARE the Issue Indices (w_iss_idx)
    wire                w_rename_valid0, w_rename_valid1, w_rename_valid2, w_rename_valid3;

    // --- Dispatch Logic -> RS (Selection info) ---
    wire [TAG_SIZE-1:0] w_disp_idx0, w_disp_idx1, w_disp_idx2, w_disp_idx3, w_disp_idx4;
    wire                w_disp_valid0, w_disp_valid1, w_disp_valid2, w_disp_valid3, w_disp_valid4;

    // ============================================================
    // MODULE 1: ISSUE LOGIC (The Allocator)
    // ============================================================
    Multi_Issue_Issue #(
        .RS_SIZE(RS_SIZE), 
        .TAG_SIZE(TAG_SIZE)
    ) ISSUE_LOGIC (
        // Inputs
        .Busy_Vector(w_busy_vector), 
        .IQ_Valid0(IQ_Valid0), .IQ_Valid1(IQ_Valid1), 
        .IQ_Valid2(IQ_Valid2), .IQ_Valid3(IQ_Valid3),
        
        // Destination register info (for renaming)
        .Rd0_rename(Rd0), .Rd1_rename(Rd1), .Rd2_rename(Rd2), .Rd3_rename(Rd3),
        .Rd0_valid(Has_Rd0), .Rd1_valid(Has_Rd1), .Rd2_valid(Has_Rd2), .Rd3_valid(Has_Rd3),
        
        // Outputs (Wired to RS Write Ports)
        .Issue_Index0(w_iss_idx0), .Issue_En0(w_iss_en0),
        .Issue_Index1(w_iss_idx1), .Issue_En1(w_iss_en1),
        .Issue_Index2(w_iss_idx2), .Issue_En2(w_iss_en2),
        .Issue_Index3(w_iss_idx3), .Issue_En3(w_iss_en3),
        
        // Rename outputs (to RegFile)
        .Rd0_valid_out(w_rename_valid0), .Rd_out0(w_rename_rd0),
        .Rd1_valid_out(w_rename_valid1), .Rd_out1(w_rename_rd1),
        .Rd2_valid_out(w_rename_valid2), .Rd_out2(w_rename_rd2),
        .Rd3_valid_out(w_rename_valid3), .Rd_out3(w_rename_rd3),
        
        .RS_Full(RS_Full),
        
        .Rs1_0(Rs1_0), .Rs2_0(Rs2_0),
        .Rs1_1(Rs1_1), .Rs2_1(Rs2_1),
        .Rs1_2(Rs1_2), .Rs2_2(Rs2_2),
        .Rs1_3(Rs1_3), .Rs2_3(Rs2_3),
        
        .Rat_Rs1_0(), .Rat_Rs2_0(),
        .Rat_Rs1_1(), .Rat_Rs2_1(),
        .Rat_Rs1_2(), .Rat_Rs2_2(),
        .Rat_Rs1_3(), .Rat_Rs2_3()
    );

    // ============================================================
    // MODULE 2: RESERVATION STATION (The Container)
    // ============================================================
    Multi_Issue_RS #(
        .RS_SIZE(RS_SIZE), 
        .DATA_SIZE(DATA_SIZE), 
        .TAG_SIZE(TAG_SIZE)
    ) RS_STORAGE (
        .Clk(Clk), .Reset(Reset),
        
        // --- Write Ports (Controlled by Issue Logic) ---
        // Lane 0
        .Vj_in0(Vj_in0), .Vk_in0(Vk_in0), .PC_in0(PC_in0), .Mem_offset_in0(Mem_offset_in0), 
        .Instr_type_in0(Instr_type_in0), .Rs1_0_tag(Rs1_0_tag), .Rs2_0_tag(Rs2_0_tag),
        .Issue_idx0(w_iss_idx0), .Issue_RQ0(w_iss_en0),
        .Pred_take_in0(Pred_take_in0),
        
        // Lane 1
        .Vj_in1(Vj_in1), .Vk_in1(Vk_in1), .PC_in1(PC_in1), .Mem_offset_in1(Mem_offset_in1), 
        .Instr_type_in1(Instr_type_in1), .Rs1_1_tag(Rs1_1_tag), .Rs2_1_tag(Rs2_1_tag),
        .Issue_idx1(w_iss_idx1), .Issue_RQ1(w_iss_en1),
        .Pred_take_in1(Pred_take_in1),

        // Lane 2
        .Vj_in2(Vj_in2), .Vk_in2(Vk_in2), .PC_in2(PC_in2), .Mem_offset_in2(Mem_offset_in2), 
        .Instr_type_in2(Instr_type_in2), .Rs1_2_tag(Rs1_2_tag), .Rs2_2_tag(Rs2_2_tag),
        .Issue_idx2(w_iss_idx2), .Issue_RQ2(w_iss_en2),
        .Pred_take_in2(Pred_take_in2),

        // Lane 3
        .Vj_in3(Vj_in3), .Vk_in3(Vk_in3), .PC_in3(PC_in3), .Mem_offset_in3(Mem_offset_in3), 
        .Instr_type_in3(Instr_type_in3), .Rs1_3_tag(Rs1_3_tag), .Rs2_3_tag(Rs2_3_tag),
        .Issue_idx3(w_iss_idx3), .Issue_RQ3(w_iss_en3),
        .Pred_take_in3(Pred_take_in3),

        // Lane 4 (Issue inputs unused for Mem in 4-wide dispatch, assuming Mem shares Issue ports or logic handles it)
        // If you had 5 issue lanes, you'd add Lane 4 here. Since your Issue logic has 4 lanes, this is correct.

        // --- Read Ports (Controlled by Dispatch Logic) ---
        .Dispatch_0(w_disp_idx0), .Dispatch_valid0(w_disp_valid0),
        .Dispatch_1(w_disp_idx1), .Dispatch_valid1(w_disp_valid1),
        .Dispatch_2(w_disp_idx2), .Dispatch_valid2(w_disp_valid2),
        .Dispatch_3(w_disp_idx3), .Dispatch_valid3(w_disp_valid3),
        .Dispatch_4(w_disp_idx4), .Dispatch_valid4(w_disp_valid4),

        // --- Wakeup Ports (CDB Snooping) ---
        .CDB_result0(CDB_result0), .CDB_tag0(CDB_tag0), .CDB_valid0(CDB_valid0),
        .CDB_result1(CDB_result1), .CDB_tag1(CDB_tag1), .CDB_valid1(CDB_valid1),
        .CDB_result2(CDB_result2), .CDB_tag2(CDB_tag2), .CDB_valid2(CDB_valid2),
        .CDB_result3(CDB_result3), .CDB_tag3(CDB_tag3), .CDB_valid3(CDB_valid3),
        .CDB_result4(CDB_result4), .CDB_tag4(CDB_tag4), .CDB_valid4(CDB_valid4),

        // --- Outputs (Data Payload to Execute) ---
        .Vj_out0(Vj_out0), .Vk_out0(Vk_out0), .PC_out0(PC_out0), .Mem_offset_out0(Mem_offset_out0), .Instr_type_out0(Instr_type_out0),
        .Vj_out1(Vj_out1), .Vk_out1(Vk_out1), .PC_out1(PC_out1), .Mem_offset_out1(Mem_offset_out1), .Instr_type_out1(Instr_type_out1),
        .Vj_out2(Vj_out2), .Vk_out2(Vk_out2), .PC_out2(PC_out2), .Mem_offset_out2(Mem_offset_out2), .Instr_type_out2(Instr_type_out2),
        .Vj_out3(Vj_out3), .Vk_out3(Vk_out3), .PC_out3(PC_out3), .Mem_offset_out3(Mem_offset_out3), .Instr_type_out3(Instr_type_out3),
        .Vj_out4(Vj_out4), .Vk_out4(Vk_out4), .PC_out4(PC_out4), .Mem_offset_out4(Mem_offset_out4), .Instr_type_out4(Instr_type_out4),

        // --- Status Outputs (Feedback) ---
        .Busy_out(w_busy_vector),
        .Ready_out(w_ready_vector),
        .Is_mem_out(w_is_mem_vector),
        
        // --- Prediction values ----
        .Pred_take_out0(Pred_taken_out0),
        .Pred_take_out1(Pred_taken_out1),
        .Pred_take_out2(Pred_taken_out2),
        .Pred_take_out3(Pred_taken_out3)
    );

    // ============================================================
    // MODULE 3: DISPATCH LOGIC (The Scheduler)
    // ============================================================
    Multi_Issue_Dispatch #(
        .RS_SIZE(RS_SIZE)
    ) DISPATCH_LOGIC (
        .Clk(Clk), .Reset(Reset),
        
        // Status Inputs from RS
        .Ready_bits(w_ready_vector),
        .Is_mem(w_is_mem_vector),
        
        // Control Outputs (Wired to RS Read Ports)
        .RS_index0(w_disp_idx0), .Valid_dispatch0(w_disp_valid0),
        .RS_index1(w_disp_idx1), .Valid_dispatch1(w_disp_valid1),
        .RS_index2(w_disp_idx2), .Valid_dispatch2(w_disp_valid2),
        .RS_index3(w_disp_idx3), .Valid_dispatch3(w_disp_valid3),
        .RS_index4(w_disp_idx4), .Valid_dispatch4(w_disp_valid4)
    );

    // ============================================================
    // 4. OUTPUT ASSIGNMENTS (All Combinational)
    // ============================================================
    
    // Dispatch Valid signals to Execute
    assign Valid_dispatch0 = w_disp_valid0;
    assign Valid_dispatch1 = w_disp_valid1;
    assign Valid_dispatch2 = w_disp_valid2;
    assign Valid_dispatch3 = w_disp_valid3;
    assign Valid_dispatch4 = w_disp_valid4;

    // Dispatch Tags to Execute (Used for CDB writeback logic)
    assign ALU_tag0 = w_disp_idx0;
    assign ALU_tag1 = w_disp_idx1;
    assign ALU_tag2 = w_disp_idx2;
    assign ALU_tag3 = w_disp_idx3;
    assign Mem_tag  = w_disp_idx4;
    
    // Rename signals to Register File (COMBINATIONAL - no delay!)
    assign Rd_out0 = w_rename_rd0;
    assign Rename_Tag0 = w_iss_idx0;
    assign Rename_Valid0 = w_rename_valid0;
    
    assign Rd_out1 = w_rename_rd1;
    assign Rename_Tag1 = w_iss_idx1;
    assign Rename_Valid1 = w_rename_valid1;

    assign Rd_out2 = w_rename_rd2;
    assign Rename_Tag2 = w_iss_idx2;
    assign Rename_Valid2 = w_rename_valid2;
    
    assign Rd_out3 = w_rename_rd3;
    assign Rename_Tag3 = w_iss_idx3;
    assign Rename_Valid3 = w_rename_valid3;

endmodule