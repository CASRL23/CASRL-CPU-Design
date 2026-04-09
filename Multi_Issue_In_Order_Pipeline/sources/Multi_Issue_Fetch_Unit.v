`timescale 10ns/1ps
module Multi_Issue_Fetch_Unit(
    input wire Clk, Reset, Fetch_done,
    input wire [2:0] Num_issued,
    input wire [3:0] PC_enable, Pred_taken, Pred_miss,
    input wire [31:0] Pred_target0, Pred_target1, Pred_target2, Pred_target3,
    input wire [31:0] Miss_target0, Miss_target1, Miss_target2, Miss_target3,
    input wire [31:0] PC_connect, 
    output reg [31:0] PC0, PC1, PC2, PC3
);

// --- Control Logic ---
always @(posedge Clk or posedge Reset) begin
    if (Reset) begin
        PC0 <= 32'h00000000;
        PC1 <= 32'h00000004;
        PC2 <= 32'h00000008;
        PC3 <= 32'h0000000C;
    end
    else if (!Fetch_done) begin
        // --- MISPREDICT (highest priority) ---
        if (Pred_miss[0]) begin
            PC0 <= Miss_target0;
            PC1 <= Miss_target0 + 32'd4;
            PC2 <= Miss_target0 + 32'd8;
            PC3 <= Miss_target0 + 32'd12;
        end 
        else if (Pred_miss[1]) begin
            PC0 <= Miss_target1;
            PC1 <= Miss_target1 + 32'd4;
            PC2 <= Miss_target1 + 32'd8;
            PC3 <= Miss_target1 + 32'd12;
        end 
        else if (Pred_miss[2]) begin
            PC0 <= Miss_target2;
            PC1 <= Miss_target2 + 32'd4;
            PC2 <= Miss_target2 + 32'd8;
            PC3 <= Miss_target2 + 32'd12;
        end 
        else if (Pred_miss[3]) begin
            PC0 <= Miss_target3;
            PC1 <= Miss_target3 + 32'd4;
            PC2 <= Miss_target3 + 32'd8;
            PC3 <= Miss_target3 + 32'd12;
        end
        
        // --- PREDICT TAKEN ---
        else if (Pred_taken[0] && (Num_issued >= 3'd1)) begin
            PC0 <= Pred_target0;
            PC1 <= Pred_target0 + 32'd4;
            PC2 <= Pred_target0 + 32'd8;
            PC3 <= Pred_target0 + 32'd12;
        end 
        else if (Pred_taken[1] && (Num_issued >= 3'd2)) begin
            PC0 <= Pred_target1;
            PC1 <= Pred_target1 + 32'd4;
            PC2 <= Pred_target1 + 32'd8;
            PC3 <= Pred_target1 + 32'd12;
        end 
        else if (Pred_taken[2] && (Num_issued >= 3'd3)) begin
            PC0 <= Pred_target2;
            PC1 <= Pred_target2 + 32'd4;
            PC2 <= Pred_target2 + 32'd8;
            PC3 <= Pred_target2 + 32'd12;
        end 
        else if (Pred_taken[3] && (Num_issued == 3'd4)) begin
            PC0 <= Pred_target3;
            PC1 <= Pred_target3 + 32'd4;
            PC2 <= Pred_target3 + 32'd8;
            PC3 <= Pred_target3 + 32'd12;
        end
        
        // --- DEFAULT: Sequential fetch from PC_connect ---
        else begin
            PC0 <= PC_connect;
            PC1 <= PC_connect + 32'd4;
            PC2 <= PC_connect + 32'd8;
            PC3 <= PC_connect + 32'd12;
        end
    end
end

endmodule
