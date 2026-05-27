//`define MAX_CYCLES 1000
//`define PROGRAM_0_EXPECTED 5
//`define PROGRAM_1_EXPECTED 2
//`define PROGRAM_2_EXPECTED 5
//`define PROGRAM_3_EXPECTED 15
//`define PROGRAM_4_EXPECTED 8
//`define PROGRAM_5_EXPECTED 32'b00000000000000000000000000100000
//`define PROGRAM_6_EXPECTED 1
//`define PROGRAM_7_EXPECTED 32'hffff0000
//`define PROGRAM_8_EXPECTED 0
//`define PROGRAM_9_EXPECTED 1
//`define PROGRAM_10_EXPECTED 0
//`define PROGRAM_11_EXPECTED 1
//`define PROGRAM_12_EXPECTED 0
//`define PROGRAM_13_EXPECTED 1
//`define PROGRAM_14_EXPECTED 1
//`define PROGRAM_15_EXPECTED 0
//`define PROGRAM_16_EXPECTED 8
//`define PROGRAM_17_EXPECTED -2
//`define PROGRAM_18_EXPECTED 32'h0000000f
//`define PROGRAM_19_EXPECTED 32'h000000f0
//`define PROGRAM_20_EXPECTED 32'h000000f0
//`define PROGRAM_21_EXPECTED 1
//`define PROGRAM_22_EXPECTED 0
//`define PROGRAM_23_EXPECTED 0
//`define PROGRAM_24_EXPECTED 1
//`define PROGRAM_25_EXPECTED 0
//`define PROGRAM_26_EXPECTED 1
//`define PROGRAM_27_EXPECTED 0
//`define PROGRAM_28_EXPECTED 1
//`define PROGRAM_29_EXPECTED 0
//`define PROGRAM_30_EXPECTED 32'h80000000
//`define PROGRAM_31_EXPECTED 32'h00000001
//`define PROGRAM_32_EXPECTED 32'hffffffff
//`define PROGRAM_33_EXPECTED 32'h00000001
//`define PROGRAM_34_EXPECTED 32'hffffffff // Verify if these cases are correct
//`define PROGRAM_35_EXPECTED 32'h0000ffff // How far is Sign extension supposed to go?
//`define PROGRAM_36_EXPECTED 32'hffffffff 
//`define PROGRAM_37_EXPECTED 32'hffffff00 
//`define PROGRAM_38_EXPECTED 32'h000000ff
//`define PROGRAM_39_EXPECTED 32'h000000ff 
//`define PROGRAM_40_EXPECTED 32'h0000007f 
//`define PROGRAM_41_EXPECTED 32'h0000ffff 
//`define PROGRAM_42_EXPECTED 32'h000000ff 
//`define PROGRAM_43_EXPECTED 1
//`define PROGRAM_44_EXPECTED 0
//`define PROGRAM_45_EXPECTED 1
//`define PROGRAM_46_EXPECTED 0
//`define PROGRAM_47_EXPECTED 1
//`define PROGRAM_48_EXPECTED 0
//`define PROGRAM_49_EXPECTED -1
//`define PROGRAM_50_EXPECTED 0
//`define PROGRAM_51_EXPECTED -2
//`define PROGRAM_52_EXPECTED 0
//`define PROGRAM_53_EXPECTED 2
//`define PROGRAM_54_EXPECTED 0
//`define PROGRAM_55_EXPECTED 2
//`define PROGRAM_56_EXPECTED 2
//`define PROGRAM_57_EXPECTED 0
//`define PROGRAM_58_EXPECTED -2
//`define PROGRAM_59_EXPECTED 0
//`define PROGRAM_60_EXPECTED 1
//`define PROGRAM_61_EXPECTED 0
//`define PROGRAM_62_EXPECTED 0
//`define PROGRAM_63_EXPECTED 1
//`define PROGRAM_64_EXPECTED -2
//`define PROGRAM_65_EXPECTED 0
//`define PROGRAM_66_EXPECTED 0
//`define PROGRAM_67_EXPECTED 0
//`define PROGRAM_68_EXPECTED 2
//`define PROGRAM_69_EXPECTED 0
//`define PROGRAM_70_EXPECTED 2
//`define PROGRAM_71_EXPECTED 0
//`define PROGRAM_72_EXPECTED -2
//`define PROGRAM_73_EXPECTED -2
//`define PROGRAM_74_EXPECTED 0
//`define PROGRAM_75_EXPECTED 4
//`define PROGRAM_76_EXPECTED 8
//`define PROGRAM_77_EXPECTED 4
//`define PROGRAM_78_EXPECTED 32'h00005000
//`define PROGRAM_79_EXPECTED 32'h000ff000
//`define PROGRAM_80_EXPECTED 32'h00001000
//`define PROGRAM_81_EXPECTED 32'h00000005
//`define PROGRAM_82_EXPECTED 32'h00000005
//`define PROGRAM_83_EXPECTED 32'd00001597
//`define PROGRAM_84_EXPECTED 32'd1
//`define PROGRAM_85_EXPECTED 32'd2




