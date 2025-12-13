`timescale 10ns/1ps
module Multi_Issue_Fetch (
    input  wire        Clk, Reset, Fetch_done,
    input  wire [3:0]  PC_enable,
    input  wire [2:0]  Num_issued,    
    input  wire [4*68-1:0] EM_feedback,   
    output wire [4*65-1:0] FD_out        
);

    // Split
    wire [67:0] EM_fb0 = EM_feedback[67:0];
    wire [67:0] EM_fb1 = EM_feedback[135:68];
    wire [67:0] EM_fb2 = EM_feedback[203:136];
    wire [67:0] EM_fb3 = EM_feedback[271:204];
    
    wire EX_Prediction0 = EM_fb0[67];
    wire Update_en0 = EM_fb0[66];       
    wire Update_taken0 = EM_fb0[65];          
    wire [31:0] Branch_target0 = EM_fb0[64:33];
    wire [31:0] Update_pc0 = EM_fb0[32:1];
    wire jump0 = EM_fb0[0];
    wire [31:0] PC_correction0 = (jump0 || Update_taken0) ? Branch_target0 : (Update_pc0 + 32'd4);

    wire EX_Prediction1 = EM_fb1[67];
    wire Update_en1 = EM_fb1[66];
    wire Update_taken1 = EM_fb1[65];
    wire [31:0] Branch_target1 = EM_fb1[64:33];
    wire [31:0] Update_pc1 = EM_fb1[32:1];
    wire jump1 = EM_fb1[0];
    wire [31:0] PC_correction1 = (jump1 || Update_taken1) ? Branch_target1 : (Update_pc1 + 32'd4);

    wire EX_Prediction2 = EM_fb2[67];       // Branch Prediction
    wire Update_en2 = EM_fb2[66];           // Valid Branch Instr
    wire Update_taken2 = EM_fb2[65];        // Resolved branch (1 or 0)
    wire [31:0] Branch_target2 = EM_fb2[64:33];
    wire [31:0] Update_pc2 = EM_fb2[32:1];  
    wire jump2 = EM_fb2[0];
    wire [31:0] PC_correction2 = (jump2 || Update_taken2) ? Branch_target2 : (Update_pc2 + 32'd4);
    
    wire EX_Prediction3 = EM_fb3[67];
    wire Update_en3 = EM_fb3[66];
    wire Update_taken3 = EM_fb3[65];
    wire [31:0] Branch_target3 = EM_fb3[64:33];
    wire [31:0] Update_pc3 = EM_fb3[32:1];
    wire jump3 = EM_fb3[0];
    wire [31:0] PC_correction3 = (jump3 || Update_taken3) ? Branch_target3 : (Update_pc3 + 32'd4);

    // -----------------------------
    // Per-issue wires
    // -----------------------------
    wire [31:0] PC0, PC1, PC2, PC3;
    wire [31:0] Instr0, Instr1, Instr2, Instr3;
    wire Pred_taken0, Pred_taken1, Pred_taken2, Pred_taken3;
    wire [31:0] Pred_target0, Pred_target1, Pred_target2, Pred_target3;
    
    wire [31:0] PC_next;
    
    // Combinational logic (no register)
    assign PC_next = Reset ? 32'h0 :
                 (Num_issued == 3'd0) ? PC0 :
                 (Num_issued == 3'd1) ? (PC0 + 32'd4) :
                 (Num_issued == 3'd2) ? (PC0 + 32'd8) :
                 (Num_issued == 3'd3) ? (PC0 + 32'd12) :
                 (PC3 + 32'd4);  // All 4 issued, no branches

    // -----------------------------
    // Branch Predictor
    // -----------------------------
    Multi_Issue_BP MIBP (
        .Clk(Clk),
        .Reset(Reset),
        .PC0(PC0), .PC1(PC1), .PC2(PC2), .PC3(PC3),
        .Pred_taken0(Pred_taken0), .Pred_taken1(Pred_taken1),
        .Pred_taken2(Pred_taken2), .Pred_taken3(Pred_taken3),
        .Pred_target0(Pred_target0), .Pred_target1(Pred_target1),
        .Pred_target2(Pred_target2), .Pred_target3(Pred_target3),
        .Update_en0(Update_en0 || jump0), .Update_taken0(Update_taken0 || jump0),
        .Update_pc0(Update_pc0), .Update_target0(Branch_target0),
        .Update_en1(Update_en1 || jump1), .Update_taken1(Update_taken1 || jump1),
        .Update_pc1(Update_pc1), .Update_target1(Branch_target1),
        .Update_en2(Update_en2 || jump2), .Update_taken2(Update_taken2 || jump2),
        .Update_pc2(Update_pc2), .Update_target2(Branch_target2),
        .Update_en3(Update_en3 || jump3), .Update_taken3(Update_taken3 || jump3),
        .Update_pc3(Update_pc3), .Update_target3(Branch_target3)      
    );

    Multi_Issue_Fetch_Unit MIFU (
        .Clk(Clk),
        .Reset(Reset),
        .PC_enable(PC_enable),
        .Num_issued(Num_issued),
        .Fetch_done(Fetch_done),
        .Pred_taken({Pred_taken3, Pred_taken2, Pred_taken1, Pred_taken0}),
        .Pred_miss({(Update_en3 && (EX_Prediction3 != Update_taken3)),
                    (Update_en2 && (EX_Prediction2 != Update_taken2)),
                    (Update_en1 && (EX_Prediction1 != Update_taken1)),
                    (Update_en0 && (EX_Prediction0 != Update_taken0))}),
        .Pred_target0(Pred_target0),
        .Pred_target1(Pred_target1),
        .Pred_target2(Pred_target2),
        .Pred_target3(Pred_target3),
        .Miss_target0(PC_correction0),  
        .Miss_target1(PC_correction1),
        .Miss_target2(PC_correction2),
        .Miss_target3(PC_correction3),
        .PC_connect(PC_next),
        .PC0(PC0),
        .PC1(PC1),
        .PC2(PC2),
        .PC3(PC3)
    );

    Multi_Issue_ROM MIR (
        .Clk(Clk), .Reset(Reset),
        .PC0(PC0), .PC1(PC1), .PC2(PC2), .PC3(PC3),
        .Instr0(Instr0), .Instr1(Instr1),
        .Instr2(Instr2), .Instr3(Instr3)
    );
 
    wire valid0 = 1'b1;
    wire valid1 = !Pred_taken0;
    wire valid2 = !Pred_taken0 && !Pred_taken1;
    wire valid3 = !Pred_taken0 && !Pred_taken1 && !Pred_taken2;

    assign FD_out = {
        Num_issued,
        Pred_taken3, (valid3 ? Instr3 : 32'h00000033), PC3,  // NOP if invalid (add x0, x0, x0)
        Pred_taken2, (valid2 ? Instr2 : 32'h00000033), PC2,
        Pred_taken1, (valid1 ? Instr1 : 32'h00000033), PC1,
        Pred_taken0, (valid0 ? Instr0 : 32'h00000033), PC0
    };

endmodule