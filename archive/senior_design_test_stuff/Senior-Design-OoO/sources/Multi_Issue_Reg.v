`timescale 10ns / 1ps


//This module is a multi ported register for the Multi issue reg file. takes in 4 data values and a write enable for each
module Multi_Issue_Reg(
                       output reg [31:0] Data_out,
                       input wire Clk, Reset, 
                       input wire [3:0] Write_enable,
                       input wire [31:0] Data_in0, Data_in1, Data_in2, Data_in3
    );

//(* mark_debug = "true", keep = "true" *)
reg [31:0] Reg_data;    
    
//Async reset and a clocked write    

always @(posedge Clk or posedge Reset) begin
    if (Reset == 1'b1) begin
        Reg_data <= 32'h0;
    end else begin
        // Last-wins: check ports in order, last has highest priority
        if (Write_enable[0]) Reg_data <= Data_in0;
        if (Write_enable[1]) Reg_data <= Data_in1;
        if (Write_enable[2]) Reg_data <= Data_in2;
        if (Write_enable[3]) Reg_data <= Data_in3;
    end
end

//Async Read
always @(*) begin
    Data_out <= Reg_data;
end    
endmodule
