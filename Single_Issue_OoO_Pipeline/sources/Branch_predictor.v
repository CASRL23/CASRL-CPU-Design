// direct-mapped BTB with 16 entries and 2-bit counters
module Branch_predictor (
    input wire Clk, Reset, Update_en, Update_taken, 
    input wire [31:0] PC, Update_pc, Update_target, 
    output wire Pred_taken, 
    output wire [31:0] Pred_target 
);

    // 256 entries 
    wire [7:0] idx_if     = PC[9:2];
    wire [7:0] idx_update = Update_pc[9:2];
    
    reg [1:0]  state [0:255];   // 2-bit saturating counters
    reg [31:0] btb   [0:255];   // branch target buffer
    
    integer i;
    
    // Prediction
    assign Pred_taken  = state[idx_if][1]; // MSB = predict taken
    assign Pred_target = btb[idx_if];      
    
    // Update logic
    always @(posedge Clk or posedge Reset) begin
        if (Reset) begin
            for (i=0; i<256; i=i+1) begin
                state[i] <= 2'b01;   // weak not-taken
                btb[i]   <= 32'd0;   // clear BTB
            end
        end else if (Update_en) begin
            // Update the counter with saturation
            case (state[idx_update])
                2'b00: state[idx_update] <= Update_taken ? 2'b01 : 2'b00;
                2'b01: state[idx_update] <= Update_taken ? 2'b10 : 2'b00;
                2'b10: state[idx_update] <= Update_taken ? 2'b11 : 2'b01;
                2'b11: state[idx_update] <= Update_taken ? 2'b11 : 2'b10;
            endcase
    
            // Update BTB only if taken
            if (Update_taken) begin
                btb[idx_update] <= Update_target;
            end
        end
    end

endmodule
