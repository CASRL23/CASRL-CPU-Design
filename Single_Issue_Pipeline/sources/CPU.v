`timescale 10ns / 1ps
module CPU(
    output wire Done,
    input wire CLK_125_P,
    input wire CLK_125_N,
    input wire Reset
);
    
    wire clk_100mhz;
    wire clk_500mhz;
    wire clk_25mhz;
    wire locked;

//   clk_wiz_0 inst(
         // Clock out ports  
//        .clk_out_100(clk_100mhz),
//        .clk_out_25(clk_25mhz),
//        .clk_out_500(clk_500mhz),
         // Status and control signals               
//        .reset(Reset),
//        .locked(locked),
         // Clock in ports
//         .clk_in1(clk)
//        .clk_in1_p(CLK_125_P),
//        .clk_in1_n(CLK_125_N)
//      );

    Pipeline_CPU PCPU(
        .Done(Done),
        .Clk(clk_500mhz),              
        .Reset(Reset)
    );    
endmodule
