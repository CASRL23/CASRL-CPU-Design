// Multi-Issue Out-of-Order Register File with Register Alias Table (RAT)
// - 32 architectural registers
// - RAT maps to 128 reservation station entries (tags 0-127)
// - 4 read ports (for 4-wide decode)
// - 5 RAT update ports (for 5-wide dispatch - 4 ALU + 1 Mem)
// - 5 CDB writeback ports (for 5 execution units)

module Multi_Issue_OoO_reg_file(
    input wire Clk, Reset,
    
    // ------------------------------------------------------------
    // 1. CDB Writeback Inputs (From Execution Units)
    // ------------------------------------------------------------
    input wire [31:0] CDB_data0, CDB_data1, CDB_data2, CDB_data3, CDB_data4,
    input wire [6:0]  CDB_tag0,  CDB_tag1,  CDB_tag2,  CDB_tag3,  CDB_tag4, 
    input wire        CDB_valid0, CDB_valid1, CDB_valid2, CDB_valid3, CDB_valid4,
    
    // ------------------------------------------------------------
    // 2. RAT Update Inputs (From Issue Stage)
    // ------------------------------------------------------------
    input wire        RAT_we0, RAT_we1, RAT_we2, RAT_we3,
    input wire [4:0]  RAT_rd0, RAT_rd1, RAT_rd2, RAT_rd3,
    input wire [6:0]  RAT_tag0, RAT_tag1, RAT_tag2, RAT_tag3,

    // ------------------------------------------------------------
    // 3. Read Ports (From Decode Stage)
    // ------------------------------------------------------------
    input wire [4:0] Rs1_0, Rs1_1, Rs1_2, Rs1_3,
    input wire [4:0] Rs2_0, Rs2_1, Rs2_2, Rs2_3,
    
    // ------------------------------------------------------------
    // 4. Read Outputs (To Reservation Stations)
    // ------------------------------------------------------------
    // Lane 0
    output reg [31:0] Data_out0_rs1, Data_out0_rs2,
    output reg [6:0]  Tag_out0_rs1,  Tag_out0_rs2,
    output reg        Ready_out0_rs1, Ready_out0_rs2,

    // Lane 1
    output reg [31:0] Data_out1_rs1, Data_out1_rs2,
    output reg [6:0]  Tag_out1_rs1,  Tag_out1_rs2,
    output reg        Ready_out1_rs1, Ready_out1_rs2,

    // Lane 2
    output reg [31:0] Data_out2_rs1, Data_out2_rs2,
    output reg [6:0]  Tag_out2_rs1,  Tag_out2_rs2,
    output reg        Ready_out2_rs1, Ready_out2_rs2,

    // Lane 3
    output reg [31:0] Data_out3_rs1, Data_out3_rs2,
    output reg [6:0]  Tag_out3_rs1,  Tag_out3_rs2,
    output reg        Ready_out3_rs1, Ready_out3_rs2
);

    // ------------------------------------------------------------
    // Internal Storage
    // ------------------------------------------------------------