//`define PROGRAM_FIB_EXPECTED 1597 // Fibbonacci change locaion later

//module Pipelined_CPU_tb #(
//    parameter NUM_PROGRAMS = 86
//);

//    reg Clk;
//    reg Reset;
//    wire Done;
//    wire [31:0] Display_out;
    
//    // Program counter for tb
//    integer program_num;
//    integer Clk_Cycles;
//    integer failed_tests;
//    integer program_failed_tests;
//    integer val_check_failed;
//    integer timeout_flag;
//    reg [31:0] expected_results [0:NUM_PROGRAMS-1];
//    reg [255:0] filename;
    
//    // Instantiate DUT
//    Pipeline_CPU dut (
//        .Done(Done),
//        .Clk(Clk),
//        .Reset(Reset),
//        .Display_out(Display_out)
//    );
    
//    always #5 Clk = ~Clk;

//    task load_program(input [255:0] filename);
//        begin
//            $display("\nRunning %0s ...", filename);
//            $readmemh(filename, dut.fetch_stage.rom.mem);
//        end
//    endtask
    
    
//   always @(posedge Clk) begin
//        Clk_Cycles <= Clk_Cycles + 1;
//        if (Clk_Cycles > `MAX_CYCLES && !timeout_flag) begin
//          $display("ERROR: MAX_CYCLES EXCEEDED! Did Done get set correctly?");
//          failed_tests = failed_tests + 1;
//          timeout_flag = 1;
//        end
//    end
    
//    // Clock
//    initial begin
//        Clk = 0;
//        Clk_Cycles = 0;
//        failed_tests = 0;
//        timeout_flag = 0;
//        val_check_failed = 0;
        
