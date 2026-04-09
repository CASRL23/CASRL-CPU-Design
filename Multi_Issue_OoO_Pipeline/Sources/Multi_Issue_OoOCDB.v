//module for multi issue CDB/writeback. takes in up to 5 values per cycle (4 ALus, 1 mem)
module Multi_Issue_CDB(
    input wire Clk, Reset,
    input wire [31:0] ALU_res0, ALU_res1, ALU_res2, ALU_res3, Mem_data_in,
    input wire [6:0] CDB_tag0, CDB_tag1, CDB_tag2, CDB_tag3, CDB_tag4,
    input wire ALU_valid0, ALU_valid1, ALU_valid2, ALU_valid3, Mem_valid, 
    
    output reg [31:0] CDB_res0, CDB_res1, CDB_res2, CDB_res3, CDB_res4,
    output reg [6:0] CDB_tag_out0, CDB_tag_out1, CDB_tag_out2, CDB_tag_out3, CDB_tag_out4,
    output reg CDB_valid0, CDB_valid1, CDB_valid2, CDB_valid3, CDB_valid4 
);


always @(posedge Clk) begin
    if (Reset) begin
        CDB_valid0 <= 1'b0;
        CDB_valid1 <= 1'b0;
        CDB_valid2 <= 1'b0;        
        CDB_valid3 <= 1'b0;  
        CDB_valid4 <= 1'b0;
        CDB_tag_out0 <= 7'd0; 
        CDB_tag_out1 <= 7'd0;
        CDB_tag_out2 <= 7'd0;
        CDB_tag_out3 <= 7'd0; 
        CDB_tag_out4 <= 7'd0;
        CDB_res0 <= 32'd0;  
        CDB_res1 <= 32'd0;  
        CDB_res2 <= 32'd0;  
        CDB_res3 <= 32'd0;  
        CDB_res4 <= 32'd0;                                                                                
    end
    else begin
        //-------------------------------ALU 0 read
        CDB_valid0 <= ALU_valid0;
        CDB_res0 <= ALU_res0;
        CDB_tag_out0 <= CDB_tag0;
        //-------------------------------ALU 1 read
        CDB_valid1 <= ALU_valid1;
        CDB_res1 <= ALU_res1;
        CDB_tag_out1 <= CDB_tag1;
        //-------------------------------ALU 2 read
        CDB_valid2 <= ALU_valid2;
        CDB_res2 <= ALU_res2;
        CDB_tag_out2 <= CDB_tag2;
        //-------------------------------ALU 3 read
        CDB_valid3 <= ALU_valid3;
        CDB_res3 <= ALU_res3;
        CDB_tag_out3 <= CDB_tag3;
        //-------------------------------Memory read    
        CDB_valid4 <= Mem_valid;
        CDB_res4 <= Mem_data_in;
        CDB_tag_out4 <= CDB_tag4;    
    end
    
end
endmodule