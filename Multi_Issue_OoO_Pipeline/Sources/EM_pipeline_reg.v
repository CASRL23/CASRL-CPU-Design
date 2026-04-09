//module for execute-memory pipeline register for out of order processor
module EM_pipeline_reg(
    input wire Clk, Reset, Flush, Stall,
    input wire [31:0] Data_in, Mem_addr,
    input wire Valid_mem_in,
    input wire [2:0] Mem_type_in,
    input wire [6:0] Mem_tag_in,
    
    
    output reg [6:0] Mem_tag_out,
    output reg [31:0] Data_out, Addr_out,
    output reg [2:0] Mem_type_out,
    output reg Mem_valid
);

always @(posedge Clk) begin
    if (Reset || Flush) begin
        Mem_tag_out <= 7'd0;
        Data_out <= 32'd0;
        Mem_valid <= 1'b0;
        Mem_type_out <= 4'd0;
        Addr_out <= 32'd0;
    end
    else if (Stall) begin
        Mem_tag_out <= Mem_tag_out;
        Data_out <= Data_out;
        Mem_valid <= Mem_valid;
        Mem_type_out <= Mem_type_out;
        Addr_out <= Addr_out;    
    end
    else begin
        Mem_tag_out <= Mem_tag_in;
        Data_out <= Data_in;
        Mem_valid <= Valid_mem_in;
        Mem_type_out <= Mem_type_in;
        Addr_out <= Mem_addr;
   end 
end
endmodule