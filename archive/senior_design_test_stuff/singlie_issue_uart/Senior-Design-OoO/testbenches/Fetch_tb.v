module Fetch_unit_tb;

    // Inputs
    reg [31:0] Pc_prev;
    reg [31:0] Branch_target;
    reg [31:0] Jalr_target;
    reg Branch;
    reg Jalr;
    reg Pc_enable;
    reg Reset;
    reg Clk;

    // Outputs
    wire [31:0] Pc_next;

    // Instantiate Fetch_unit
    Fetch_unit uut (
        .Pc_next(Pc_next),
        .Pc_prev(Pc_prev),
        .Branch_target(Branch_target),
        .Jalr_target(Jalr_target),
        .Branch(Branch),
        .Jalr(Jalr),
        .Pc_enable(Pc_enable),
        .Reset(Reset),
        .Clk(Clk)
    );

    // Clock generation: 10ns period
    initial Clk = 0;
    always #5 Clk = ~Clk;

    initial begin
        // Initialize inputs
        Pc_prev = 32'h00000000;
        Branch_target = 32'h00000020;
        Jalr_target = 32'h00000040;
        Branch = 0; Jalr = 0; Pc_enable = 0; Reset = 1;

        // Hold reset for a few cycles
        #12; Reset = 0;Pc_enable = 1;

        // First PC increment (PC+4)
        Pc_prev = Pc_next; #10;
        // Branch taken
        Branch = 1; Pc_prev = Pc_next; #10; Branch = 0;

        // JALR taken
        Jalr = 1; Pc_prev = Pc_next;#10; Jalr = 0;

        // Another PC increment
        Pc_prev = Pc_next; #10; #10;
        $finish;
    end

endmodule
