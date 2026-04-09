module Decode(
    input wire Clk, Reset,
    // 4 instructions from fetch {pred[1], PC[32], Instruction[32]}
    input wire [4*65-1:0] IQD_in,      
    
    // Input wires from IQ to signal valid instructions
    input wire Valid_in0, Valid_in1, Valid_in2, Valid_in3,
    
    // CDB Inputs (for register file writeback)
    input wire [31:0] CDB_data0, CDB_data1, CDB_data2, CDB_data3, CDB_data4,
    input wire [6:0]  CDB_tag0,  CDB_tag1,  CDB_tag2,  CDB_tag3,  CDB_tag4,
    input wire        CDB_valid0, CDB_valid1, CDB_valid2, CDB_valid3, CDB_valid4,
    
    // RAT Update Inputs (from Issue stage - rename feedback)
    input wire        RAT_we0, RAT_we1, RAT_we2, RAT_we3,
    input wire [4:0]  RAT_rd0, RAT_rd1, RAT_rd2, RAT_rd3,
    input wire [6:0]  RAT_tag0, RAT_tag1, RAT_tag2, RAT_tag3,
    
    // Control inputs
    input wire RS_full, IQ_full, D_cache_miss, Branch_misprediction, Branch_resolve,
    input wire [31:0] Branch_correction,
    
    // Control outputs (Keep as wires for immediate feedback)
    output wire Stall_Decode, Stall_Fetch, Flush,
    
    // Wire for valid instructions from HDU (Keep as wire)
    output wire [3:0] hdu_issue_mask,     
    
    // Outputs to Issue Stage (Multi_Issue_Tomasulo) -> CHANGED TO REG
    // Lane 0
    output reg [31:0] Vj_out0, Vk_out0, Imm_out0, PC_out0,
    output reg [4:0]  I_type_out0, Rd_out0, Rs1_0, Rs2_0,
    output reg [7:0]  Rs1_tag_out0, Rs2_tag_out0,
    output reg        IQ_Valid_out0, Pred_take_out0, Has_Rd_out0,
    output reg        Rs1_0_valid_out, Rs2_0_valid_out,
    
    // Lane 1
    output reg [31:0] Vj_out1, Vk_out1, Imm_out1, PC_out1,
    output reg [4:0]  I_type_out1, Rd_out1, Rs1_1, Rs2_1,
    output reg [7:0]  Rs1_tag_out1, Rs2_tag_out1,
    output reg        IQ_Valid_out1, Pred_take_out1, Has_Rd_out1,
    output reg        Rs1_1_valid_out, Rs2_1_valid_out,
    
    // Lane 2
    output reg [31:0] Vj_out2, Vk_out2, Imm_out2, PC_out2,
    output reg [4:0]  I_type_out2, Rd_out2, Rs1_2, Rs2_2,
    output reg [7:0]  Rs1_tag_out2, Rs2_tag_out2,
    output reg        IQ_Valid_out2, Pred_take_out2, Has_Rd_out2,
    output reg        Rs1_2_valid_out, Rs2_2_valid_out,
    
    // Lane 3
    output reg [31:0] Vj_out3, Vk_out3, Imm_out3, PC_out3,
    output reg [4:0]  I_type_out3, Rd_out3, Rs1_3, Rs2_3,
    output reg [7:0]  Rs1_tag_out3, Rs2_tag_out3,
    output reg        IQ_Valid_out3, Pred_take_out3, Has_Rd_out3,
    output reg        Rs1_3_valid_out, Rs2_3_valid_out
);

    // ========================================================================
    // 1. Slice IQD_in into 4 slots (each 65 bits = {pred[1], PC[32], Instr[32]})
    // ========================================================================
    wire [64:0] slot0 = IQD_in[64:0];
    wire [64:0] slot1 = IQD_in[129:65];
    wire [64:0] slot2 = IQD_in[194:130];
    wire [64:0] slot3 = IQD_in[259:195];
    
    wire [31:0] Instruction_0 = slot0[63:32];
    wire [31:0] Instruction_1 = slot1[63:32];
    wire [31:0] Instruction_2 = slot2[63:32];
    wire [31:0] Instruction_3 = slot3[63:32];

    wire [31:0] PC_0 = slot0[31:0];
    wire [31:0] PC_1 = slot1[31:0];
    wire [31:0] PC_2 = slot2[31:0];
    wire [31:0] PC_3 = slot3[31:0];

    wire Pred_take0 = slot0[64];
    wire Pred_take1 = slot1[64];
    wire Pred_take2 = slot2[64];
    wire Pred_take3 = slot3[64];

    // ========================================================================
    // 2. Control Unit Outputs
    // ========================================================================
    // Lane 0
    wire [4:0] Read_reg1_0, Read_reg2_0, Write_reg_0, Instruction_type_0;
    wire Immediate_enable_0, Has_Rd_0, Done_0;
    wire [31:0] Immediate_0;
    
    // Lane 1
    wire [4:0] Read_reg1_1, Read_reg2_1, Write_reg_1, Instruction_type_1;
    wire Immediate_enable_1, Has_Rd_1, Done_1;
    wire [31:0] Immediate_1;
    
    // Lane 2
    wire [4:0] Read_reg1_2, Read_reg2_2, Write_reg_2, Instruction_type_2;
    wire Immediate_enable_2, Has_Rd_2, Done_2;
    wire [31:0] Immediate_2;
    
    // Lane 3
    wire [4:0] Read_reg1_3, Read_reg2_3, Write_reg_3, Instruction_type_3;
    wire Immediate_enable_3, Has_Rd_3, Done_3;
    wire [31:0] Immediate_3;
    
    // ========================================================================
    // 3. Instantiate 4 Control Units
    // ========================================================================
    OoO_Control_Unit OOOCU0(
        .Instruction(Instruction_0), 
        .Read_reg1(Read_reg1_0), .Read_reg2(Read_reg2_0),
        .Write_reg(Write_reg_0), .Instruction_type(Instruction_type_0), 
        .Immediate_enable(Immediate_enable_0), .Has_Rd(Has_Rd_0), 
        .Done(Done_0), .Immediate(Immediate_0)
    );
    
    OoO_Control_Unit OOOCU1(
        .Instruction(Instruction_1), 
        .Read_reg1(Read_reg1_1), .Read_reg2(Read_reg2_1),
        .Write_reg(Write_reg_1), .Instruction_type(Instruction_type_1), 
        .Immediate_enable(Immediate_enable_1), .Has_Rd(Has_Rd_1), 
        .Done(Done_1), .Immediate(Immediate_1)
    );
           
    OoO_Control_Unit OOOCU2(
        .Instruction(Instruction_2), 
        .Read_reg1(Read_reg1_2), .Read_reg2(Read_reg2_2),
        .Write_reg(Write_reg_2), .Instruction_type(Instruction_type_2), 
        .Immediate_enable(Immediate_enable_2), .Has_Rd(Has_Rd_2), 
        .Done(Done_2), .Immediate(Immediate_2)
    );

    OoO_Control_Unit OOOCU3(
        .Instruction(Instruction_3), 
        .Read_reg1(Read_reg1_3), .Read_reg2(Read_reg2_3),
        .Write_reg(Write_reg_3), .Instruction_type(Instruction_type_3), 
        .Immediate_enable(Immediate_enable_3), .Has_Rd(Has_Rd_3), 
        .Done(Done_3), .Immediate(Immediate_3)
    );

    // ========================================================================
    // 4. Hazard Detection (HDU)
    // ========================================================================
    // Detect Branches based on Opcode (Assuming 18-25 range)
    wire Branch_d0 = (Instruction_type_0 >= 5'd18 && Instruction_type_0 <= 5'd25);
    wire Branch_d1 = (Instruction_type_1 >= 5'd18 && Instruction_type_1 <= 5'd25);
    wire Branch_d2 = (Instruction_type_2 >= 5'd18 && Instruction_type_2 <= 5'd25);
    wire Branch_d3 = (Instruction_type_3 >= 5'd18 && Instruction_type_3 <= 5'd25);
    
    // Identify Stores (Opcode 13-17). Stores need Rs2 (Data), so we can't force Rs2 Ready.
    wire Is_Store_0 = (Instruction_type_0 >= 5'd13 && Instruction_type_0 <= 5'd17); 
    wire Is_Store_1 = (Instruction_type_1 >= 5'd13 && Instruction_type_1 <= 5'd17); 
    wire Is_Store_2 = (Instruction_type_2 >= 5'd13 && Instruction_type_2 <= 5'd17); 
    wire Is_Store_3 = (Instruction_type_3 >= 5'd13 && Instruction_type_3 <= 5'd17); 
    
    wire w_stall_decode;
    assign Stall_Decode = w_stall_decode;

    Tomasulos_Multi_Issue_HDU MIOoOHDU(
        .Clk(Clk), .Reset(Reset),
        .RS_full(RS_full), .IQ_full(IQ_full), .D_cache_miss(D_cache_miss),
        
        .Branch_decode({Branch_d3, Branch_d2, Branch_d1, Branch_d0}), 
        .Branch_valid({Valid_in3, Valid_in2, Valid_in1, Valid_in0}), 
        .Branch_resolve(Branch_resolve), 
        .Branch_mispredict(Branch_misprediction),
        .Branch_correction(Branch_correction), 
        
        .Stall_fetch(Stall_Fetch), .Stall_Decode(w_stall_decode), .Flush(Flush),
        .Issue_Mask(hdu_issue_mask)
    );     

    // ========================================================================
    // 5. Register File (Reg Reading & Renaming Status)
    // ========================================================================
    // Register File Outputs
    wire [31:0] RF_Data_rs1_0, RF_Data_rs2_0;
    wire [6:0]  RF_Tag_rs1_0,  RF_Tag_rs2_0;
    wire        RF_Ready_rs1_0, RF_Ready_rs2_0;
    
    wire [31:0] RF_Data_rs1_1, RF_Data_rs2_1;
    wire [6:0]  RF_Tag_rs1_1,  RF_Tag_rs2_1;
    wire        RF_Ready_rs1_1, RF_Ready_rs2_1;
    
    wire [31:0] RF_Data_rs1_2, RF_Data_rs2_2;
    wire [6:0]  RF_Tag_rs1_2,  RF_Tag_rs2_2;
    wire        RF_Ready_rs1_2, RF_Ready_rs2_2;
    
    wire [31:0] RF_Data_rs1_3, RF_Data_rs2_3;
    wire [6:0]  RF_Tag_rs1_3,  RF_Tag_rs2_3;
    wire        RF_Ready_rs1_3, RF_Ready_rs2_3;
    
    Multi_Issue_OoO_reg_file MIOoORF(
        .Clk(Clk), .Reset(Reset),
        
        // CDB Writeback
        .CDB_data0(CDB_data0), .CDB_data1(CDB_data1), .CDB_data2(CDB_data2), 
        .CDB_data3(CDB_data3), .CDB_data4(CDB_data4),
        .CDB_tag0(CDB_tag0), .CDB_tag1(CDB_tag1), .CDB_tag2(CDB_tag2), 
        .CDB_tag3(CDB_tag3), .CDB_tag4(CDB_tag4),
        .CDB_valid0(CDB_valid0), .CDB_valid1(CDB_valid1), .CDB_valid2(CDB_valid2), 
        .CDB_valid3(CDB_valid3), .CDB_valid4(CDB_valid4),
        
        // RAT Updates (from Issue stage)
        .RAT_we0(RAT_we0), .RAT_we1(RAT_we1), .RAT_we2(RAT_we2), .RAT_we3(RAT_we3), 
        .RAT_rd0(RAT_rd0), .RAT_rd1(RAT_rd1), .RAT_rd2(RAT_rd2), .RAT_rd3(RAT_rd3), 
        .RAT_tag0(RAT_tag0), .RAT_tag1(RAT_tag1), .RAT_tag2(RAT_tag2), .RAT_tag3(RAT_tag3), 
        
        // Read Ports (from Control Units)
        .Rs1_0(Read_reg1_0), .Rs2_0(Read_reg2_0),
        .Rs1_1(Read_reg1_1), .Rs2_1(Read_reg2_1),
        .Rs1_2(Read_reg1_2), .Rs2_2(Read_reg2_2),
        .Rs1_3(Read_reg1_3), .Rs2_3(Read_reg2_3),
        
        // Read Outputs
        .Data_out0_rs1(RF_Data_rs1_0), .Data_out0_rs2(RF_Data_rs2_0),
        .Tag_out0_rs1(RF_Tag_rs1_0), .Tag_out0_rs2(RF_Tag_rs2_0),
        .Ready_out0_rs1(RF_Ready_rs1_0), .Ready_out0_rs2(RF_Ready_rs2_0),
        
        .Data_out1_rs1(RF_Data_rs1_1), .Data_out1_rs2(RF_Data_rs2_1),
        .Tag_out1_rs1(RF_Tag_rs1_1), .Tag_out1_rs2(RF_Tag_rs2_1),
        .Ready_out1_rs1(RF_Ready_rs1_1), .Ready_out1_rs2(RF_Ready_rs2_1),
        
        .Data_out2_rs1(RF_Data_rs1_2), .Data_out2_rs2(RF_Data_rs2_2),
        .Tag_out2_rs1(RF_Tag_rs1_2), .Tag_out2_rs2(RF_Tag_rs2_2),
        .Ready_out2_rs1(RF_Ready_rs1_2), .Ready_out2_rs2(RF_Ready_rs2_2),
        
        .Data_out3_rs1(RF_Data_rs1_3), .Data_out3_rs2(RF_Data_rs2_3),
        .Tag_out3_rs1(RF_Tag_rs1_3), .Tag_out3_rs2(RF_Tag_rs2_3),
        .Ready_out3_rs1(RF_Ready_rs1_3), .Ready_out3_rs2(RF_Ready_rs2_3)
    );

    // ========================================================================
    // 6. Output Logic (Registered)
    // ========================================================================

    // -- Intermediate wire definitions (Combinational Logic) --
    // These calculate the "Next" state for the registers
    
    // Lane 0 wires
    wire [31:0] w_Vk_out0       = (Immediate_enable_0 && !Is_Store_0) ? Immediate_0 : RF_Data_rs2_0;
    wire [7:0]  w_Rs1_tag_out0  = {RF_Ready_rs1_0, RF_Tag_rs1_0};
    wire [7:0]  w_Rs2_tag_out0  = (Immediate_enable_0 && !Is_Store_0) ? {1'b1, 7'd0} : {RF_Ready_rs2_0, RF_Tag_rs2_0};
    wire        w_Rs2_valid_0   = (Immediate_enable_0 && !Is_Store_0) ? 1'b1 : RF_Ready_rs2_0;
    
    // Lane 1 wires
    wire [31:0] w_Vk_out1       = (Immediate_enable_1 && !Is_Store_1) ? Immediate_1 : RF_Data_rs2_1;
    wire [7:0]  w_Rs1_tag_out1  = {RF_Ready_rs1_1, RF_Tag_rs1_1};
    wire [7:0]  w_Rs2_tag_out1  = (Immediate_enable_1 && !Is_Store_1) ? {1'b1, 7'd0} : {RF_Ready_rs2_1, RF_Tag_rs2_1};
    wire        w_Rs2_valid_1   = (Immediate_enable_1 && !Is_Store_1) ? 1'b1 : RF_Ready_rs2_1;
    
    // Lane 2 wires
    wire [31:0] w_Vk_out2       = (Immediate_enable_2 && !Is_Store_2) ? Immediate_2 : RF_Data_rs2_2;
    wire [7:0]  w_Rs1_tag_out2  = {RF_Ready_rs1_2, RF_Tag_rs1_2};
    wire [7:0]  w_Rs2_tag_out2  = (Immediate_enable_2 && !Is_Store_2) ? {1'b1, 7'd0} : {RF_Ready_rs2_2, RF_Tag_rs2_2};
    wire        w_Rs2_valid_2   = (Immediate_enable_2 && !Is_Store_2) ? 1'b1 : RF_Ready_rs2_2;

    // Lane 3 wires
    wire [31:0] w_Vk_out3       = (Immediate_enable_3 && !Is_Store_3) ? Immediate_3 : RF_Data_rs2_3;
    wire [7:0]  w_Rs1_tag_out3  = {RF_Ready_rs1_3, RF_Tag_rs1_3};
    wire [7:0]  w_Rs2_tag_out3  = (Immediate_enable_3 && !Is_Store_3) ? {1'b1, 7'd0} : {RF_Ready_rs2_3, RF_Tag_rs2_3};
    wire        w_Rs2_valid_3   = (Immediate_enable_3 && !Is_Store_3) ? 1'b1 : RF_Ready_rs2_3;

    // -- Sequential Output Block --
    always @(posedge Clk) begin
        if (Reset || Flush) begin
            // Clear Valid signals on Reset/Flush
            IQ_Valid_out0 <= 0;
            IQ_Valid_out1 <= 0;
            IQ_Valid_out2 <= 0;
            IQ_Valid_out3 <= 0;
            
            // Optional: zero out data (not strictly required, but good for debug)
            PC_out0 <= 0; PC_out1 <= 0; PC_out2 <= 0; PC_out3 <= 0;
        end 
        else if (!w_stall_decode) begin
            // Only update outputs if NOT stalled (Pipeline Register behavior)
            
            // --- Lane 0 ---
            IQ_Valid_out0   <= Valid_in0 && !Done_0 && hdu_issue_mask[0];
            Vj_out0         <= RF_Data_rs1_0;
            Vk_out0         <= w_Vk_out0;
            Imm_out0        <= Immediate_0;
            PC_out0         <= PC_0;
            I_type_out0     <= Instruction_type_0;
            Rd_out0         <= Write_reg_0;
            Rs1_tag_out0    <= w_Rs1_tag_out0;
            Rs2_tag_out0    <= w_Rs2_tag_out0;
            Pred_take_out0  <= Pred_take0;
            Has_Rd_out0     <= Has_Rd_0;
            Rs1_0_valid_out <= RF_Ready_rs1_0;
            Rs2_0_valid_out <= w_Rs2_valid_0;
            Rs1_0           <= Read_reg1_0;
            Rs2_0           <= Read_reg2_0;

            // --- Lane 1 ---
            IQ_Valid_out1   <= Valid_in1 && !Done_1 && hdu_issue_mask[1];
            Vj_out1         <= RF_Data_rs1_1;
            Vk_out1         <= w_Vk_out1;
            Imm_out1        <= Immediate_1;
            PC_out1         <= PC_1;
            I_type_out1     <= Instruction_type_1;
            Rd_out1         <= Write_reg_1;
            Rs1_tag_out1    <= w_Rs1_tag_out1;
            Rs2_tag_out1    <= w_Rs2_tag_out1;
            Pred_take_out1  <= Pred_take1;
            Has_Rd_out1     <= Has_Rd_1;
            Rs1_1_valid_out <= RF_Ready_rs1_1;
            Rs2_1_valid_out <= w_Rs2_valid_1;
            Rs1_1           <= Read_reg1_1;
            Rs2_1           <= Read_reg2_1;

            // --- Lane 2 ---
            IQ_Valid_out2   <= Valid_in2 && !Done_2 && hdu_issue_mask[2];
            Vj_out2         <= RF_Data_rs1_2;
            Vk_out2         <= w_Vk_out2;
            Imm_out2        <= Immediate_2;
            PC_out2         <= PC_2;
            I_type_out2     <= Instruction_type_2;
            Rd_out2         <= Write_reg_2;
            Rs1_tag_out2    <= w_Rs1_tag_out2;
            Rs2_tag_out2    <= w_Rs2_tag_out2;
            Pred_take_out2  <= Pred_take2;
            Has_Rd_out2     <= Has_Rd_2;
            Rs1_2_valid_out <= RF_Ready_rs1_2;
            Rs2_2_valid_out <= w_Rs2_valid_2;
            Rs1_2           <= Read_reg1_2;
            Rs2_2           <= Read_reg2_2;

            // --- Lane 3 ---
            IQ_Valid_out3   <= Valid_in3 && !Done_3 && hdu_issue_mask[3];
            Vj_out3         <= RF_Data_rs1_3;
            Vk_out3         <= w_Vk_out3;
            Imm_out3        <= Immediate_3;
            PC_out3         <= PC_3;
            I_type_out3     <= Instruction_type_3;
            Rd_out3         <= Write_reg_3;
            Rs1_tag_out3    <= w_Rs1_tag_out3;
            Rs2_tag_out3    <= w_Rs2_tag_out3;
            Pred_take_out3  <= Pred_take3;
            Has_Rd_out3     <= Has_Rd_3;
            Rs1_3_valid_out <= RF_Ready_rs1_3;
            Rs2_3_valid_out <= w_Rs2_valid_3;
            Rs1_3           <= Read_reg1_3;
            Rs2_3           <= Read_reg2_3;
        end
        // Implicit ELSE: If stalled, maintain current values in registers.
    end

endmodule