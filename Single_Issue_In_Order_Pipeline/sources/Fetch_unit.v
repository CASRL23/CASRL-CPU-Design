module Fetch_unit(
    input  wire Clk, Reset, Pc_enable, Jalr, Fetch_done, Pred_taken,
    input  wire Misprediction,  
    input  wire [31:0] Pred_target, Jalr_target, PC_current, Branch_target, PC_correction,  // ← Add PC_correction
    output reg  [31:0] PC
);
    // Synchronous PC update logic
    always @(posedge Clk or posedge Reset) begin
        if (Reset) begin
            PC <= 32'h00000000;         // Reset PC to 0
        end
        else if (Pc_enable && !Fetch_done) begin
            if (Misprediction) begin
                PC <= PC_correction;
            end
            else if (Jalr) begin
                PC <= Jalr_target & 32'hfffffffe;  // JALR target
            end
            else if (Pred_taken) begin
                PC <= Pred_target;
            end
            else begin
                PC <= PC_current + 32'h00000004;    // Default: PC + 4
            end
        end
        else begin
            PC <= PC_current;                       // Hold (stall)
        end
    end
endmodule