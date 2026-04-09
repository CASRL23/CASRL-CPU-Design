`timescale 1ns/1ps

module Hazard_detection_tb;
    // Inputs
    reg DE_MemRead, E_branch;
    reg [4:0] DE_Rd, FD_Rs1, FD_Rs2;

    // Outputs
    wire PC_write, FD_write, FD_flush, DE_flush;

    Hazard_detection dut (
        .DE_MemRead(DE_MemRead),
        .E_branch(E_branch),
        .DE_Rd(DE_Rd),
        .FD_Rs1(FD_Rs1),
        .FD_Rs2(FD_Rs2),
        .PC_write(PC_write),
        .FD_write(FD_write),
        .FD_flush(FD_flush),
        .DE_flush(DE_flush)
    );

    initial begin
        // Default case: no hazards
        DE_MemRead = 0; E_branch = 0; DE_Rd = 5'd0; FD_Rs1 = 5'd1; FD_Rs2 = 5'd2;
        #10;

        // Load-use hazard: DE is a load writing to x3, FD needs x3
        DE_MemRead = 1; DE_Rd = 5'd3; FD_Rs1 = 5'd3; FD_Rs2 = 5'd4; E_branch = 0;
        #10;

        // Load-use hazard: DE is a load writing to x5, FD needs x5 on Rs2
        DE_MemRead = 1; DE_Rd = 5'd5; FD_Rs1 = 5'd7; FD_Rs2 = 5'd5; E_branch = 0;
        #10;

        // No hazard: DE is a load but Rd not matching Rs1 or Rs2
        DE_MemRead = 1; DE_Rd = 5'd8; FD_Rs1 = 5'd9; FD_Rs2 = 5'd10; E_branch = 0;
        #10;

        // Branch hazard
        DE_MemRead = 0; DE_Rd = 5'd0; FD_Rs1 = 5'd0; FD_Rs2 = 5'd0; E_branch = 1;
        #10;

        // Combined case: load-use hazard AND branch
        DE_MemRead = 1; DE_Rd = 5'd3; FD_Rs1 = 5'd3; FD_Rs2 = 5'd4; E_branch = 1;
        #10;

        $finish;
    end
endmodule
