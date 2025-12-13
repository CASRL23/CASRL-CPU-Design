`timescale 10ns / 1ps
module CPU(
    output wire Done,
    input wire CLK_125_P,
    input wire CLK_125_N,
    input wire Reset
    
   
    
);
    

    wire clk_100mhz;
    wire clk_25mhz;
    wire clk_200mhz;
    wire locked;



  clk_wiz_0 inst
  (
  // Clock out ports  
  .clk_out_100(clk_100mhz),
  .clk_out_25(clk_25mhz),
  .clk_out_200(clk_200mhz),
  // Status and control signals               
  .reset(Reset), 
  .locked(locked),
 // Clock in ports
  .clk_in1_p(CLK_125_P),
  .clk_in1_n(CLK_125_N)
  );

    ila_0 analyzer(
        .clk(clk_100mhz),
        .probe0(MICPU.Decode_Stage.MIRF.x1_out),
        .probe1(MICPU.Decode_Stage.MIRF.x2_out),
        .probe2(MICPU.Decode_Stage.MIRF.x3_out),
        .probe3(MICPU.Decode_Stage.MIRF.x4_out),
        .probe4(MICPU.Decode_Stage.MIRF.x5_out),
        .probe5(MICPU.Decode_Stage.MIRF.x6_out),
        .probe6(MICPU.Decode_Stage.MIRF.x7_out),
        .probe7(MICPU.Decode_Stage.MIRF.x8_out),
        .probe8(Done),
        .probe9(Reset | locked)         
    );
    
    
    Multi_Issue_CPU MICPU(
        .Done(Done),
        .Display_out(Display_out), 
        .Clk(clk_200mhz),              
        .Reset(Reset)   
    );   
endmodule
