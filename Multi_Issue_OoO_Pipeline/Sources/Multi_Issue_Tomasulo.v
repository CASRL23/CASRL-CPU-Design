module Multi_Issue_Tomasulo(
    input wire Clk, Reset,
    input wire Flush, Stall, 

    // ---------------------------------------------------------
    // 1. Inputs from Instruction Queue (Fetch Stage)
    // ---------------------------------------------------------
    // 4 instructions: {Pred[1], PC[32], Instr[32]} * 4
    input wire [259:0] IQD_in,
    
    // Valid bits from IQ
    input wire IQ_Valid0, IQ_Valid1, IQ_Valid2, IQ_Valid3,

    // ---------------------------------------------------------
    // 2. Global Outputs
    // ---------------------------------------------------------
    output wire Stall_Fetch, // To Fetch Unit
//    output wire RS_Full,     // Status
    

    
    // Branch Recovery (To Fetch Unit)
    output wire Mispredict0, Mispredict1, Mispredict2, Mispredict3, Mispredict4,
    output wire [31:0] Branch_target0, Branch_target1, Branch_target2, Branch_target3, Branch_target4
);

    // =========================================================================
    // INTERNAL WIRES
    // =========================================================================

    // --- 1. Decode -> DI Pipeline Register ---
    wire [31:0] dec_vj0, dec_vk0, dec_imm0, dec_pc0; wire [4:0] dec_op0, dec_in_rs1_0, dec_in_rs2_0,dec_rd0; wire [7:0] dec_rs1_tag0, dec_rs2_tag0; wire dec_valid0, dec_pred0, dec_has_rd0;
    wire [31:0] dec_vj1, dec_vk1, dec_imm1, dec_pc1; wire [4:0] dec_op1, dec_in_rs1_1, dec_in_rs2_1,dec_rd1; wire [7:0] dec_rs1_tag1, dec_rs2_tag1; wire dec_valid1, dec_pred1, dec_has_rd1;
    wire [31:0] dec_vj2, dec_vk2, dec_imm2, dec_pc2; wire [4:0] dec_op2, dec_in_rs1_2, dec_in_rs2_2,dec_rd2; wire [7:0] dec_rs1_tag2, dec_rs2_tag2; wire dec_valid2, dec_pred2, dec_has_rd2;
    wire [31:0] dec_vj3, dec_vk3, dec_imm3, dec_pc3; wire [4:0] dec_op3, dec_in_rs1_3, dec_in_rs2_3,dec_rd3; wire [7:0] dec_rs1_tag3, dec_rs2_tag3; wire dec_valid3, dec_pred3, dec_has_rd3;
    
    wire w_stall_decode, w_stall_fetch, w_flush_internal;
    wire [3:0] w_hdu_mask;

    // --- 2. DI Pipeline Register -> RS Subsystem (Issue) ---
    wire [31:0] rs_in_vj0, rs_in_vk0, rs_in_imm0, rs_in_pc0; wire [4:0] rs_in_op0, rs_in_rs1_0, rs_in_rs2_0,rs_in_rd0; wire [7:0] rs_in_rs1_tag0, rs_in_rs2_tag0; wire rs_in_valid0, rs_in_pred0, rs_in_has_rd0;
    wire [31:0] rs_in_vj1, rs_in_vk1, rs_in_imm1, rs_in_pc1; wire [4:0] rs_in_op1, rs_in_rs1_1, rs_in_rs2_1,rs_in_rd1; wire [7:0] rs_in_rs1_tag1, rs_in_rs2_tag1; wire rs_in_valid1, rs_in_pred1, rs_in_has_rd1;
    wire [31:0] rs_in_vj2, rs_in_vk2, rs_in_imm2, rs_in_pc2; wire [4:0] rs_in_op2, rs_in_rs1_2, rs_in_rs2_2,rs_in_rd2; wire [7:0] rs_in_rs1_tag2, rs_in_rs2_tag2; wire rs_in_valid2, rs_in_pred2, rs_in_has_rd2;
    wire [31:0] rs_in_vj3, rs_in_vk3, rs_in_imm3, rs_in_pc3; wire [4:0] rs_in_op3, rs_in_rs1_3, rs_in_rs2_3,rs_in_rd3; wire [7:0] rs_in_rs1_tag3, rs_in_rs2_tag3; wire rs_in_valid3, rs_in_pred3, rs_in_has_rd3;

    // --- 3. RS Subsystem -> DE Pipeline Register (Dispatch Payloads) ---
    wire [31:0] rs_out_vj0, rs_out_vk0, rs_out_pc0, rs_out_imm0; wire [4:0] rs_out_op0; wire [6:0] rs_out_tag0; wire rs_out_valid0, rs_out_pred0;
    wire [31:0] rs_out_vj1, rs_out_vk1, rs_out_pc1, rs_out_imm1; wire [4:0] rs_out_op1; wire [6:0] rs_out_tag1; wire rs_out_valid1, rs_out_pred1;
    wire [31:0] rs_out_vj2, rs_out_vk2, rs_out_pc2, rs_out_imm2; wire [4:0] rs_out_op2; wire [6:0] rs_out_tag2; wire rs_out_valid2, rs_out_pred2;
    wire [31:0] rs_out_vj3, rs_out_vk3, rs_out_pc3, rs_out_imm3; wire [4:0] rs_out_op3; wire [6:0] rs_out_tag3; wire rs_out_valid3, rs_out_pred3;
    wire [31:0] rs_out_vj4, rs_out_vk4, rs_out_pc4, rs_out_imm4; wire [4:0] rs_out_op4; wire [6:0] rs_out_tag4; wire rs_out_valid4, rs_out_pred4;

    // --- Feedback: Rename Info (Issue -> Decode) ---
    wire [4:0]  fb_rn_rd0, fb_rn_rd1, fb_rn_rd2, fb_rn_rd3, fb_rn_rd4;
    wire [6:0]  fb_rn_tag0, fb_rn_tag1, fb_rn_tag2, fb_rn_tag3, fb_rn_tag4;
    wire        fb_rn_v0, fb_rn_v1, fb_rn_v2, fb_rn_v3, fb_rn_v4;

    // --- 4. DE Pipeline Register -> Execute (Operands) ---
    wire [31:0] de_vj0, de_vk0, de_pc0, de_imm0; wire [4:0] de_op0; wire [6:0] de_tag0; wire de_valid0, de_pred0;
    wire [31:0] de_vj1, de_vk1, de_pc1, de_imm1; wire [4:0] de_op1; wire [6:0] de_tag1; wire de_valid1, de_pred1;
    wire [31:0] de_vj2, de_vk2, de_pc2, de_imm2; wire [4:0] de_op2; wire [6:0] de_tag2; wire de_valid2, de_pred2;
    wire [31:0] de_vj3, de_vk3, de_pc3, de_imm3; wire [4:0] de_op3; wire [6:0] de_tag3; wire de_valid3, de_pred3;
    wire [31:0] de_vj4, de_vk4, de_pc4, de_imm4; wire [4:0] de_op4; wire [6:0] de_tag4; wire de_valid4, de_pred4;

    // --- 5. Execute Outputs ---
    // ALU Results (To CDB)
    wire [31:0] exec_res0, exec_res1, exec_res2, exec_res3;
    wire [6:0]  exec_tag0, exec_tag1, exec_tag2, exec_tag3;
    wire        exec_val0, exec_val1, exec_val2, exec_val3;
    
    // Memory Request (To Pipeline Reg)
    wire [31:0] exec_mem_addr, exec_mem_data;
    wire [2:0]  exec_mem_type;
    wire [6:0]  exec_mem_tag;
    wire        exec_mem_valid;

    // --- 6. Pipeline Register -> Memory Stage ---
    wire [31:0] mem_stage_addr, mem_stage_data;
    wire [2:0]  mem_stage_type; // 3-bit type
    wire [6:0]  mem_stage_tag;
    wire        mem_stage_valid;

    // --- 7. Memory -> CDB ---
    wire [31:0] mem_res;
    wire [6:0]  mem_res_tag;
    wire        mem_res_valid;
    wire        mem_busy_sig;
    
    
    // --- 8. CDB  wires
    wire [31:0] CDB_res0, CDB_res1, CDB_res2, CDB_res3, CDB_res4;
    wire [6:0] CDB_tag_out0, CDB_tag_out1, CDB_tag_out2, CDB_tag_out3, CDB_tag_out4;
    wire CDB_valid0, CDB_valid1, CDB_valid2, CDB_valid3, CDB_valid4; 

    // Combine Flushes
    // If any stage mispredicts, flush everything.
    wire Global_Flush = Flush || Mispredict0 || Mispredict1 || Mispredict2 || Mispredict3 || Mispredict4;

    // =========================================================================
    // MODULE 1: DECODE STAGE
    // =========================================================================
    Decode DECODE (
        .Clk(Clk), .Reset(Reset),
        .IQD_in(IQD_in),
        
        // IQ Valid Inputs
        .Valid_in0(IQ_Valid0), .Valid_in1(IQ_Valid1), .Valid_in2(IQ_Valid2), .Valid_in3(IQ_Valid3),
        
        // CDB Inputs (Writeback to RegFile)
        .CDB_data0(CDB_res0), .CDB_tag0(CDB_tag_out0), .CDB_valid0(CDB_valid0),
        .CDB_data1(CDB_res1), .CDB_tag1(CDB_tag_out1), .CDB_valid1(CDB_valid1),
        .CDB_data2(CDB_res2), .CDB_tag2(CDB_tag_out2), .CDB_valid2(CDB_valid2),
        .CDB_data3(CDB_res3), .CDB_tag3(CDB_tag_out3), .CDB_valid3(CDB_valid3),
        .CDB_data4(CDB_res4), .CDB_tag4(CDB_tag_out4), .CDB_valid4(CDB_valid4),
        
        // RAT Rename Updates (From Issue Stage)
        // Note: Only lanes 0-3 usually rename. Lane 4 (Mem) logic in Issue handles passing if needed.
        .RAT_we0(fb_rn_v0), .RAT_rd0(fb_rn_rd0), .RAT_tag0(fb_rn_tag0),
        .RAT_we1(fb_rn_v1), .RAT_rd1(fb_rn_rd1), .RAT_tag1(fb_rn_tag1),
        .RAT_we2(fb_rn_v2), .RAT_rd2(fb_rn_rd2), .RAT_tag2(fb_rn_tag2),
        .RAT_we3(fb_rn_v3), .RAT_rd3(fb_rn_rd3), .RAT_tag3(fb_rn_tag3),
        
        // Control
        .RS_full(RS_Full), .IQ_full(1'b0), .D_cache_miss(1'b0),
        .Branch_misprediction(Global_Flush), .Branch_resolve(1'b0), .Branch_correction(32'd0),
        
        // Outputs
        .Stall_Decode(w_stall_decode), .Stall_Fetch(Stall_Fetch), .Flush(w_flush_internal),
        .hdu_issue_mask(w_hdu_mask),
        
        // Decoded Packets (To DI Regs)
        .Vj_out0(dec_vj0), .Vk_out0(dec_vk0), .Imm_out0(dec_imm0), .PC_out0(dec_pc0), .I_type_out0(dec_op0), .Rd_out0(dec_rd0), .Rs1_tag_out0(dec_rs1_tag0), .Rs2_tag_out0(dec_rs2_tag0), .IQ_Valid_out0(dec_valid0), .Pred_take_out0(dec_pred0), .Has_Rd_out0(dec_has_rd0),
        .Vj_out1(dec_vj1), .Vk_out1(dec_vk1), .Imm_out1(dec_imm1), .PC_out1(dec_pc1), .I_type_out1(dec_op1), .Rd_out1(dec_rd1), .Rs1_tag_out1(dec_rs1_tag1), .Rs2_tag_out1(dec_rs2_tag1), .IQ_Valid_out1(dec_valid1), .Pred_take_out1(dec_pred1), .Has_Rd_out1(dec_has_rd1),
        .Vj_out2(dec_vj2), .Vk_out2(dec_vk2), .Imm_out2(dec_imm2), .PC_out2(dec_pc2), .I_type_out2(dec_op2), .Rd_out2(dec_rd2), .Rs1_tag_out2(dec_rs1_tag2), .Rs2_tag_out2(dec_rs2_tag2), .IQ_Valid_out2(dec_valid2), .Pred_take_out2(dec_pred2), .Has_Rd_out2(dec_has_rd2),
        .Vj_out3(dec_vj3), .Vk_out3(dec_vk3), .Imm_out3(dec_imm3), .PC_out3(dec_pc3), .I_type_out3(dec_op3), .Rd_out3(dec_rd3), .Rs1_tag_out3(dec_rs1_tag3), .Rs2_tag_out3(dec_rs2_tag3), .IQ_Valid_out3(dec_valid3), .Pred_take_out3(dec_pred3), .Has_Rd_out3(dec_has_rd3),
        // Output 'RsX_valid_out' not strictly needed if 'RsX_tag_out' contains the valid bit in MSB.
    
        .Rs1_0(dec_in_rs1_0), .Rs2_0(dec_in_rs2_0), .Rs1_1(dec_in_rs1_1), .Rs2_1(dec_in_rs2_1), 
        .Rs1_2(dec_in_rs1_2), .Rs2_2(dec_in_rs2_2), .Rs1_3(dec_in_rs1_3), .Rs2_3(dec_in_rs2_3)
    );

    // =========================================================================
    // 2. DECODE -> ISSUE PIPELINE REGISTERS (DI Regs)
    // =========================================================================
    wire stall_pipeline = w_stall_decode; // Stalls prevent new data entering RS

    DI_pipeline_reg DI0(.Clk(Clk), .Reset(Reset), .Stall(stall_pipeline), .Flush(Global_Flush),
        .Vj_in(dec_vj0), .Vk_in(dec_vk0), .Mem_offset_in(dec_imm0), .Instr_type_in(dec_op0), .PC_in(dec_pc0), .Rd_id_in(dec_rd0), .Has_Rd_in(dec_has_rd0), .Pred_take_in(dec_pred0),
        .Rs1_tag_in(dec_rs1_tag0[6:0]), .Rs2_tag_in(dec_rs2_tag0[6:0]), .Rs1_valid_in(dec_rs1_tag0[7]), .Rs2_valid_in(dec_rs2_tag0[7]), .Valid_issue_in(dec_valid0),
        .Rs1_in(dec_in_rs1_0), .Rs2_in(dec_in_rs2_0),
        // Outputs
        .Vj_out(rs_in_vj0), .Vk_out(rs_in_vk0), .Mem_offset_out(rs_in_imm0), .Instr_type_out(rs_in_op0), .PC_out(rs_in_pc0), .Rd_id_out(rs_in_rd0), .Has_Rd_out(rs_in_has_rd0), .Pred_take_out(rs_in_pred0),
        .Rs1_tag_out(rs_in_rs1_tag0[6:0]), .Rs2_tag_out(rs_in_rs2_tag0[6:0]), .Rs1_valid_out(rs_in_rs1_tag0[7]), .Rs2_valid_out(rs_in_rs2_tag0[7]), .Valid_issue_out(rs_in_valid0),
        .Rs1_out(rs_in_rs1_0), .Rs2_out(rs_in_rs2_0)
    );

    DI_pipeline_reg DI1(.Clk(Clk), .Reset(Reset), .Stall(stall_pipeline), .Flush(Global_Flush),
        .Vj_in(dec_vj1), .Vk_in(dec_vk1), .Mem_offset_in(dec_imm1), .Instr_type_in(dec_op1), .PC_in(dec_pc1), .Rd_id_in(dec_rd1), .Has_Rd_in(dec_has_rd1), .Pred_take_in(dec_pred1),
        .Rs1_tag_in(dec_rs1_tag1[6:0]), .Rs2_tag_in(dec_rs2_tag1[6:0]), .Rs1_valid_in(dec_rs1_tag1[7]), .Rs2_valid_in(dec_rs2_tag1[7]), .Valid_issue_in(dec_valid1),
        .Rs1_in(dec_in_rs1_1), .Rs2_in(dec_in_rs2_1),
        
        .Vj_out(rs_in_vj1), .Vk_out(rs_in_vk1), .Mem_offset_out(rs_in_imm1), .Instr_type_out(rs_in_op1), .PC_out(rs_in_pc1), .Rd_id_out(rs_in_rd1), .Has_Rd_out(rs_in_has_rd1), .Pred_take_out(rs_in_pred1),
        .Rs1_tag_out(rs_in_rs1_tag1[6:0]), .Rs2_tag_out(rs_in_rs2_tag1[6:0]), .Rs1_valid_out(rs_in_rs1_tag1[7]), .Rs2_valid_out(rs_in_rs2_tag1[7]), .Valid_issue_out(rs_in_valid1),
        .Rs1_out(rs_in_rs1_1), .Rs2_out(rs_in_rs2_1)
    );

    DI_pipeline_reg DI2(.Clk(Clk), .Reset(Reset), .Stall(stall_pipeline), .Flush(Global_Flush),
        .Vj_in(dec_vj2), .Vk_in(dec_vk2), .Mem_offset_in(dec_imm2), .Instr_type_in(dec_op2), .PC_in(dec_pc2), .Rd_id_in(dec_rd2), .Has_Rd_in(dec_has_rd2), .Pred_take_in(dec_pred2),
        .Rs1_tag_in(dec_rs1_tag2[6:0]), .Rs2_tag_in(dec_rs2_tag2[6:0]), .Rs1_valid_in(dec_rs1_tag2[7]), .Rs2_valid_in(dec_rs2_tag2[7]), .Valid_issue_in(dec_valid2),
        .Rs1_in(dec_in_rs1_2), .Rs2_in(dec_in_rs2_2),
        
        .Vj_out(rs_in_vj2), .Vk_out(rs_in_vk2), .Mem_offset_out(rs_in_imm2), .Instr_type_out(rs_in_op2), .PC_out(rs_in_pc2), .Rd_id_out(rs_in_rd2), .Has_Rd_out(rs_in_has_rd2), .Pred_take_out(rs_in_pred2),
        .Rs1_tag_out(rs_in_rs1_tag2[6:0]), .Rs2_tag_out(rs_in_rs2_tag2[6:0]), .Rs1_valid_out(rs_in_rs1_tag2[7]), .Rs2_valid_out(rs_in_rs2_tag2[7]), .Valid_issue_out(rs_in_valid2),
        .Rs1_out(rs_in_rs1_2), .Rs2_out(rs_in_rs2_2)
    );

    DI_pipeline_reg DI3(.Clk(Clk), .Reset(Reset), .Stall(stall_pipeline), .Flush(Global_Flush),
        .Vj_in(dec_vj3), .Vk_in(dec_vk3), .Mem_offset_in(dec_imm3), .Instr_type_in(dec_op3), .PC_in(dec_pc3), .Rd_id_in(dec_rd3), .Has_Rd_in(dec_has_rd3), .Pred_take_in(dec_pred3),
        .Rs1_tag_in(dec_rs1_tag3[6:0]), .Rs2_tag_in(dec_rs2_tag3[6:0]), .Rs1_valid_in(dec_rs1_tag3[7]), .Rs2_valid_in(dec_rs2_tag3[7]), .Valid_issue_in(dec_valid3),
        .Rs1_in(dec_in_rs1_3), .Rs2_in(dec_in_rs2_3),
        
        .Vj_out(rs_in_vj3), .Vk_out(rs_in_vk3), .Mem_offset_out(rs_in_imm3), .Instr_type_out(rs_in_op3), .PC_out(rs_in_pc3), .Rd_id_out(rs_in_rd3), .Has_Rd_out(rs_in_has_rd3), .Pred_take_out(rs_in_pred3),
        .Rs1_tag_out(rs_in_rs1_tag3[6:0]), .Rs2_tag_out(rs_in_rs2_tag3[6:0]), .Rs1_valid_out(rs_in_rs1_tag3[7]), .Rs2_valid_out(rs_in_rs2_tag3[7]), .Valid_issue_out(rs_in_valid3),
        .Rs1_out(rs_in_rs1_3), .Rs2_out(rs_in_rs2_3)
   
    );

    // =========================================================================
    // 3. RS INTEGRATED SUBSYSTEM
    // =========================================================================
    Multi_Issue_RS_top #(
        .RS_SIZE(128), .DATA_SIZE(32), .TAG_SIZE(7)
    ) RS_UNIT (
        .Clk(Clk), .Reset(Reset),
        
        // Issue Inputs (From DI Regs)
        // Lane 0
        .IQ_Valid0(rs_in_valid0), .Vj_in0(rs_in_vj0), .Vk_in0(rs_in_vk0), .PC_in0(rs_in_pc0), 
        .Mem_offset_in0(rs_in_imm0), .Instr_type_in0(rs_in_op0), .Rd0(rs_in_rd0), .Has_Rd0(rs_in_has_rd0), .Pred_take_in0(rs_in_pred0),
        .Rs1_0_tag(rs_in_rs1_tag0), .Rs2_0_tag(rs_in_rs2_tag0),
        
        // Lane 1
        .IQ_Valid1(rs_in_valid1), .Vj_in1(rs_in_vj1), .Vk_in1(rs_in_vk1), .PC_in1(rs_in_pc1), 
        .Mem_offset_in1(rs_in_imm1), .Instr_type_in1(rs_in_op1), .Rd1(rs_in_rd1), .Has_Rd1(rs_in_has_rd1), .Pred_take_in1(rs_in_pred1),
        .Rs1_1_tag(rs_in_rs1_tag1), .Rs2_1_tag(rs_in_rs2_tag1),

        // Lane 2
        .IQ_Valid2(rs_in_valid2), .Vj_in2(rs_in_vj2), .Vk_in2(rs_in_vk2), .PC_in2(rs_in_pc2), 
        .Mem_offset_in2(rs_in_imm2), .Instr_type_in2(rs_in_op2), .Rd2(rs_in_rd2), .Has_Rd2(rs_in_has_rd2), .Pred_take_in2(rs_in_pred2),
        .Rs1_2_tag(rs_in_rs1_tag2), .Rs2_2_tag(rs_in_rs2_tag2),

        // Lane 3
        .IQ_Valid3(rs_in_valid3), .Vj_in3(rs_in_vj3), .Vk_in3(rs_in_vk3), .PC_in3(rs_in_pc3), 
        .Mem_offset_in3(rs_in_imm3), .Instr_type_in3(rs_in_op3), .Rd3(rs_in_rd3), .Has_Rd3(rs_in_has_rd3), .Pred_take_in3(rs_in_pred3),
        .Rs1_3_tag(rs_in_rs1_tag3), .Rs2_3_tag(rs_in_rs2_tag3),

        // CDB Inputs (For Wakeup)
        .CDB_result0(CDB_res0), .CDB_tag0(CDB_tag_out0), .CDB_valid0(CDB_valid0),
        .CDB_result1(CDB_res1), .CDB_tag1(CDB_tag_out1), .CDB_valid1(CDB_valid1),
        .CDB_result2(CDB_res2), .CDB_tag2(CDB_tag_out2), .CDB_valid2(CDB_valid2),
        .CDB_result3(CDB_res3), .CDB_tag3(CDB_tag_out3), .CDB_valid3(CDB_valid3),
        .CDB_result4(CDB_res4), .CDB_tag4(CDB_tag_out4), .CDB_valid4(CDB_valid4),

        // Dispatch Outputs (To DE Regs)
        .Vj_out0(rs_out_vj0), .Vk_out0(rs_out_vk0), .PC_out0(rs_out_pc0), .Mem_offset_out0(rs_out_imm0), .Instr_type_out0(rs_out_op0), .ALU_tag0(rs_out_tag0), .Valid_dispatch0(rs_out_valid0), .Pred_taken_out0(rs_out_pred0),
        .Vj_out1(rs_out_vj1), .Vk_out1(rs_out_vk1), .PC_out1(rs_out_pc1), .Mem_offset_out1(rs_out_imm1), .Instr_type_out1(rs_out_op1), .ALU_tag1(rs_out_tag1), .Valid_dispatch1(rs_out_valid1), .Pred_taken_out1(rs_out_pred1),
        .Vj_out2(rs_out_vj2), .Vk_out2(rs_out_vk2), .PC_out2(rs_out_pc2), .Mem_offset_out2(rs_out_imm2), .Instr_type_out2(rs_out_op2), .ALU_tag2(rs_out_tag2), .Valid_dispatch2(rs_out_valid2), .Pred_taken_out2(rs_out_pred2),
        .Vj_out3(rs_out_vj3), .Vk_out3(rs_out_vk3), .PC_out3(rs_out_pc3), .Mem_offset_out3(rs_out_imm3), .Instr_type_out3(rs_out_op3), .ALU_tag3(rs_out_tag3), .Valid_dispatch3(rs_out_valid3), .Pred_taken_out3(rs_out_pred3),
        .Vj_out4(rs_out_vj4), .Vk_out4(rs_out_vk4), .PC_out4(rs_out_pc4), .Mem_offset_out4(rs_out_imm4), .Instr_type_out4(rs_out_op4), .Mem_tag(rs_out_tag4), .Valid_dispatch4(rs_out_valid4), 
 
        // Rename Outputs (Feedback to Decode)
        .Rd_out0(fb_rn_rd0), .Rename_Tag0(fb_rn_tag0), .Rename_Valid0(fb_rn_v0),
        .Rd_out1(fb_rn_rd1), .Rename_Tag1(fb_rn_tag1), .Rename_Valid1(fb_rn_v1),
        .Rd_out2(fb_rn_rd2), .Rename_Tag2(fb_rn_tag2), .Rename_Valid2(fb_rn_v2),
        .Rd_out3(fb_rn_rd3), .Rename_Tag3(fb_rn_tag3), .Rename_Valid3(fb_rn_v3),

        
        .RS_Full(RS_Full),
        
        .Rs1_0(rs_in_rs1_0), .Rs2_0(rs_in_rs2_0), .Rs1_1(rs_in_rs1_1), .Rs2_1(rs_in_rs2_1), 
        .Rs1_2(rs_in_rs1_2), .Rs2_2(rs_in_rs2_2), .Rs1_3(rs_in_rs1_3), .Rs2_3(rs_in_rs2_3) 
    );

    // =========================================================================
    // 4. DISPATCH -> EXECUTE PIPELINE REGISTERS (5 Lanes)
    // =========================================================================
    DE_Pipeline_reg DE_reg0 ( .Clk(Clk), .Reset(Reset), 
        .Vj_in(rs_out_vj0), .Vk_in(rs_out_vk0), .Mem_offset_in(rs_out_imm0), .PC_in(rs_out_pc0), .Imm_in(rs_out_imm0),
        .Tag_in(rs_out_tag0), .Instr_type_in(rs_out_op0), .Dispatch_valid_in(rs_out_valid0), .Pred_taken_in(rs_out_pred0),
        .Vj_out(de_vj0), .Vk_out(de_vk0), .Mem_offset_out(de_imm0), .PC_out(de_pc0), .Tag_out(de_tag0), .Instr_type_out(de_op0), .Dispatch_valid_out(de_valid0), .Pred_taken_out(de_pred0) );

    DE_Pipeline_reg DE_reg1 ( .Clk(Clk), .Reset(Reset), 
        .Vj_in(rs_out_vj1), .Vk_in(rs_out_vk1), .Mem_offset_in(rs_out_imm1), .PC_in(rs_out_pc1), .Imm_in(rs_out_imm1),
        .Tag_in(rs_out_tag1), .Instr_type_in(rs_out_op1), .Dispatch_valid_in(rs_out_valid1), .Pred_taken_in(rs_out_pred1),
        .Vj_out(de_vj1), .Vk_out(de_vk1), .Mem_offset_out(de_imm1), .PC_out(de_pc1), .Tag_out(de_tag1), .Instr_type_out(de_op1), .Dispatch_valid_out(de_valid1), .Pred_taken_out(de_pred1) );

    DE_Pipeline_reg DE_reg2 ( .Clk(Clk), .Reset(Reset), 
        .Vj_in(rs_out_vj2), .Vk_in(rs_out_vk2), .Mem_offset_in(rs_out_imm2), .PC_in(rs_out_pc2), .Imm_in(rs_out_imm2),
        .Tag_in(rs_out_tag2), .Instr_type_in(rs_out_op2), .Dispatch_valid_in(rs_out_valid2), .Pred_taken_in(rs_out_pred2),
        .Vj_out(de_vj2), .Vk_out(de_vk2), .Mem_offset_out(de_imm2), .PC_out(de_pc2), .Tag_out(de_tag2), .Instr_type_out(de_op2), .Dispatch_valid_out(de_valid2), .Pred_taken_out(de_pred2) );

    DE_Pipeline_reg DE_reg3 ( .Clk(Clk), .Reset(Reset), 
        .Vj_in(rs_out_vj3), .Vk_in(rs_out_vk3), .Mem_offset_in(rs_out_imm3), .PC_in(rs_out_pc3), .Imm_in(rs_out_imm3),
        .Tag_in(rs_out_tag3), .Instr_type_in(rs_out_op3), .Dispatch_valid_in(rs_out_valid3), .Pred_taken_in(rs_out_pred3),
        .Vj_out(de_vj3), .Vk_out(de_vk3), .Mem_offset_out(de_imm3), .PC_out(de_pc3), .Tag_out(de_tag3), .Instr_type_out(de_op3), .Dispatch_valid_out(de_valid3), .Pred_taken_out(de_pred3) );

    // Memory Lane 4
    DE_Pipeline_reg DE_reg4 ( .Clk(Clk), .Reset(Reset), 
        .Vj_in(rs_out_vj4), .Vk_in(rs_out_vk4), .Mem_offset_in(rs_out_imm4), .PC_in(rs_out_pc4), .Imm_in(rs_out_imm4),
        .Tag_in(rs_out_tag4), .Instr_type_in(rs_out_op4), .Dispatch_valid_in(rs_out_valid4), .Pred_taken_in(rs_out_pred4),
        .Vj_out(de_vj4), .Vk_out(de_vk4), .Mem_offset_out(de_imm4), .PC_out(de_pc4), .Tag_out(de_tag4), .Instr_type_out(de_op4), .Dispatch_valid_out(de_valid4), .Pred_taken_out(de_pred4) );

    // =========================================================================
    // 5. EXECUTE STAGE
    // =========================================================================
    Multi_Issue_OoO_Execute MIOoOE (
        // ALU Lanes
        .Vj_in0(de_vj0), .Vk_in0(de_vk0), .Imm0(de_imm0), .PC0(de_pc0), .I_type0(de_op0), .ALU_tag_in0(de_tag0), .Valid_ALU0(de_valid0), .Pred_taken0(de_pred0),
        .Vj_in1(de_vj1), .Vk_in1(de_vk1), .Imm1(de_imm1), .PC1(de_pc1), .I_type1(de_op1), .ALU_tag_in1(de_tag1), .Valid_ALU1(de_valid1), .Pred_taken1(de_pred1),
        .Vj_in2(de_vj2), .Vk_in2(de_vk2), .Imm2(de_imm2), .PC2(de_pc2), .I_type2(de_op2), .ALU_tag_in2(de_tag2), .Valid_ALU2(de_valid2), .Pred_taken2(de_pred2),
        .Vj_in3(de_vj3), .Vk_in3(de_vk3), .Imm3(de_imm3), .PC3(de_pc3), .I_type3(de_op3), .ALU_tag_in3(de_tag3), .Valid_ALU3(de_valid3), .Pred_taken3(de_pred3),
        
        // Memory Lane
        .Mem_Vj(de_vj4), .Mem_Vk(de_vk4), .Mem_offset(de_imm4), .PC4(de_pc4),
        .Mem_tag_in(de_tag4), .Mem_type_in(de_op4), .Valid_mem(de_valid4), .Pred_taken4(de_pred4),
        
        // ALU Outputs -> CDB
        .ALU_result0(exec_res0), .ALU_tag_out0(exec_tag0), .ValidA0(exec_val0),
        .ALU_result1(exec_res1), .ALU_tag_out1(exec_tag1), .ValidA1(exec_val1),
        .ALU_result2(exec_res2), .ALU_tag_out2(exec_tag2), .ValidA2(exec_val2),
        .ALU_result3(exec_res3), .ALU_tag_out3(exec_tag3), .ValidA3(exec_val3),
        
        // Mem Outputs -> Pipeline Reg
        .Mem_address_out(exec_mem_addr), .Mem_data_out(exec_mem_data), .Mem_type_out(exec_mem_type), .Mem_tag_out(exec_mem_tag), .ValidM(exec_mem_valid),
        
        // Branch Outputs
        .Mispredict0(Mispredict0), .Branch_target0(Branch_target0),
        .Mispredict1(Mispredict1), .Branch_target1(Branch_target1),
        .Mispredict2(Mispredict2), .Branch_target2(Branch_target2),
        .Mispredict3(Mispredict3), .Branch_target3(Branch_target3),
        .Mispredict4(Mispredict4), .Branch_target4(Branch_target4)
    );

    // =========================================================================
    // 6. MEMORY STAGE
    // =========================================================================
    EM_pipeline_reg EM_reg (
        .Clk(Clk), .Reset(Reset), 
        .Mem_addr(exec_mem_addr), .Data_in(exec_mem_data), .Mem_type_in(exec_mem_type), .Mem_tag_in(exec_mem_tag), .Valid_mem_in(exec_mem_valid),
        .Addr_out(mem_stage_addr), .Data_out(mem_stage_data), .Mem_type_out(mem_stage_type), .Mem_tag_out(mem_stage_tag), .Mem_valid(mem_stage_valid)
    );

    Multi_Issue_OoO_Mem MIOoOM (
        .Clk(Clk), .Reset(Reset),
        .Valid_mem(mem_stage_valid), .Mem_type(mem_stage_type), .Dest_tag_in(mem_stage_tag), .Data_in(mem_stage_data), .Addr_in(mem_stage_addr),
        .Data_out(mem_res), .Dest_tag_out(mem_res_tag), .Valid_CDB_write(mem_res_valid), .Mem_busy(mem_busy_sig)
    );

    // =========================================================================
    // 7. CDB ARBITER
    // =========================================================================
    Multi_Issue_CDB MICDB (
        .Clk(Clk), .Reset(Reset),
        .ALU_res0(exec_res0), .ALU_res1(exec_res1), .ALU_res2(exec_res2), .ALU_res3(exec_res3),
        .Mem_data_in(mem_res),
        .CDB_tag0(exec_tag0), .CDB_tag1(exec_tag1), .CDB_tag2(exec_tag2), .CDB_tag3(exec_tag3), .CDB_tag4(mem_res_tag),
        .ALU_valid0(exec_val0), .ALU_valid1(exec_val1), .ALU_valid2(exec_val2), .ALU_valid3(exec_val2), .Mem_valid(mem_res_valid),
        
        .CDB_res0(CDB_res0), .CDB_tag_out0(CDB_tag_out0), .CDB_valid0(CDB_valid0),
        .CDB_res1(CDB_res1), .CDB_tag_out1(CDB_tag_out1), .CDB_valid1(CDB_valid1),
        .CDB_res2(CDB_res2), .CDB_tag_out2(CDB_tag_out2), .CDB_valid2(CDB_valid2),
        .CDB_res3(CDB_res3), .CDB_tag_out3(CDB_tag_out3), .CDB_valid3(CDB_valid3),
        .CDB_res4(CDB_res4), .CDB_tag_out4(CDB_tag_out4), .CDB_valid4(CDB_valid4)
    );
    
endmodule