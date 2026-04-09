//module for Decode to Issue stage pipeline registers
module DI_pipeline_reg(
    input wire Clk, Reset, Stall, Flush,
    input wire [31:0] Vj_in, Vk_in, Mem_offset_in, PC_in,
    input wire  [4:0] Instr_type_in, Rd_id_in, Rs1_in, Rs2_in,
    input wire [6:0] Rs1_tag_in, Rs2_tag_in,
    input wire Rs1_valid_in, Rs2_valid_in, Has_Rd_in, Valid_issue_in, Pred_take_in,
    
    
    output reg [31:0] Vj_out, Vk_out, Mem_offset_out, PC_out,
    output reg [4:0] Instr_type_out, Rd_id_out, Rs1_out, Rs2_out,
    output reg [6:0] Rs1_tag_out, Rs2_tag_out,
    output reg Rs1_valid_out, Rs2_valid_out, Has_Rd_out, Valid_issue_out, Pred_take_out
);

always @(posedge Clk) begin
    if (Reset || Flush) begin
        Vj_out <= 32'd0;
        Vk_out <= 32'd0;
        Mem_offset_out <= 32'd0;
        Instr_type_out <= 5'd0;
        Rd_id_out <= 5'd0;
        Rs1_tag_out <= 8'h80;
        Rs2_tag_out <= 8'h80;
        Rs1_valid_out <= 1'b0;
        Rs2_valid_out <= 1'b0;
        Has_Rd_out <= 1'b0;
        Valid_issue_out <= 1'b0;
        Pred_take_out <= 1'b0;
        PC_out <= 32'd0;
        Rs1_out <= 5'd0;
        Rs2_out <= 5'd0;
    end
    else if (Stall) begin
        Vj_out <= Vj_out;
        Vk_out <= Vk_out;
        Mem_offset_out <= Mem_offset_out;
        Instr_type_out <= Instr_type_out;
        Rd_id_out <= Rd_id_out;
        Rs1_tag_out <= Rs1_tag_out;
        Rs2_tag_out <= Rs2_tag_out;
        Rs1_valid_out <= Rs1_valid_out;
        Rs2_valid_out <= Rs2_valid_out;
        Has_Rd_out <= Has_Rd_out;
        Valid_issue_out <= Valid_issue_out;
        Pred_take_out <= Pred_take_out;    
        PC_out <= PC_out;
    end
    else begin
        Vj_out <= Vj_in;
        Vk_out <= Vk_in;
        Mem_offset_out <= Mem_offset_in;
        Instr_type_out <= Instr_type_in;
        Rd_id_out <= Rd_id_in;
        Rs1_tag_out <= Rs1_tag_in;
        Rs2_tag_out <= Rs2_tag_in;
        Rs1_valid_out <= Rs1_valid_in;
        Rs2_valid_out <= Rs2_valid_in;
        Has_Rd_out <= Has_Rd_in;
        Valid_issue_out <= Valid_issue_in;
        Pred_take_out <= Pred_take_in; 
        PC_out <= PC_in;
        Rs1_out <= Rs1_in;
        Rs2_out <= Rs2_in;
    end
    
end

endmodule