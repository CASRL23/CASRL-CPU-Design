//This module has a base 32 bit general purpose register
//Reads are asynchronous, writes and resets are synchronous
module Register_32_bit(
    output wire [31:0] Data_out,
    input wire Write_enable, Clk, Reset,
    input wire [31:0] Data_in
    );
 
//32 bit register to hold data
reg [31:0] Reg_data; 
    
//every clock    
always @(posedge Clk) begin
    //if reset is high, reset
    if (Reset == 1'b1) begin
         Reg_data <= 32'h00000000;
    end
    //otherwise if write is enabled, write in the new data
    else if (Write_enable == 1'b1) begin
        Reg_data <= Data_in;
    end
end

//assign dreg_data to data_out for asyn read
assign Data_out = Reg_data;
endmodule