//        expected_results[0] = `PROGRAM_0_EXPECTED;
//        expected_results[1] = `PROGRAM_1_EXPECTED;
//        expected_results[2] = `PROGRAM_2_EXPECTED; 
//        expected_results[3] = `PROGRAM_3_EXPECTED;
//        expected_results[4] = `PROGRAM_4_EXPECTED;
//        expected_results[5] = `PROGRAM_5_EXPECTED;
//        expected_results[6] = `PROGRAM_6_EXPECTED;
//        expected_results[7] = `PROGRAM_7_EXPECTED;
//        expected_results[8] = `PROGRAM_8_EXPECTED;
//        expected_results[9] = `PROGRAM_9_EXPECTED;
//        expected_results[10] = `PROGRAM_10_EXPECTED;
//        expected_results[11] = `PROGRAM_11_EXPECTED;
//        expected_results[12] = `PROGRAM_12_EXPECTED;
//        expected_results[13] = `PROGRAM_13_EXPECTED;
//        expected_results[14] = `PROGRAM_14_EXPECTED;
//        expected_results[15] = `PROGRAM_15_EXPECTED;
//        expected_results[16] = `PROGRAM_16_EXPECTED;
//        expected_results[17] = `PROGRAM_17_EXPECTED;
//        expected_results[18] = `PROGRAM_18_EXPECTED;
//        expected_results[19] = `PROGRAM_19_EXPECTED;
//        expected_results[20] = `PROGRAM_20_EXPECTED;
//        expected_results[21] = `PROGRAM_21_EXPECTED;
//        expected_results[22] = `PROGRAM_22_EXPECTED;
//        expected_results[23] = `PROGRAM_23_EXPECTED;
//        expected_results[24] = `PROGRAM_24_EXPECTED;
//        expected_results[25] = `PROGRAM_25_EXPECTED;
//        expected_results[26] = `PROGRAM_26_EXPECTED;
//        expected_results[27] = `PROGRAM_27_EXPECTED;
//        expected_results[28] = `PROGRAM_28_EXPECTED;
//        expected_results[29] = `PROGRAM_29_EXPECTED;
//        expected_results[30] = `PROGRAM_30_EXPECTED;
//        expected_results[31] = `PROGRAM_31_EXPECTED;
//        expected_results[32] = `PROGRAM_32_EXPECTED;
//        expected_results[33] = `PROGRAM_33_EXPECTED;
//        expected_results[34] = `PROGRAM_34_EXPECTED;
//        expected_results[35] = `PROGRAM_35_EXPECTED;
//        expected_results[36] = `PROGRAM_36_EXPECTED;
//        expected_results[37] = `PROGRAM_37_EXPECTED;
//        expected_results[38] = `PROGRAM_38_EXPECTED;
//        expected_results[39] = `PROGRAM_39_EXPECTED;
//        expected_results[40] = `PROGRAM_40_EXPECTED;
//        expected_results[41] = `PROGRAM_41_EXPECTED;
//        expected_results[42] = `PROGRAM_42_EXPECTED;
//        expected_results[43] = `PROGRAM_43_EXPECTED;
//        expected_results[44] = `PROGRAM_44_EXPECTED;
//        expected_results[45] = `PROGRAM_45_EXPECTED;
//        expected_results[46] = `PROGRAM_46_EXPECTED;
//        expected_results[47] = `PROGRAM_47_EXPECTED;
//        expected_results[48] = `PROGRAM_48_EXPECTED;
//        expected_results[49] = `PROGRAM_49_EXPECTED;
//        expected_results[50] = `PROGRAM_50_EXPECTED;
//        expected_results[51] = `PROGRAM_51_EXPECTED;
//        expected_results[52] = `PROGRAM_52_EXPECTED;
//        expected_results[53] = `PROGRAM_53_EXPECTED;
//        expected_results[54] = `PROGRAM_54_EXPECTED;
//        expected_results[55] = `PROGRAM_55_EXPECTED;
//        expected_results[56] = `PROGRAM_56_EXPECTED;
//        expected_results[57] = `PROGRAM_57_EXPECTED;
//        expected_results[58] = `PROGRAM_58_EXPECTED;
//        expected_results[59] = `PROGRAM_59_EXPECTED;
//        expected_results[60] = `PROGRAM_60_EXPECTED;
//        expected_results[61] = `PROGRAM_61_EXPECTED;
//        expected_results[62] = `PROGRAM_62_EXPECTED;
//        expected_results[63] = `PROGRAM_63_EXPECTED;
//        expected_results[64] = `PROGRAM_64_EXPECTED;
//        expected_results[65] = `PROGRAM_65_EXPECTED;
//        expected_results[66] = `PROGRAM_66_EXPECTED;
//        expected_results[67] = `PROGRAM_67_EXPECTED;
//        expected_results[68] = `PROGRAM_68_EXPECTED;
//        expected_results[69] = `PROGRAM_69_EXPECTED;
//        expected_results[70] = `PROGRAM_70_EXPECTED;
//        expected_results[71] = `PROGRAM_71_EXPECTED;
//        expected_results[72] = `PROGRAM_72_EXPECTED;
//        expected_results[73] = `PROGRAM_73_EXPECTED;
//        expected_results[74] = `PROGRAM_74_EXPECTED;
//        expected_results[75] = `PROGRAM_75_EXPECTED;
//        expected_results[76] = `PROGRAM_76_EXPECTED;
//        expected_results[77] = `PROGRAM_77_EXPECTED;
//        expected_results[78] = `PROGRAM_78_EXPECTED;
//        expected_results[79] = `PROGRAM_79_EXPECTED;
//        expected_results[80] = `PROGRAM_80_EXPECTED;
//        expected_results[81] = `PROGRAM_81_EXPECTED;
//        expected_results[82] = `PROGRAM_82_EXPECTED;
//        expected_results[83] = `PROGRAM_83_EXPECTED;
//        expected_results[84] = `PROGRAM_84_EXPECTED;
//        expected_results[85] = `PROGRAM_85_EXPECTED;
        
        
//        Reset = 1;
//        #20 Reset = 0;
        
