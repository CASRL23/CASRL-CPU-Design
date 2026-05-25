`timescale 10ns / 1ps

module Multi_Issue_Decode (
    input  wire  Clk, Reset,
    input  wire [4*65-1:0] FD_in,     
    input  wire [3:0]  DE_MemRead, E_branch, E_pred_taken, E_valid_branch,
    input  wire [4*5-1:0] DE_Rd,
    input  wire [4*32-1:0] WB_data,
    input  wire [4*5-1:0] WB_addr,
    input  wire [3:0]  WB_en,
    output wire [4*167-1:0] DE_out,
    output wire [2:0] Num_issued,
    output wire [3:0] PC_en,
    output wire Flush, FD_write,
    output wire [31:0] display_out
);

    // ---------- slice FD_in into 4 slots (each 65 bits) ----------
    wire [64:0] FD_slot0, FD_slot1, FD_slot2, FD_slot3;
    reg [2:0] Num_issued_prev;  // Number issued from prev cycle
    reg [64:0] FD_slot0_prev, FD_slot1_prev, FD_slot2_prev, FD_slot3_prev;
    wire is_nop_prev0, is_nop_prev1, is_nop_prev2, is_nop_prev3;

    // Arrange decode slots based on how many issued last cycle
    wire [64:0] decode_slot0, decode_slot1, decode_slot2, decode_slot3;

    assign FD_slot0 = FD_in[64:0];
    assign FD_slot1 = FD_in[129:65];
    assign FD_slot2 = FD_in[194:130];
    assign FD_slot3 = FD_in[259:195];
    
    always @(posedge Clk or posedge Reset) begin
        if (Reset || Flush) begin
            Num_issued_prev <= 3'd4; 
            FD_slot0_prev <= 65'b0;
            FD_slot1_prev <= 65'b0;
            FD_slot2_prev <= 65'b0;
            FD_slot3_prev <= 65'b0;
        end
        else begin
            Num_issued_prev <= Num_issued; 
            FD_slot0_prev <= decode_slot0;
            FD_slot1_prev <= decode_slot1;
            FD_slot2_prev <= decode_slot2;
            FD_slot3_prev <= decode_slot3; 
        end
    end
    
    assign is_nop_prev0 = (FD_slot0_prev[63:32] == 32'h00000033);
    assign is_nop_prev1 = (FD_slot1_prev[63:32] == 32'h00000033);
    assign is_nop_prev2 = (FD_slot2_prev[63:32] == 32'h00000033);
    assign is_nop_prev3 = (FD_slot3_prev[63:32] == 32'h00000033);
    
    // Identify valid (non-NOP) instructions from previous cycle that weren't fully consumed
    wire [3:0] prev_valid;
    assign prev_valid[0] = !is_nop_prev0 && (Num_issued_prev < 3'd1);
    assign prev_valid[1] = !is_nop_prev1 && (Num_issued_prev < 3'd2);
    assign prev_valid[2] = !is_nop_prev2 && (Num_issued_prev < 3'd3);
    assign prev_valid[3] = !is_nop_prev3 && (Num_issued_prev < 3'd4);

    // Count how many valid instructions remain from previous cycle
    wire [2:0] prev_valid_count = prev_valid[0] + prev_valid[1] + prev_valid[2] + prev_valid[3];

    // Pack remaining valid instructions, then fill with new instructions
    assign decode_slot0 = prev_valid[0] ? FD_slot0_prev :
                      prev_valid[1] ? FD_slot1_prev :
                      prev_valid[2] ? FD_slot2_prev :
                      prev_valid[3] ? FD_slot3_prev :
                      FD_slot0;

    assign decode_slot1 = (prev_valid[0] && prev_valid[1]) ? FD_slot1_prev :
                      (prev_valid[0] && prev_valid[2]) ? FD_slot2_prev :
                      (prev_valid[0] && prev_valid[3]) ? FD_slot3_prev :
                      (prev_valid[1] && prev_valid[2]) ? FD_slot2_prev :
                      (prev_valid[1] && prev_valid[3]) ? FD_slot3_prev :
                      (prev_valid[2] && prev_valid[3]) ? FD_slot3_prev :
                      prev_valid[0] ? FD_slot0 :
                      prev_valid[1] ? FD_slot0 :
                      prev_valid[2] ? FD_slot0 :
                      prev_valid[3] ? FD_slot0 :
                      FD_slot1;

    assign decode_slot2 = (prev_valid_count >= 3'd3) ? 
                     (prev_valid[0] && prev_valid[1] && prev_valid[2] ? FD_slot2_prev : 
                      prev_valid[0] && prev_valid[1] && prev_valid[3] ? FD_slot3_prev :
                      prev_valid[0] && prev_valid[2] && prev_valid[3] ? FD_slot3_prev :
                      FD_slot3_prev) :
                      (prev_valid_count == 3'd2) ? FD_slot0 :
                      (prev_valid_count == 3'd1) ? FD_slot1 :
                      FD_slot2;

    assign decode_slot3 = (prev_valid_count == 3'd4) ? FD_slot3_prev :
                      (prev_valid_count == 3'd3) ? FD_slot0 :
                      (prev_valid_count == 3'd2) ? FD_slot1 :
                      (prev_valid_count == 3'd1) ? FD_slot2 :
                      FD_slot3;
    
    // instruction and PC and prediction per slot
    wire [31:0] Instruction_0 = decode_slot0[63:32];
    wire [31:0] Instruction_1 = decode_slot1[63:32];
    wire [31:0] Instruction_2 = decode_slot2[63:32];
    wire [31:0] Instruction_3 = decode_slot3[63:32];

    wire [31:0] PC_0 = decode_slot0[31:0];
    wire [31:0] PC_1 = decode_slot1[31:0];
    wire [31:0] PC_2 = decode_slot2[31:0];
    wire [31:0] PC_3 = decode_slot3[31:0];

    wire Pred_take0 = decode_slot0[64];
    wire Pred_take1 = decode_slot1[64];
    wire Pred_take2 = decode_slot2[64];
    wire Pred_take3 = decode_slot3[64];
    
    // ---------- per-slot control / decode outputs (declared to match MICU instance) ----------
    // Slot 0
    wire [4:0] Read_reg1_0, Read_reg2_0, Write_reg_0;
    wire [3:0] Alu_opcode_0;
    wire       Immediate_enable_0, RegWrite_0, Jal_0, Jalr_0, Load_0, Store_0, Auipc_0, Lui_0;
    wire       Beq_0, Bne_0, Blt_0, Bge_0, Bltu_0, Bgeu_0;
    wire       Byte_0, Half_0, Word_0, Unsigned_0;
    wire       ALU_operation_0, Done_0;
    wire [31:0] Immediate_0;

    // Slot 1
    wire [4:0] Read_reg1_1, Read_reg2_1, Write_reg_1;
    wire [3:0] Alu_opcode_1;
    wire       Immediate_enable_1, RegWrite_1, Jal_1, Jalr_1, Load_1, Store_1, Auipc_1, Lui_1;
    wire       Beq_1, Bne_1, Blt_1, Bge_1, Bltu_1, Bgeu_1;
    wire       Byte_1, Half_1, Word_1, Unsigned_1;
    wire       ALU_operation_1, Done_1;
    wire [31:0] Immediate_1;

    // Slot 2
    wire [4:0] Read_reg1_2, Read_reg2_2, Write_reg_2;
    wire [3:0] Alu_opcode_2;
    wire       Immediate_enable_2, RegWrite_2, Jal_2, Jalr_2, Load_2, Store_2, Auipc_2, Lui_2;
    wire       Beq_2, Bne_2, Blt_2, Bge_2, Bltu_2, Bgeu_2;
    wire       Byte_2, Half_2, Word_2, Unsigned_2;
    wire       ALU_operation_2, Done_2;
    wire [31:0] Immediate_2;

    // Slot 3
    wire [4:0] Read_reg1_3, Read_reg2_3, Write_reg_3;
    wire [3:0] Alu_opcode_3;
    wire       Immediate_enable_3, RegWrite_3, Jal_3, Jalr_3, Load_3, Store_3, Auipc_3, Lui_3;
    wire       Beq_3, Bne_3, Blt_3, Bge_3, Bltu_3, Bgeu_3;
    wire       Byte_3, Half_3, Word_3, Unsigned_3;
    wire       ALU_operation_3, Done_3;
    wire [31:0] Immediate_3;

    // ---------- register file outputs (8 read ports for 4 slots x 2 read regs) ----------
    wire [31:0] Data_out0, Data_out1, Data_out2, Data_out3, Data_out4, Data_out5, Data_out6, Data_out7;

    // Map regfile outputs to slot read-data wires
    // convention: Data_out0 = Rs1_0, Data_out1 = Rs2_0, Data_out2 = Rs1_1, Data_out3 = Rs2_1, ...
    wire [31:0] Read_data1_0 = Data_out0;
    wire [31:0] Read_data2_0 = Data_out1;
    wire [31:0] Read_data1_1 = Data_out2;
    wire [31:0] Read_data2_1 = Data_out3;
    wire [31:0] Read_data1_2 = Data_out4;
    wire [31:0] Read_data2_2 = Data_out5;
    wire [31:0] Read_data1_3 = Data_out6;
    wire [31:0] Read_data2_3 = Data_out7;

    // ---------- split WB buses into per-slot signals ----------
    wire [31:0] WB_data0 = WB_data[31:0];
    wire [31:0] WB_data1 = WB_data[63:32];
    wire [31:0] WB_data2 = WB_data[95:64];
    wire [31:0] WB_data3 = WB_data[127:96];

    wire [4:0] WB_addr0 = WB_addr[4:0];
    wire [4:0] WB_addr1 = WB_addr[9:5];
    wire [4:0] WB_addr2 = WB_addr[14:10];
    wire [4:0] WB_addr3 = WB_addr[19:15];

    // ---------- split DE/execute single-bit vectors ----------
    wire DE_MemRead0 = DE_MemRead[0];
    wire DE_MemRead1 = DE_MemRead[1];
    wire DE_MemRead2 = DE_MemRead[2];
    wire DE_MemRead3 = DE_MemRead[3];

    wire E_branch0 = E_branch[0];
    wire E_branch1 = E_branch[1];
    wire E_branch2 = E_branch[2];
    wire E_branch3 = E_branch[3];

    wire E_pred_taken0 = E_pred_taken[0];
    wire E_pred_taken1 = E_pred_taken[1];
    wire E_pred_taken2 = E_pred_taken[2];
    wire E_pred_taken3 = E_pred_taken[3];

    wire E_valid_branch0 = E_valid_branch[0];
    wire E_valid_branch1 = E_valid_branch[1];
    wire E_valid_branch2 = E_valid_branch[2];
    wire E_valid_branch3 = E_valid_branch[3];
    
    wire [4:0] DE_Rd0 = DE_Rd[4:0];
    wire [4:0] DE_Rd1 = DE_Rd[9:5];
    wire [4:0] DE_Rd2 = DE_Rd[14:10];
    wire [4:0] DE_Rd3 = DE_Rd[19:15];

    // ---------- instantiate multi-issue control unit ----------
    Multi_Issue_Control_Unit MICU(
        // inputs (instructions)
        .Instruction_0(Instruction_0),
        .Instruction_1(Instruction_1),
        .Instruction_2(Instruction_2),
        .Instruction_3(Instruction_3),

        .Reset(Reset),

        // control unit 0 outputs
        .Read_reg1_0(Read_reg1_0),
        .Read_reg2_0(Read_reg2_0),
        .Write_reg_0(Write_reg_0),
        .Alu_opcode_0(Alu_opcode_0),
        .Immediate_enable_0(Immediate_enable_0),
        .RegWrite_0(RegWrite_0),
        .Jal_0(Jal_0),
        .Jalr_0(Jalr_0),
        .Load_0(Load_0),
        .Store_0(Store_0),
        .Auipc_0(Auipc_0),
        .Lui_0(Lui_0),
        .Beq_0(Beq_0),
        .Bne_0(Bne_0),
        .Blt_0(Blt_0),
        .Bge_0(Bge_0),
        .Bltu_0(Bltu_0),
        .Bgeu_0(Bgeu_0),
        .Byte_0(Byte_0),
        .Half_0(Half_0),
        .Word_0(Word_0),
        .Unsigned_0(Unsigned_0),
        .ALU_operation_0(ALU_operation_0),
        .Done_0(Done_0),
        .Immediate_0(Immediate_0),

        // control unit 1 outputs
        .Read_reg1_1(Read_reg1_1),
        .Read_reg2_1(Read_reg2_1),
        .Write_reg_1(Write_reg_1),
        .Alu_opcode_1(Alu_opcode_1),
        .Immediate_enable_1(Immediate_enable_1),
        .RegWrite_1(RegWrite_1),
        .Jal_1(Jal_1),
        .Jalr_1(Jalr_1),
        .Load_1(Load_1),
        .Store_1(Store_1),
        .Auipc_1(Auipc_1),
        .Lui_1(Lui_1),
        .Beq_1(Beq_1),
        .Bne_1(Bne_1),
        .Blt_1(Blt_1),
        .Bge_1(Bge_1),
        .Bltu_1(Bltu_1),
        .Bgeu_1(Bgeu_1),
        .Byte_1(Byte_1),
        .Half_1(Half_1),
        .Word_1(Word_1),
        .Unsigned_1(Unsigned_1),
        .ALU_operation_1(ALU_operation_1),
        .Done_1(Done_1),
        .Immediate_1(Immediate_1),

        // control unit 2 outputs
        .Read_reg1_2(Read_reg1_2),
        .Read_reg2_2(Read_reg2_2),
        .Write_reg_2(Write_reg_2),
        .Alu_opcode_2(Alu_opcode_2),
        .Immediate_enable_2(Immediate_enable_2),
        .RegWrite_2(RegWrite_2),
        .Jal_2(Jal_2),
        .Jalr_2(Jalr_2),
        .Load_2(Load_2),
        .Store_2(Store_2),
        .Auipc_2(Auipc_2),
        .Lui_2(Lui_2),
        .Beq_2(Beq_2),
        .Bne_2(Bne_2),
        .Blt_2(Blt_2),
        .Bge_2(Bge_2),
        .Bltu_2(Bltu_2),
        .Bgeu_2(Bgeu_2),
        .Byte_2(Byte_2),
        .Half_2(Half_2),
        .Word_2(Word_2),
        .Unsigned_2(Unsigned_2),
        .ALU_operation_2(ALU_operation_2),
        .Done_2(Done_2),
        .Immediate_2(Immediate_2),

        // control unit 3 outputs
        .Read_reg1_3(Read_reg1_3),
        .Read_reg2_3(Read_reg2_3),
        .Write_reg_3(Write_reg_3),
        .Alu_opcode_3(Alu_opcode_3),
        .Immediate_enable_3(Immediate_enable_3),
        .RegWrite_3(RegWrite_3),
        .Jal_3(Jal_3),
        .Jalr_3(Jalr_3),
        .Load_3(Load_3),
        .Store_3(Store_3),
        .Auipc_3(Auipc_3),
        .Lui_3(Lui_3),
        .Beq_3(Beq_3),
        .Bne_3(Bne_3),
        .Blt_3(Blt_3),
        .Bge_3(Bge_3),
        .Bltu_3(Bltu_3),
        .Bgeu_3(Bgeu_3),
        .Byte_3(Byte_3),
        .Half_3(Half_3),
        .Word_3(Word_3),
        .Unsigned_3(Unsigned_3),
        .ALU_operation_3(ALU_operation_3),
        .Done_3(Done_3),
        .Immediate_3(Immediate_3)
    );

    // ---------- Reg File ----------
    Multi_Issue_Reg_file MIRF(
        .Clk(Clk),
        .Reset(Reset),
        .Data_out0(Data_out0),
        .Data_out1(Data_out1),
        .Data_out2(Data_out2),
        .Data_out3(Data_out3),
        .Data_out4(Data_out4),
        .Data_out5(Data_out5),
        .Data_out6(Data_out6),
        .Data_out7(Data_out7),
        .Display_out(display_out),

        // Writeback inputs
        .WB_en(WB_en),
        .Rd0(WB_addr0), .Rd1(WB_addr1), .Rd2(WB_addr2), .Rd3(WB_addr3),
        .Data_in0(WB_data0), .Data_in1(WB_data1), .Data_in2(WB_data2), .Data_in3(WB_data3),

        // Read addresses (from MICU outputs)
        .Rs1_0(Read_reg1_0), .Rs2_0(Read_reg2_0),
        .Rs1_1(Read_reg1_1), .Rs2_1(Read_reg2_1),
        .Rs1_2(Read_reg1_2), .Rs2_2(Read_reg2_2),
        .Rs1_3(Read_reg1_3), .Rs2_3(Read_reg2_3)
    );

    // ---------- instantiate hazard detection unit ----------
    wire Write0, Stall0;
    wire Write1, Stall1;
    wire Write2, Stall2;
    wire Write3, Stall3;

    Multi_Issue_Hazard_Control MIHC (
        .Reset(Reset), 
        // Slot 0
        .DE_MemRead0(DE_MemRead0),
        .E_branch0(E_branch0),
        .E_pred_taken0(E_pred_taken0),
        .E_valid_branch0(E_valid_branch0),
        .Is_write0(Store_0),
        .Is_load0(Load_0),
        .DE_Rd0(DE_Rd0),
        .FD_Rs1_0(Read_reg1_0),
        .FD_Rs2_0(Read_reg2_0),
        .FD_Rd0(Write_reg_0),

        // Slot 1
        .DE_MemRead1(DE_MemRead1),
        .E_branch1(E_branch1),
        .E_pred_taken1(E_pred_taken1),
        .E_valid_branch1(E_valid_branch1),
        .Is_write1(Store_1),
        .Is_load1(Load_1),
        .DE_Rd1(DE_Rd1),
        .FD_Rs1_1(Read_reg1_1),
        .FD_Rs2_1(Read_reg2_1),
        .FD_Rd1(Write_reg_1),

        // Slot 2
        .DE_MemRead2(DE_MemRead2),
        .E_branch2(E_branch2),
        .E_pred_taken2(E_pred_taken2),
        .E_valid_branch2(E_valid_branch2),
        .Is_write2(Store_2),
        .Is_load2(Load_2),
        .DE_Rd2(DE_Rd2),
        .FD_Rs1_2(Read_reg1_2),
        .FD_Rs2_2(Read_reg2_2),
        .FD_Rd2(Write_reg_2),

        // Slot 3
        .DE_MemRead3(DE_MemRead3),
        .E_branch3(E_branch3),
        .E_pred_taken3(E_pred_taken3),
        .E_valid_branch3(E_valid_branch3),
        .Is_write3(Store_3),
        .Is_load3(Load_3),
        .DE_Rd3(DE_Rd3),
        .FD_Rs1_3(Read_reg1_3),
        .FD_Rs2_3(Read_reg2_3),
        .FD_Rd3(Write_reg_3),

        // Outputs
        .Write0(Write0), .Stall0(Stall0), .Flush(Flush), .FD_write(FD_write),
        .Write1(Write1), .Stall1(Stall1), 
        .Write2(Write2), .Stall2(Stall2),
        .Write3(Write3), .Stall3(Stall3), 
        
        .Num_issued(Num_issued)
    );

    wire [166:0] DE_in0, DE_in1, DE_in2, DE_in3;

    // Expanded to show the format of the reg
    assign DE_in0 = (Stall0) ? {
        167'b0
    } : {
        Pred_take0,            // [166]
        Done_0,                // [165]
        PC_0,                  // [164:133]
        RegWrite_0,            // [132]
        Unsigned_0,            // [131]
        Word_0,                // [130]
        Half_0,                // [129]
        Byte_0,                // [128]
        Store_0,               // [127]
        Load_0,                // [126]
        Bgeu_0,                // [125]
        Bltu_0,                // [124]
        Bge_0,                 // [123]
        Blt_0,                 // [122]
        Bne_0,                 // [121]
        Beq_0,                 // [120]
        Lui_0,                 // [119]
        Auipc_0,               // [118]
        Jalr_0,                // [117]
        Jal_0,                 // [116]
        Immediate_enable_0,    // [115]
        Alu_opcode_0,          // [114:111]
        Write_reg_0,           // [110:106]
        Read_reg2_0,           // [105:101]
        Read_reg1_0,           // [100:96]
        Immediate_0,           // [95:64]
        Read_data2_0,          // [63:32]
        Read_data1_0           // [31:0]
    };

    assign DE_in1 = (Stall1) ? {
        167'b0
        } : {
        Pred_take1, Done_1, PC_1,
        RegWrite_1, Unsigned_1, Word_1, Half_1, Byte_1, Store_1, Load_1,
        Bgeu_1, Bltu_1, Bge_1, Blt_1, Bne_1, Beq_1, Lui_1, Auipc_1,
        Jalr_1, Jal_1, Immediate_enable_1,
        Alu_opcode_1, Write_reg_1, Read_reg2_1, Read_reg1_1,
        Immediate_1, Read_data2_1, Read_data1_1
    };

    assign DE_in2 = (Stall2) ? {
        167'b0
        } : {
        Pred_take2, Done_2, PC_2,
        RegWrite_2, Unsigned_2, Word_2, Half_2, Byte_2, Store_2, Load_2,
        Bgeu_2, Bltu_2, Bge_2, Blt_2, Bne_2, Beq_2, Lui_2, Auipc_2,
        Jalr_2, Jal_2, Immediate_enable_2,
        Alu_opcode_2, Write_reg_2, Read_reg2_2, Read_reg1_2,
        Immediate_2, Read_data2_2, Read_data1_2
    };

    assign DE_in3 = (Stall3) ? {
        167'b0
        } : {
        Pred_take3, Done_3, PC_3,
        RegWrite_3, Unsigned_3, Word_3, Half_3, Byte_3, Store_3, Load_3,
        Bgeu_3, Bltu_3, Bge_3, Blt_3, Bne_3, Beq_3, Lui_3, Auipc_3,
        Jalr_3, Jal_3, Immediate_enable_3,
        Alu_opcode_3, Write_reg_3, Read_reg2_3, Read_reg1_3,
        Immediate_3, Read_data2_3, Read_data1_3
    };

    assign DE_out = { DE_in3, DE_in2, DE_in1, DE_in0 };
    assign PC_en = { Write3, Write2, Write1, Write0 };

endmodule
