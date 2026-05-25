`timescale 1ns / 1ps
module CPU_tb();
    reg CLK_125_P;
    reg CLK_125_N;
    reg Reset;
    wire Done;
    wire [31:0] Display_out;  // Add this
    
    // Instantiate DUT
    CPU dut (
        .Done(Done),
        .Display_out(Display_out),  // Connect it
        .CLK_125_P(CLK_125_P),
        .CLK_125_N(CLK_125_N),
        .Reset(Reset)
    );
    
    integer i;
    
    // Generate 125 MHz differential clock (for input to MMCM)
    initial begin
        CLK_125_P = 0;
        CLK_125_N = 1;
        forever begin
            #4 CLK_125_P = ~CLK_125_P;
            CLK_125_N = ~CLK_125_P;
        end
    end
    
    // Monitor Display_out
    always @(Display_out) begin
        if (Display_out !== 32'bx)  // Only display if not unknown
            $display("Time %0t: Display_out = 0x%08h (%0d)", $time, Display_out, Display_out);
    end
    
    // Reset and simulation control
    initial begin
        Reset = 1;
        #200;  // Wait for MMCM to lock
        Reset = 0;
        #20;
        
        // Wait for Done or timeout
        for (i = 0; i < 20000; i = i + 1) begin
            @(posedge CLK_125_P);  // Can wait on input clock
            if (Done) begin
                $display("========================================");
                $display("Program completed at time %0t", $time);
                $display("Final Display_out = 0x%08h (%0d)", Display_out, Display_out);
                $display("========================================");
                #100;
                $finish;
            end
        end
        
        $display("Timeout!");
        $finish;
    end
    
endmodule