//        for (program_num = 0; program_num < NUM_PROGRAMS; program_num = program_num + 1) begin: run_test
//            //$display("\nStarting Program %0d", program_num);
//            program_failed_tests = 0;
//            $sformat(filename, "program_%0d.mem", program_num);
//            load_program(filename);
            
            
//            Reset = 1;
//            #20 Reset = 0;     
//            Clk_Cycles = 0;
//            timeout_flag = 0;                
            
//            wait(Done == 1 || timeout_flag);
            
//            if (timeout_flag) begin
//                $display("ERROR: program_%0d.mem timed out after %0d cycles", program_num, Clk_Cycles);
//                program_failed_tests = program_failed_tests + 1;
//            end 
//                // Check against expected result
//                if (program_num < NUM_PROGRAMS && expected_results[program_num] !== 32'bx) begin
//                    if (Display_out != expected_results[program_num]) begin
//                        $display("FAILED Value check! Expected: %0d, got %0d", expected_results[program_num], Display_out);
//                        failed_tests = failed_tests + 1;
//                        val_check_failed = val_check_failed + 1;
//                        program_failed_tests = program_failed_tests + 1;
//                    end else begin
//                        $display("PASSED Value Check! Expected: %0d, got %0d", expected_results[program_num], Display_out);
//                    end
//                end else begin
//                    $display("WARNING: No valid testcases for program_%0d.mem!", program_num);
//                end
            
            
//            if (!timeout_flag) begin
//                $display("program_%0d.mem completed in %0d cycles", program_num, Clk_Cycles);
//            end
            
//            if (program_failed_tests != 0) begin
//                $display("program_%0d.mem FAILED", program_num);
//            end
//            else begin
//                $display("program_%0d.mem PASSED all tests", program_num);
//            end
            
//            Clk_Cycles = 0;
//            #50;
//        end
                
//        if (failed_tests > 0) begin
//            $display("\n=========================================================================");
//            $display("\nValid testcases %0d/%0d\n", NUM_PROGRAMS * 2 - failed_tests, NUM_PROGRAMS * 2);
//            $display("=========================================================================");
//            $display("Simulation complete\n\nFAILED %0d test(s)\nFAILED %0d value check(s)", failed_tests, val_check_failed);
//            $display("=========================================================================\n");    
//        end
//        else begin
//            $display("=========================================================================\n");    
//            $display("All tests PASSED!\n");
//            $display("=========================================================================\n");    
//        end
//            $stop;
//    end

//endmodule

