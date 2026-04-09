module Multi_Issue_RS #(
    parameter RS_SIZE = 128,
    parameter DATA_SIZE = 32,
    parameter TAG_SIZE = 7
)(
    input wire Clk, Reset,
    
    // Issue Inputs (Write Port) - 4 lanes
    input wire [DATA_SIZE-1:0] Vj_in0, Vk_in0, PC_in0, Mem_offset_in0,
    input wire [4:0]           Instr_type_in0,
    input wire [TAG_SIZE-1:0]  Issue_idx0, 
    input wire [TAG_SIZE:0]    Rs1_0_tag, Rs2_0_tag, 
    input wire                 Pred_take_in0,
    input wire                 Issue_RQ0,
    
    input wire [DATA_SIZE-1:0] Vj_in1, Vk_in1, PC_in1, Mem_offset_in1,
    input wire [4:0]           Instr_type_in1,
    input wire [TAG_SIZE-1:0]  Issue_idx1, 
    input wire [TAG_SIZE:0]    Rs1_1_tag, Rs2_1_tag, 
    input wire                 Pred_take_in1,
    input wire                 Issue_RQ1,    
    
    input wire [DATA_SIZE-1:0] Vj_in2, Vk_in2, PC_in2, Mem_offset_in2,
    input wire [4:0]           Instr_type_in2,
    input wire [TAG_SIZE-1:0]  Issue_idx2, 
    input wire [TAG_SIZE:0]    Rs1_2_tag, Rs2_2_tag, 
    input wire                 Pred_take_in2,
    input wire                 Issue_RQ2,    
    
    input wire [DATA_SIZE-1:0] Vj_in3, Vk_in3, PC_in3, Mem_offset_in3,
    input wire [4:0]           Instr_type_in3,
    input wire [TAG_SIZE-1:0]  Issue_idx3, 
    input wire [TAG_SIZE:0]    Rs1_3_tag, Rs2_3_tag,
    input wire                 Pred_take_in3,     
    input wire                 Issue_RQ3,      
    
    // Dispatch Inputs (Read/Free Port) - 5 lanes
    input wire [TAG_SIZE-1:0] Dispatch_0, Dispatch_1, Dispatch_2, Dispatch_3, Dispatch_4,
    input wire                Dispatch_valid0, Dispatch_valid1, Dispatch_valid2, Dispatch_valid3, Dispatch_valid4,
    
    // CDB Snooping Inputs (Wakeup Port) - 5 lanes
    input wire [DATA_SIZE-1:0] CDB_result0, CDB_result1, CDB_result2, CDB_result3, CDB_result4,
    input wire [TAG_SIZE-1:0]  CDB_tag0, CDB_tag1, CDB_tag2, CDB_tag3, CDB_tag4,
    input wire                 CDB_valid0, CDB_valid1, CDB_valid2, CDB_valid3, CDB_valid4,
        
    // Execute Outputs (To ALU/Mem)
    output wire [DATA_SIZE-1:0] Vj_out0, Vk_out0, PC_out0, Mem_offset_out0,
    output wire [4:0]           Instr_type_out0, 
    output wire                 Pred_take_out0,
    
    output wire [DATA_SIZE-1:0] Vj_out1, Vk_out1, PC_out1, Mem_offset_out1,
    output wire [4:0]           Instr_type_out1,     
    output wire                 Pred_take_out1,
    
    output wire [DATA_SIZE-1:0] Vj_out2, Vk_out2, PC_out2, Mem_offset_out2,
    output wire [4:0]           Instr_type_out2, 
    output wire                 Pred_take_out2,    
    
    output wire [DATA_SIZE-1:0] Vj_out3, Vk_out3, PC_out3, Mem_offset_out3,
    output wire [4:0]           Instr_type_out3,
    output wire                 Pred_take_out3,    
    
    output wire [DATA_SIZE-1:0] Vj_out4, Vk_out4, PC_out4, Mem_offset_out4,
    output wire [4:0]           Instr_type_out4,            
    
    // Status Outputs (To Issue & Dispatch Units)
    output reg [RS_SIZE-1:0] Busy_out,
    output reg [RS_SIZE-1:0] Ready_out,
    output reg [RS_SIZE-1:0] Is_mem_out
);

    // Internal Storage Arrays
    reg [RS_SIZE-1:0] Busy; 
    reg [RS_SIZE-1:0] Is_mem;
    
    reg Pred_take [0:RS_SIZE-1];
    reg [DATA_SIZE-1:0] Vj [0:RS_SIZE-1];
    reg [DATA_SIZE-1:0] Vk [0:RS_SIZE-1];
    reg [DATA_SIZE-1:0] PC [0:RS_SIZE-1];
    reg [DATA_SIZE-1:0] Mem_offset [0:RS_SIZE-1];
    reg [4:0]           I_type [0:RS_SIZE-1];
    
    reg [TAG_SIZE:0] Qj [0:RS_SIZE-1]; 
    reg [TAG_SIZE:0] Qk [0:RS_SIZE-1];

    integer i;

    // ============================================================
    // Combinational Logic: Dispatch Read & Status
    // ============================================================
    // FIX: Add all output assignments
    assign Vj_out0         = Vj[Dispatch_0];
    assign Vk_out0         = Vk[Dispatch_0];
    assign PC_out0         = PC[Dispatch_0];
    assign Mem_offset_out0 = Mem_offset[Dispatch_0];
    assign Instr_type_out0 = I_type[Dispatch_0];
    assign Pred_take_out0  = Pred_take[Dispatch_0];    

    assign Vj_out1         = Vj[Dispatch_1];
    assign Vk_out1         = Vk[Dispatch_1];
    assign PC_out1         = PC[Dispatch_1];
    assign Mem_offset_out1 = Mem_offset[Dispatch_1];
    assign Instr_type_out1 = I_type[Dispatch_1];
    assign Pred_take_out1  = Pred_take[Dispatch_1];    

    assign Vj_out2         = Vj[Dispatch_2];
    assign Vk_out2         = Vk[Dispatch_2];
    assign PC_out2         = PC[Dispatch_2];
    assign Mem_offset_out2 = Mem_offset[Dispatch_2];
    assign Instr_type_out2 = I_type[Dispatch_2];
    assign Pred_take_out2  = Pred_take[Dispatch_2];    

    assign Vj_out3         = Vj[Dispatch_3];
    assign Vk_out3         = Vk[Dispatch_3];
    assign PC_out3         = PC[Dispatch_3];
    assign Mem_offset_out3 = Mem_offset[Dispatch_3];
    assign Instr_type_out3 = I_type[Dispatch_3];
    assign Pred_take_out3  = Pred_take[Dispatch_3];    

    assign Vj_out4         = Vj[Dispatch_4];
    assign Vk_out4         = Vk[Dispatch_4];
    assign PC_out4         = PC[Dispatch_4];
    assign Mem_offset_out4 = Mem_offset[Dispatch_4];
    assign Instr_type_out4 = I_type[Dispatch_4];


    always @* begin
        Busy_out = Busy;
        for (i = 0; i < RS_SIZE; i = i+1) begin
            Ready_out[i] = Busy[i] && Qj[i][TAG_SIZE] && Qk[i][TAG_SIZE];
            Is_mem_out[i] = Is_mem[i];
        end
    end

    // ============================================================
    // Sequential Logic: Issue, Wakeup, Free
    // ============================================================
    always @(posedge Clk) begin
        if (Reset) begin
            Busy <= {RS_SIZE{1'b0}};
            Is_mem <= {RS_SIZE{1'b0}};
        end
        else begin       
            
            // DISPATCH (Clear Busy)
            if (Dispatch_valid0) begin
                Busy[Dispatch_0] <= 1'b0;
            end
            if (Dispatch_valid1) begin
                Busy[Dispatch_1] <= 1'b0;
            end
            if (Dispatch_valid2) begin
                Busy[Dispatch_2] <= 1'b0;
            end
            if (Dispatch_valid3) begin
                Busy[Dispatch_3] <= 1'b0;
            end
            if (Dispatch_valid4) begin
                Busy[Dispatch_4] <= 1'b0;
                Is_mem[Dispatch_4] <= 1'b0;
            end
            // ISSUE (Write New Entry)
            // Issue 0
            if (Issue_RQ0) begin
                Busy[Issue_idx0] <= 1'b1;
                PC[Issue_idx0]         <= PC_in0;
                Mem_offset[Issue_idx0] <= Mem_offset_in0;
                I_type[Issue_idx0]     <= Instr_type_in0;
                
                Vj[Issue_idx0] <= Vj_in0;
                Qj[Issue_idx0] <= Rs1_0_tag;
                
                Vk[Issue_idx0] <= Vk_in0;
                Qk[Issue_idx0] <= Rs2_0_tag;

                Is_mem[Issue_idx0] <= (Instr_type_in0 >= 5'd10 && Instr_type_in0 <= 5'd17);

                Pred_take[Issue_idx0] <= Pred_take_in0;
            end
            
            // Issue 1 - FIX: Use Issue_idx1 for PC, not Issue_idx0
            if (Issue_RQ1) begin
                Busy[Issue_idx1] <= 1'b1;
                PC[Issue_idx1]         <= PC_in1;  // FIXED
                Mem_offset[Issue_idx1] <= Mem_offset_in1;
                I_type[Issue_idx1]     <= Instr_type_in1;
                
                Vj[Issue_idx1] <= Vj_in1;
                Qj[Issue_idx1] <= Rs1_1_tag;
                
                Vk[Issue_idx1] <= Vk_in1;
                Qk[Issue_idx1] <= Rs2_1_tag;

                Is_mem[Issue_idx1] <= (Instr_type_in1 >= 5'd10 && Instr_type_in1 <= 5'd17);
            
                Pred_take[Issue_idx1] <= Pred_take_in1;            
            end            

            // Issue 2 - FIX: Use Vk_in2, not Vk_in0
            if (Issue_RQ2) begin
                Busy[Issue_idx2] <= 1'b1;
                PC[Issue_idx2]         <= PC_in2;
                Mem_offset[Issue_idx2] <= Mem_offset_in2;
                I_type[Issue_idx2]     <= Instr_type_in2;
                
                Vj[Issue_idx2] <= Vj_in2;
                Qj[Issue_idx2] <= Rs1_2_tag;
                
                Vk[Issue_idx2] <= Vk_in2;  // FIXED
                Qk[Issue_idx2] <= Rs2_2_tag;

                Is_mem[Issue_idx2] <= (Instr_type_in2 >= 5'd10 && Instr_type_in2 <= 5'd17);
            
                Pred_take[Issue_idx2] <= Pred_take_in2;            
            end
            
            // Issue 3
            if (Issue_RQ3) begin
                Busy[Issue_idx3] <= 1'b1;
                PC[Issue_idx3]         <= PC_in3;
                Mem_offset[Issue_idx3] <= Mem_offset_in3;
                I_type[Issue_idx3]     <= Instr_type_in3;
                
                Vj[Issue_idx3] <= Vj_in3;
                Qj[Issue_idx3] <= Rs1_3_tag;
                
                Vk[Issue_idx3] <= Vk_in3;
                Qk[Issue_idx3] <= Rs2_3_tag;

                Is_mem[Issue_idx3] <= (Instr_type_in3 >= 5'd10 && Instr_type_in3 <= 5'd17);
            
                Pred_take[Issue_idx3] <= Pred_take_in3;            
            end  
                        
            
            // WAKEUP (CDB Snooping) - Simplified
            for (i = 0; i < RS_SIZE; i = i + 1) begin
                if (Busy[i]) begin
                    // CDB 0
                    if (CDB_valid0) begin
                        if (Qj[i][TAG_SIZE] == 1'b0 && Qj[i][TAG_SIZE-1:0] == CDB_tag0) begin
                            Vj[i] <= CDB_result0;
                            Qj[i] <= {1'b1, {TAG_SIZE{1'b0}}}; 
                        end
                        if (Qk[i][TAG_SIZE] == 1'b0 && Qk[i][TAG_SIZE-1:0] == CDB_tag0) begin
                            Vk[i] <= CDB_result0;
                            Qk[i] <= {1'b1, {TAG_SIZE{1'b0}}}; 
                        end
                    end
                    
                    // CDB 1
                    if (CDB_valid1) begin
                        if (Qj[i][TAG_SIZE] == 1'b0 && Qj[i][TAG_SIZE-1:0] == CDB_tag1) begin
                            Vj[i] <= CDB_result1;
                            Qj[i] <= {1'b1, {TAG_SIZE{1'b0}}}; 
                        end
                        if (Qk[i][TAG_SIZE] == 1'b0 && Qk[i][TAG_SIZE-1:0] == CDB_tag1) begin
                            Vk[i] <= CDB_result1;
                            Qk[i] <= {1'b1, {TAG_SIZE{1'b0}}}; 
                        end
                    end
                    
                    // CDB 2
                    if (CDB_valid2) begin
                        if (Qj[i][TAG_SIZE] == 1'b0 && Qj[i][TAG_SIZE-1:0] == CDB_tag2) begin
                            Vj[i] <= CDB_result2;
                            Qj[i] <= {1'b1, {TAG_SIZE{1'b0}}}; 
                        end
                        if (Qk[i][TAG_SIZE] == 1'b0 && Qk[i][TAG_SIZE-1:0] == CDB_tag2) begin
                            Vk[i] <= CDB_result2;
                            Qk[i] <= {1'b1, {TAG_SIZE{1'b0}}}; 
                        end
                    end
                    
                    // CDB 3
                    if (CDB_valid3) begin
                        if (Qj[i][TAG_SIZE] == 1'b0 && Qj[i][TAG_SIZE-1:0] == CDB_tag3) begin
                            Vj[i] <= CDB_result3;
                            Qj[i] <= {1'b1, {TAG_SIZE{1'b0}}}; 
                        end
                        if (Qk[i][TAG_SIZE] == 1'b0 && Qk[i][TAG_SIZE-1:0] == CDB_tag3) begin
                            Vk[i] <= CDB_result3;
                            Qk[i] <= {1'b1, {TAG_SIZE{1'b0}}}; 
                        end
                    end
                    
                    // CDB 4
                    if (CDB_valid4) begin
                        if (Qj[i][TAG_SIZE] == 1'b0 && Qj[i][TAG_SIZE-1:0] == CDB_tag4) begin
                            Vj[i] <= CDB_result4;
                            Qj[i] <= {1'b1, {TAG_SIZE{1'b0}}}; 
                        end
                        if (Qk[i][TAG_SIZE] == 1'b0 && Qk[i][TAG_SIZE-1:0] == CDB_tag4) begin
                            Vk[i] <= CDB_result4;
                            Qk[i] <= {1'b1, {TAG_SIZE{1'b0}}}; 
                        end
                    end
                end
            end
        end
    end

endmodule