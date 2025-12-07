module Hazard_detection (
    input  wire DE_MemRead, E_branch, E_pred_taken, E_valid_branch,
    input  wire [4:0] DE_Rd, FD_Rs1, FD_Rs2,
    output reg PC_write, FD_write, FD_flush, DE_flush, Stall
);

    always @(DE_MemRead, DE_Rd, FD_Rs1, FD_Rs2, E_branch, E_pred_taken, E_valid_branch) begin
        // Defaults
        PC_write = 1'b1;
        FD_write = 1'b1;
        FD_flush = 1'b0;
        DE_flush = 1'b0;
        Stall = 1'b0;

        // Load-use hazard: stall F and D, insert bubble into DE (DE_flush)
        if (DE_MemRead && (DE_Rd != 5'b00000) &&
           ((DE_Rd == FD_Rs1) || (DE_Rd == FD_Rs2))) begin
            PC_write = 1'b0;   // freeze PC
            FD_write = 1'b0;   // freeze FD
            Stall = 1'b1;   // used to disable control signals
        end

        // Misprediction
        if ((!E_valid_branch && E_pred_taken) || (E_valid_branch && (E_branch != E_pred_taken))) begin
            FD_flush = 1'b1;
            DE_flush = 1'b1;
            PC_write = 1'b1;
        end
    end

endmodule
