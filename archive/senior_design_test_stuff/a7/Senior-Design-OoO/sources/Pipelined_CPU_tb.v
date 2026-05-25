module Pipelined_CPU_tb();
    reg Clk;
    reg Reset;
    wire Done;
    wire [26:0] Display_out;
    
    // Instantiate DUT
    Pipeline_CPU dut (
        .Done(Done),
        .Clk(Clk),
        .Reset(Reset),
        .Display_out(Display_out)
    );

    // Clock
    initial begin
        Clk = 0;
        forever #5 Clk = ~Clk;
    end

    initial begin
        // Apply Reset
        Reset = 1;
        #20;
        Reset = 0;

        // Run simulation for some cycles
        repeat(500) begin
            @(posedge Clk);         
        end

        $finish;
    end

endmodule