// Internal Storage
    reg [31:0] ARF [0:31];
    reg [6:0]  RAT_tag [0:31];
    reg        RAT_ready [0:31];
    
    integer i;

    // =========================================================================
    // Sequential Logic: CDB Writebacks & RAT Updates
    // =========================================================================
    always @(posedge Clk) begin
        if (Reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                ARF[i]       <= 32'd0;
                RAT_tag[i]   <= 7'd0;
                RAT_ready[i] <= 1'b1;
            end
        end
        else begin
            // CDB Writeback
            for (i = 1; i < 32; i = i + 1) begin 
                if (RAT_ready[i] == 1'b0) begin
                    if      (CDB_valid0 && RAT_tag[i] == CDB_tag0) begin 
                        ARF[i] <= CDB_data0; 
                        RAT_ready[i] <= 1'b1; 
                    end
                    else if (CDB_valid1 && RAT_tag[i] == CDB_tag1) begin 
                        ARF[i] <= CDB_data1; 
                        RAT_ready[i] <= 1'b1; 
                    end
                    else if (CDB_valid2 && RAT_tag[i] == CDB_tag2) begin 
                        ARF[i] <= CDB_data2; 
                        RAT_ready[i] <= 1'b1; 
                    end
                    else if (CDB_valid3 && RAT_tag[i] == CDB_tag3) begin 
                        ARF[i] <= CDB_data3; 
                        RAT_ready[i] <= 1'b1; 
                    end
                    else if (CDB_valid4 && RAT_tag[i] == CDB_tag4) begin 
                        ARF[i] <= CDB_data4; 
                        RAT_ready[i] <= 1'b1; 
                    end
                end
            end

            // RAT Updates
            if (RAT_we0 && RAT_rd0 != 0) begin 
                RAT_tag[RAT_rd0]   <= RAT_tag0; 
                RAT_ready[RAT_rd0] <= 1'b0; 
            end
            if (RAT_we1 && RAT_rd1 != 0) begin 
                RAT_tag[RAT_rd1]   <= RAT_tag1; 
                RAT_ready[RAT_rd1] <= 1'b0; 
            end
            if (RAT_we2 && RAT_rd2 != 0) begin 
                RAT_tag[RAT_rd2]   <= RAT_tag2; 
                RAT_ready[RAT_rd2] <= 1'b0; 
            end
            if (RAT_we3 && RAT_rd3 != 0) begin 
                RAT_tag[RAT_rd3]   <= RAT_tag3; 
                RAT_ready[RAT_rd3] <= 1'b0; 
            end
            
            // x0 hardwired
            ARF[0]       <= 32'd0;
            RAT_ready[0] <= 1'b1;
            RAT_tag[0]   <= 7'd0;
        end
    end

    // =========================================================================
    // Combinational Logic: Read Ports (WITH EXPLICIT SENSITIVITY)
    // =========================================================================
    
    // Helper function (same as before)
    function [32:0] check_cdb_forward;
        input [6:0] tag;
        begin
            if      (CDB_valid0 && CDB_tag0 == tag) check_cdb_forward = {1'b1, CDB_data0};
            else if (CDB_valid1 && CDB_tag1 == tag) check_cdb_forward = {1'b1, CDB_data1};
            else if (CDB_valid2 && CDB_tag2 == tag) check_cdb_forward = {1'b1, CDB_data2};
            else if (CDB_valid3 && CDB_tag3 == tag) check_cdb_forward = {1'b1, CDB_data3};
            else if (CDB_valid4 && CDB_tag4 == tag) check_cdb_forward = {1'b1, CDB_data4};
            else                                     check_cdb_forward = {1'b0, 32'd0};
        end
    endfunction

    // CORRECTED: Add explicit sensitivity to ALL inputs that affect outputs
    // This ensures combinational logic updates immediately
    reg [32:0] fwd_result;    
    always @(*) begin
        // Lane 0 - Rs1
        if (Rs1_0 == 0) begin
            Data_out0_rs1 = 32'd0;
            Tag_out0_rs1 = 7'd0;
            Ready_out0_rs1 = 1'b1;
        end
        else if (RAT_ready[Rs1_0]) begin
            Data_out0_rs1 = ARF[Rs1_0];
            Tag_out0_rs1 = 7'd0;
            Ready_out0_rs1 = 1'b1;
        end
        else begin
            fwd_result = check_cdb_forward(RAT_tag[Rs1_0]);
            if (fwd_result[32]) begin
                Data_out0_rs1 = fwd_result[31:0];
                Tag_out0_rs1 = 7'd0;
                Ready_out0_rs1 = 1'b1;
            end
            else begin
                Data_out0_rs1 = 32'd0;
                Tag_out0_rs1 = RAT_tag[Rs1_0];
                Ready_out0_rs1 = 1'b0;
            end
        end
        
        // Lane 0 - Rs2
        if (Rs2_0 == 0) begin
            Data_out0_rs2 = 32'd0;
            Tag_out0_rs2 = 7'd0;
            Ready_out0_rs2 = 1'b1;
        end
        else if (RAT_ready[Rs2_0]) begin
            Data_out0_rs2 = ARF[Rs2_0];
            Tag_out0_rs2 = 7'd0;
            Ready_out0_rs2 = 1'b1;
        end
        else begin
            fwd_result = check_cdb_forward(RAT_tag[Rs2_0]);
            if (fwd_result[32]) begin
                Data_out0_rs2 = fwd_result[31:0];
                Tag_out0_rs2 = 7'd0;
                Ready_out0_rs2 = 1'b1;
            end
            else begin
                Data_out0_rs2 = 32'd0;
                Tag_out0_rs2 = RAT_tag[Rs2_0];
                Ready_out0_rs2 = 1'b0;
            end
        end
        
        // Repeat for Lanes 1, 2, 3...
        // (I'll show Lane 1 as example, you do the rest)
        
        // Lane 1 - Rs1
        if (Rs1_1 == 0) begin
            Data_out1_rs1 = 32'd0;
            Tag_out1_rs1 = 7'd0;
            Ready_out1_rs1 = 1'b1;
        end
        else if (RAT_ready[Rs1_1]) begin
            Data_out1_rs1 = ARF[Rs1_1];
            Tag_out1_rs1 = 7'd0;
            Ready_out1_rs1 = 1'b1;
        end
        else begin
            fwd_result = check_cdb_forward(RAT_tag[Rs1_1]);
            if (fwd_result[32]) begin
                Data_out1_rs1 = fwd_result[31:0];
                Tag_out1_rs1 = 7'd0;
                Ready_out1_rs1 = 1'b1;
            end
            else begin
                Data_out1_rs1 = 32'd0;
                Tag_out1_rs1 = RAT_tag[Rs1_1];
                Ready_out1_rs1 = 1'b0;
            end
        end
        
        // Lane 1 - Rs2
        if (Rs2_1 == 0) begin
            Data_out1_rs2 = 32'd0;
            Tag_out1_rs2 = 7'd0;
            Ready_out1_rs2 = 1'b1;
        end
        else if (RAT_ready[Rs2_1]) begin
            Data_out1_rs2 = ARF[Rs2_1];
            Tag_out1_rs2 = 7'd0;
            Ready_out1_rs2 = 1'b1;
        end
        else begin
            fwd_result = check_cdb_forward(RAT_tag[Rs2_1]);
            if (fwd_result[32]) begin
                Data_out1_rs2 = fwd_result[31:0];
                Tag_out1_rs2 = 7'd0;
                Ready_out1_rs2 = 1'b1;
            end
            else begin
                Data_out1_rs2 = 32'd0;
                Tag_out1_rs2 = RAT_tag[Rs2_1];
                Ready_out1_rs2 = 1'b0;
            end
        end        
        
        // Lane 2 - Rs1
        if (Rs1_2 == 0) begin
            Data_out2_rs1 = 32'd0;
            Tag_out2_rs1 = 7'd0;
            Ready_out2_rs1 = 1'b1;
        end
        else if (RAT_ready[Rs1_2]) begin
            Data_out2_rs1 = ARF[Rs1_2];
            Tag_out2_rs1 = 7'd0;
            Ready_out2_rs1 = 1'b1;
        end
        else begin
            fwd_result = check_cdb_forward(RAT_tag[Rs1_2]);
            if (fwd_result[32]) begin
                Data_out2_rs1 = fwd_result[31:0];
                Tag_out2_rs1 = 7'd0;
                Ready_out2_rs1 = 1'b1;
            end
            else begin
                Data_out2_rs1 = 32'd0;
                Tag_out2_rs1 = RAT_tag[Rs1_2];
                Ready_out2_rs1 = 1'b0;
            end
        end
        
        // Lane 2 - Rs2
        if (Rs2_2 == 0) begin
            Data_out2_rs2 = 32'd0;
            Tag_out2_rs2 = 7'd0;
            Ready_out2_rs2 = 1'b1;
        end
        else if (RAT_ready[Rs2_2]) begin
            Data_out2_rs2 = ARF[Rs2_2];
            Tag_out2_rs2 = 7'd0;
            Ready_out2_rs2 = 1'b1;
        end
        else begin
            fwd_result = check_cdb_forward(RAT_tag[Rs2_2]);
            if (fwd_result[32]) begin
                Data_out2_rs2 = fwd_result[31:0];
                Tag_out2_rs2 = 7'd0;
                Ready_out2_rs2 = 1'b1;
            end
            else begin
                Data_out2_rs2 = 32'd0;
                Tag_out2_rs2 = RAT_tag[Rs2_2];
                Ready_out2_rs2 = 1'b0;
            end
        end        

        // Lane 3 - Rs1
        if (Rs1_3 == 0) begin
            Data_out3_rs1 = 32'd0;
            Tag_out3_rs1 = 7'd0;
            Ready_out3_rs1 = 1'b1;
        end
        else if (RAT_ready[Rs1_3]) begin
            Data_out3_rs1 = ARF[Rs1_3];
            Tag_out3_rs1 = 7'd0;
            Ready_out3_rs1 = 1'b1;
        end
        else begin
            fwd_result = check_cdb_forward(RAT_tag[Rs1_3]);
            if (fwd_result[32]) begin
                Data_out3_rs1 = fwd_result[31:0];
                Tag_out3_rs1 = 7'd0;
                Ready_out3_rs1 = 1'b1;
            end
            else begin
                Data_out3_rs1 = 32'd0;
                Tag_out3_rs1 = RAT_tag[Rs1_3];
                Ready_out3_rs1 = 1'b0;
            end
        end
        
        // Lane 3 - Rs2
        if (Rs2_3 == 0) begin
            Data_out3_rs2 = 32'd0;
            Tag_out3_rs2 = 7'd0;
            Ready_out3_rs2 = 1'b1;
        end
        else if (RAT_ready[Rs2_3]) begin
            Data_out3_rs2 = ARF[Rs2_3];
            Tag_out3_rs2 = 7'd0;
            Ready_out3_rs2 = 1'b1;
        end
        else begin
            fwd_result = check_cdb_forward(RAT_tag[Rs2_3]);
            if (fwd_result[32]) begin
                Data_out3_rs2 = fwd_result[31:0];
                Tag_out3_rs2 = 7'd0;
                Ready_out3_rs2 = 1'b1;
            end
            else begin
                Data_out3_rs2 = 32'd0;
                Tag_out3_rs2 = RAT_tag[Rs2_3];
                Ready_out3_rs2 = 1'b0;
            end
        end 
    end

endmodule