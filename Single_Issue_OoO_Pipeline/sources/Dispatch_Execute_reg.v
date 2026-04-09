//pipeline reg for between dispatch and execute stage
module DE_Pipeline_reg(
    input wire Clk, Reset,
    
    input wire [31:0] Vj_in, Vk_in, Mem_offset_in, PC_in, Imm_in, 
    input wire [6:0] Tag_in, 
    input wire [4:0] Instr_type_in,
    input wire Dispatch_valid_in,
    input wire Pred_taken_in,
    
    output reg [31:0] Vj_out, Vk_out, Mem_offset_out, PC_out, Imm_out, 
    output reg [6:0] Tag_out, 
    output reg [4:0] Instr_type_out,
    output reg Dispatch_valid_out,
    output reg Pred_taken_out
);

always @(posedge Clk) begin
    if (Reset) begin
        Vj_out <= 0;
        Vk_out <= 0;
        Mem_offset_out <= 0;
        PC_out <= 0;
        Imm_out <= 0;
        Tag_out <= 0;
        Dispatch_valid_out <= 0;
        Pred_taken_out <= 0;
    end
    else begin
        Vj_out <= Vj_in;
        Vk_out <= Vk_in;
        Mem_offset_out <= Mem_offset_in;
        PC_out <= PC_in;
        Imm_out <= Imm_in;
        Tag_out <= Tag_in;
        Instr_type_out <= Instr_type_in;
        Dispatch_valid_out <= Dispatch_valid_in;
        Pred_taken_out <= Pred_taken_in;
    end

end


endmodule