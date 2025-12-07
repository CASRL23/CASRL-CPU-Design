//This module tests the register file
module Reg_file_tb();
    wire [31:0] Read_data1, Read_data2;
    reg clk;
    reg reset;
    reg Write;
    reg [4:0] Read_reg1, Read_reg2, Write_reg;
    reg [31:0] Data_in;



    // Instantiate the register file
    Reg_file Reg_file_uut(.clk(clk), .reset(reset),
        .Write(Write),
        .Read_reg1(Read_reg1),
        .Read_reg2(Read_reg2),
        .Write_reg(Write_reg),
        .Data_in(Data_in),
        .Read_data1(Read_data1),
        .Read_data2(Read_data2)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        reset = 1; Write = 0; Read_reg1 = 0; Read_reg2 = 0; Write_reg = 0; Data_in = 32'h0;

        // Apply reset
        #10; reset = 0;

        // Write 0xAAAA5555 to x1
        Write_reg = 5'd1; Data_in = 32'hAAAA5555; Write = 1; #10;


        // Write 0x12345678 to x5
        Write_reg = 5'd5; Data_in = 32'h12345678; Write = 1; #10;


        // Try writing to x0 (should be ignored)
        Write_reg = 5'd0; Data_in = 32'hFFFFFFFF; Write = 1; #10;
        Write = 0;

        // Read x0 and x1
        Read_reg1 = 5'd0; Read_reg2 = 5'd1; #10;

        // Read x5 and x1
        Read_reg1 = 5'd5; Read_reg2 = 5'd1;#10;

        // Write to x31
        Write_reg = 5'd31; Data_in = 32'hDEADBEEF; Write = 1; #10;
        
        //Turn write off
        Write = 0;

        // Read x31 and x5
        Read_reg1 = 5'd31; Read_reg2 = 5'd5;#10;
        $finish;
    end

endmodule
