`timescale 10ns / 1ps

module CPU(
    output wire Done,
    input wire CLK100MHZ, Reset,
    output wire [7:0] Segment,  
    output wire [7:0] Anode
    );
    
    reg Clk = 0;
    wire [26:0] Data_in;
    reg [21:0] Refresh_counter = 0;
    
     Seg_Decoder Decoder(
        .Segment(Segment), 
        .Anode(Anode),    
        .Data_in(Data_in),   
        .CLK(CLK100MHZ)       
    );
   
//    Single_cycle_cpu SSCPU(
//        .Done(Done),
//        .Display_out(Data_in), 
//        .Clk(Clk), 
//        .Reset(Reset)    
//    );
    
    Pipeline_CPU PCPU(
        .Done(Done),
        .Display_out(Data_in), 
        .Clk(Clk), 
        .Reset(Reset) 
    );
   
   always @(posedge CLK100MHZ) begin
    Refresh_counter <= Refresh_counter + 1;
    if (Refresh_counter == 0) begin
        Clk <= ~Clk;
    end
end
   
endmodule