// == USED FOR SINGLE PROGRAM TESTING ==
`timescale 1ns / 1ps

module Pipelined_CPU_tb();

    reg Clk;
    reg Reset;

    wire Done;
    wire [31:0] Display_out;

    // CPU UART-side signals
    wire [7:0]  UART_tx_byte;
    wire        UART_transmit_signal;
    reg  [7:0] UART_rx_byte;
    reg  [31:0] UART_status;

    // Instantiate CPU DUT only
    Pipeline_CPU dut (
        .Done(Done),
        .Display_out(Display_out),
        .Clk(Clk),
        .Reset(Reset),

        .UART_tx_byte(UART_tx_byte),
        .UART_transmit_signal(UART_transmit_signal),
        .UART_rx_byte(UART_rx_byte),
        .UART_status(UART_status)
    );

    integer i;
    reg [31:0] cycle_count;
    reg [31:0] uart_tx_count;
    reg last_transmit;

    // 100 MHz clock: 10 ns period
    initial begin
        Clk = 1'b0;
        forever #5 Clk = ~Clk;
    end

    // UART status model
    initial begin
        UART_rx_byte = 8'h00;
        UART_status  = 32'h00000001; // bit 0 = TX ready
    end

    // Watch CPU UART transmit requests
    always @(posedge Clk) begin
        if (Reset) begin
            last_transmit <= 1'b0;
            uart_tx_count <= 32'd0;
        end
        else begin
            last_transmit <= UART_transmit_signal;

            if ((UART_transmit_signal === 1'b1) && (last_transmit === 1'b0)) begin
                uart_tx_count <= uart_tx_count + 1;

                $display("[%0t ns] CPU UART TX request #%0d: byte = 0x%02h, char = %c",
                         $time, uart_tx_count + 1, UART_tx_byte, UART_tx_byte);
            end
        end
    end

    // Show memory stores from CPU
    always @(posedge Clk) begin
        if (!Reset && dut.memory_stage.ram.Store === 1'b1) begin
            $display("[%0t ns] STORE: Address = 0x%08h, Data = 0x%08h, WordIndex = 0x%04h",
                     $time,
                     dut.memory_stage.ram.Address,
                     dut.memory_stage.ram.Data_in,
                     dut.memory_stage.ram.Address[16:2]);

            if (dut.memory_stage.ram.Address[16:2] == 15'h0001) begin
                $display("           UART TX register write: 0x%02h / %c",
                         dut.memory_stage.ram.Data_in[7:0],
                         dut.memory_stage.ram.Data_in[7:0]);
            end

            if (dut.memory_stage.ram.Address[16:2] == 15'h0002) begin
                $display("           UART TRANSMIT control write: 0x%08h",
                         dut.memory_stage.ram.Data_in);
            end
        end
    end

    // Print fetch activity
    always @(posedge Clk) begin
        if (Reset) begin
            cycle_count <= 32'd0;
        end
        else begin
            cycle_count <= cycle_count + 1;

            if (cycle_count < 100) begin
                $display("[%0t ns] Cycle %0d: PC = 0x%08h, Instruction = 0x%08h",
                         $time,
                         cycle_count,
                         dut.fetch_stage.PC,
                         dut.fetch_stage.Instruction);
            end
        end
    end

    initial begin
        Reset = 1'b1;
        last_transmit = 1'b0;
        cycle_count = 32'd0;
        uart_tx_count = 32'd0;

        $display("[%0t ns] Reset asserted", $time);

        repeat (10) @(posedge Clk);
        Reset = 1'b0;

        $display("[%0t ns] Reset released", $time);

        for (i = 0; i < 25000; i = i + 1) begin
            @(posedge Clk);

            if (Done) begin
                $display("[%0t ns] CPU Done asserted", $time);
                $display("UART transmit count = %0d", uart_tx_count);
                $finish;
            end
        end

        $display("[%0t ns] Timeout: CPU did not assert Done", $time);
        $display("UART transmit count = %0d", uart_tx_count);
        $finish;
    end

endmodule