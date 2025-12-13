`timescale 10ns / 1ps


module Multi_Issue_BP(
    input  wire        Clk, Reset,

    // ---- 4 parallel fetch ports ----
    input  wire [31:0] PC0, PC1, PC2, PC3,
    output wire        Pred_taken0, Pred_taken1, Pred_taken2, Pred_taken3,
    output wire [31:0] Pred_target0, Pred_target1, Pred_target2, Pred_target3,

    // ---- 4 update ports ----
    input  wire        Update_en0, Update_taken0,
    input  wire [31:0] Update_pc0, Update_target0,

    input  wire        Update_en1, Update_taken1,
    input  wire [31:0] Update_pc1, Update_target1,

    input  wire        Update_en2, Update_taken2,
    input  wire [31:0] Update_pc2, Update_target2,

    input  wire        Update_en3, Update_taken3,
    input  wire [31:0] Update_pc3, Update_target3
);

    // Indexing
    wire [7:0] idx_if0 = PC0[9:2];
    wire [7:0] idx_if1 = PC1[9:2];
    wire [7:0] idx_if2 = PC2[9:2];
    wire [7:0] idx_if3 = PC3[9:2];

    wire [7:0] idx_up0 = Update_pc0[9:2];
    wire [7:0] idx_up1 = Update_pc1[9:2];
    wire [7:0] idx_up2 = Update_pc2[9:2];
    wire [7:0] idx_up3 = Update_pc3[9:2];

    // Predictor tables
    reg [1:0]  state [0:255];   // 2-bit counters
    reg [31:0] btb   [0:255];   // BTB entries

    integer i;

    // ---- Prediction Outputs ----
    assign Pred_taken0  = state[idx_if0][1];
    assign Pred_target0 = btb[idx_if0];

    assign Pred_taken1  = state[idx_if1][1];
    assign Pred_target1 = btb[idx_if1];

    assign Pred_taken2  = state[idx_if2][1];
    assign Pred_target2 = btb[idx_if2];

    assign Pred_taken3  = state[idx_if3][1];
    assign Pred_target3 = btb[idx_if3];

    // ---- Update Logic ----
    always @(posedge Clk or posedge Reset) begin
        if (Reset) begin
            for (i = 0; i < 256; i = i + 1) begin
                state[i] <= 2'b01;
                btb[i]   <= 32'd0;
            end
        end else begin

            // Only one mispredict per cycle: oldest (lowest index) wins
            if (Update_en0) begin
                case (state[idx_up0])
                    2'b00: state[idx_up0] <= Update_taken0 ? 2'b01 : 2'b00;
                    2'b01: state[idx_up0] <= Update_taken0 ? 2'b10 : 2'b00;
                    2'b10: state[idx_up0] <= Update_taken0 ? 2'b11 : 2'b01;
                    2'b11: state[idx_up0] <= Update_taken0 ? 2'b11 : 2'b10;
                endcase
                if (Update_taken0)
                    btb[idx_up0] <= Update_target0;
            end 
            else if (Update_en1) begin
                case (state[idx_up1])
                    2'b00: state[idx_up1] <= Update_taken1 ? 2'b01 : 2'b00;
                    2'b01: state[idx_up1] <= Update_taken1 ? 2'b10 : 2'b00;
                    2'b10: state[idx_up1] <= Update_taken1 ? 2'b11 : 2'b01;
                    2'b11: state[idx_up1] <= Update_taken1 ? 2'b11 : 2'b10;
                endcase
                if (Update_taken1)
                    btb[idx_up1] <= Update_target1;
            end 
            else if (Update_en2) begin
                case (state[idx_up2])
                    2'b00: state[idx_up2] <= Update_taken2 ? 2'b01 : 2'b00;
                    2'b01: state[idx_up2] <= Update_taken2 ? 2'b10 : 2'b00;
                    2'b10: state[idx_up2] <= Update_taken2 ? 2'b11 : 2'b01;
                    2'b11: state[idx_up2] <= Update_taken2 ? 2'b11 : 2'b10;
                endcase
                if (Update_taken2)
                    btb[idx_up2] <= Update_target2;
            end 
            else if (Update_en3) begin
                case (state[idx_up3])
                    2'b00: state[idx_up3] <= Update_taken3 ? 2'b01 : 2'b00;
                    2'b01: state[idx_up3] <= Update_taken3 ? 2'b10 : 2'b00;
                    2'b10: state[idx_up3] <= Update_taken3 ? 2'b11 : 2'b01;
                    2'b11: state[idx_up3] <= Update_taken3 ? 2'b11 : 2'b10;
                endcase
                if (Update_taken3)
                    btb[idx_up3] <= Update_target3;
            end
        end
    end
endmodule
