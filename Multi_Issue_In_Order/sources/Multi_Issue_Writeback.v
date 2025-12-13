`timescale 1ns / 1ps

module Multi_Issue_Writeback (
    input wire Clk, Reset,
    
    // 4 pipeline inputs (one per issue slot)
    input  wire [4*172:0] MW_in,
    input  wire [31:0] RAM_out0, RAM_out1, RAM_out2, RAM_out3,
    
    // 4 writeback outputs
    output wire WB_en0,
    output wire [4:0] WB_addr0,
    output wire [31:0] WB_data0,
    
    output wire WB_en1,
    output wire [4:0] WB_addr1,
    output wire [31:0] WB_data1,
    
    output wire WB_en2,
    output wire [4:0] WB_addr2,
    output wire [31:0] WB_data2,
    
    output wire WB_en3,
    output wire [4:0] WB_addr3,
    output wire [31:0] WB_data3,
    
    output wire Done
);
    // Split 
    wire [171:0] MW_in0 = MW_in[171:0];
    wire [171:0] MW_in1 = MW_in[343:172];
    wire [171:0] MW_in2 = MW_in[515:344];
    wire [171:0] MW_in3 = MW_in[687:516];
    
    // Issue 0
    assign WB_addr0 = MW_in0[164:160];
    
    wire Jal0 = MW_in0[169];
    wire Jalr0 = MW_in0[168];
    wire Load0 = MW_in0[167];
    wire Lui0 = MW_in0[166];
    wire Auipc0 = MW_in0[165];
    wire [31:0] Branch_target0 = MW_in0[159:128];
    wire [31:0] Immediate0 = MW_in0[127:96];
    wire [31:0] PC_plus4_0 = MW_in0[95:64];
    wire [31:0] Alu_result0 = MW_in0[63:32];
    
    assign WB_data0 = Load0 ? RAM_out0 :
                      (Jalr0 || Jal0) ? PC_plus4_0 :
                      Lui0 ? Immediate0 :
                      Auipc0 ? Branch_target0 :
                      Alu_result0;
    
    // Issue 1
    assign WB_addr1 = MW_in1[164:160];
    
    wire Jal1 = MW_in1[169];
    wire Jalr1 = MW_in1[168];
    wire Load1 = MW_in1[167];
    wire Lui1 = MW_in1[166];
    wire Auipc1 = MW_in1[165];
    wire [31:0] Branch_target1 = MW_in1[159:128];
    wire [31:0] Immediate1 = MW_in1[127:96];
    wire [31:0] PC_plus4_1 = MW_in1[95:64];
    wire [31:0] Alu_result1 = MW_in1[63:32];
    //wire [31:0] RAM_out1 = MW_in1[31:0];
    
    assign WB_data1 = Load1 ? RAM_out1 :
                      (Jalr1 || Jal1) ? PC_plus4_1 :
                      Lui1 ? Immediate1 :
                      Auipc1 ? Branch_target1 :
                      Alu_result1;
    
    // Issue 2
    assign WB_addr2 = MW_in2[164:160];
    
    wire Jal2 = MW_in2[169];
    wire Jalr2 = MW_in2[168];
    wire Load2 = MW_in2[167];
    wire Lui2 = MW_in2[166];
    wire Auipc2 = MW_in2[165];
    wire [31:0] Branch_target2 = MW_in2[159:128];
    wire [31:0] Immediate2 = MW_in2[127:96];
    wire [31:0] PC_plus4_2 = MW_in2[95:64];
    wire [31:0] Alu_result2 = MW_in2[63:32];
    
    assign WB_data2 = Load2 ? RAM_out2 :
                      (Jalr2 || Jal2) ? PC_plus4_2 :
                      Lui2 ? Immediate2 :
                      Auipc2 ? Branch_target2 :
                      Alu_result2;
    
    // Issue 3
    assign WB_addr3 = MW_in3[164:160];
    
    wire Jal3 = MW_in3[169];
    wire Jalr3 = MW_in3[168];
    wire Load3 = MW_in3[167];
    wire Lui3 = MW_in3[166];
    wire Auipc3 = MW_in3[165];
    wire [31:0] Branch_target3 = MW_in3[159:128];
    wire [31:0] Immediate3 = MW_in3[127:96];
    wire [31:0] PC_plus4_3 = MW_in3[95:64];
    wire [31:0] Alu_result3 = MW_in3[63:32];
   
    assign WB_data3 = Load3 ? RAM_out3 :
                      (Jalr3 || Jal3) ? PC_plus4_3 :
                      Lui3 ? Immediate3 :
                      Auipc3 ? Branch_target3 :
                      Alu_result3;
    
    reg done_reg;
    always @(posedge Clk or posedge Reset) begin
        if (Reset)
            done_reg <= 1'b0;
        else if (MW_in0[171] || MW_in1[171] || MW_in2[171] || MW_in3[171])
            done_reg <= 1'b1;
    end
    
    assign Done = done_reg;
    
    // Disable later writebacks if an earlier "done" is set
    assign WB_en0 = MW_in0[170] && !Done;
    assign WB_en1 = MW_in1[170] && !MW_in0[171] && !Done;
    assign WB_en2 = MW_in2[170] && !(MW_in0[171] || MW_in1[171]) && !Done;
    assign WB_en3 = MW_in3[170] && !(MW_in0[171] || MW_in1[171] || MW_in2[171]) && !Done;

endmodule

