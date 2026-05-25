`timescale 1ns/1ps

module Branch_predictor_tb;

    wire Pred_taken;
    wire [31:0] Pred_target;

    reg Clk, Reset, Update_en, Update_taken;
    reg [31:0] Update_pc, Update_target, PC;

    // DUT
    Branch_predictor dut (
        .Clk(Clk),
        .Reset(Reset),
        .PC(PC),
        .Pred_taken(Pred_taken),
        .Pred_target(Pred_target),
        .Update_en(Update_en),
        .Update_taken(Update_taken),
        .Update_pc(Update_pc),
        .Update_target(Update_target)
    );

    // clock gen
    always #5 Clk = ~Clk;

    initial begin
      
        // init
        Clk = 0;
        Reset = 1;
        PC = 32'h0;
        Update_en = 0;
        Update_taken = 0;
        Update_pc = 0;
        Update_target = 0;

        // hold reset a few cycles
        #20 Reset = 0;

        // Query prediction at PC=0x10
        PC = 32'h10;
        #10;

        // Train branch at PC=0x10 as TAKEN with target=0x100
        Update_en     = 1;
        Update_pc     = 32'h10;
        Update_taken  = 1;
        Update_target = 32'h100;
        #10 Update_en = 0;

        // Query again at PC=0x10
        PC = 32'h10;
        #10;

        // Branch as NOT TAKEN (same PC)
        Update_en     = 1;
        Update_pc     = 32'h10;
        Update_taken  = 0;
        Update_target = 32'h100; // ignored because not taken
        #10 Update_en = 0;

        // Query again
        PC = 32'h10;
        #10;

        // Taken multiple times to saturate counter
        repeat(4) begin
            Update_en     = 1;
            Update_pc     = 32'h10;
            Update_taken  = 1;
            Update_target = 32'h100;
            #10 Update_en = 0;
            #10;
        end

        // Query final prediction
        PC = 32'h10;
        #10;

        $finish;
    end

endmodule
