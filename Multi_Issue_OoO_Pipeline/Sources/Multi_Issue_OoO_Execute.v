//module for multi issue OoO execute stage
//holds 4 ALUs for integer ALU operations, branching, jalr
module Multi_Issue_OoO_Execute(
    input wire [31:0] Vj_in0, Vj_in1, Vj_in2, Vj_in3, 
    input wire [31:0] Vk_in0, Vk_in1, Vk_in2, Vk_in3, 
    input wire [31:0] Imm0, Imm1, Imm2, Imm3,
    input wire [31:0] PC0, PC1, PC2, PC3, PC4,
    input wire [6:0] ALU_tag_in0, ALU_tag_in1, ALU_tag_in2, ALU_tag_in3, Mem_tag_in, 
    input wire [4:0] I_type0, I_type1, I_type2, I_type3, 
    input wire [4:0] Mem_type_in,
    input wire [31:0] Mem_Vj, Mem_Vk, Mem_offset,
    input wire Pred_taken0, Pred_taken1, Pred_taken2, Pred_taken3, Pred_taken4, 
    input wire Valid_ALU0, Valid_ALU1, Valid_ALU2, Valid_ALU3, Valid_mem,
    
    output reg [31:0] ALU_result0, ALU_result1, ALU_result2, ALU_result3, Mem_data_out,
    output reg [31:0] Branch_target0, Branch_target1, Branch_target2, Branch_target3, Branch_target4,
    output reg Mispredict0, Mispredict1, Mispredict2, Mispredict3, Mispredict4,
    output reg [2:0] Mem_type_out,
    output reg [6:0] ALU_tag_out0, ALU_tag_out1, ALU_tag_out2, ALU_tag_out3, 
    output reg [6:0] Mem_tag_out,
    output reg ValidA0, ValidA1, ValidA2, ValidA3, ValidM,
    output wire [31:0] Mem_address_out
    
);

//register for assignment (inputs to ALu modules)
reg [31:0] ALU0_op1, ALU0_op2, ALU1_op1, ALU1_op2, ALU2_op1, ALU2_op2, ALU3_op1, ALU3_op2;
reg [3:0] ALU0_opcode, ALU1_opcode, ALU2_opcode, ALU3_opcode;
wire [31:0] Res0, Res1, Res2, Res3;



//instantiate 4 alus and 2 adders (adder for mem address calculations and for jal/jalr)
Alu ALU0(.Alu_result(Res0), .Alu_op(ALU0_opcode), .Op1(ALU0_op1), .Op2(ALU0_op2));
Alu ALU1(.Alu_result(Res1), .Alu_op(ALU1_opcode), .Op1(ALU1_op1), .Op2(ALU1_op2));
Alu ALU2(.Alu_result(Res2), .Alu_op(ALU2_opcode), .Op1(ALU2_op1), .Op2(ALU2_op2));
Alu ALU3(.Alu_result(Res3), .Alu_op(ALU3_opcode), .Op1(ALU3_op1), .Op2(ALU3_op2));
Ripple_carry_lookahead_32bit Mem_addr_adder(.Result(Mem_address_out), .Op1(Mem_Vj), .Op2(Mem_offset), .C_out(open), .C_in(1'b0));

//has up to 4 alu operations per cycle, 1 mem operation per cycle. This module isnt clocked though, it's pipeline regs are
//mem is not guaranteed to be sent every cycle depending on if LSq or cache are full
always @(*) begin
    
//logic to assign sources to the 4 ALUs and memory operation,
/*
instruction types
0-add
1-sub
2- xor
3- or
4- and
5- lsl
6- lsr
7- asr
8- slt
9- sltu
10- lb 
11- lh
12- lw
13- lbu
14- lhu
15- sb
16- sh
17- sw
18- beq
19- bne
20- blt
21- bge
22- bltu
23- bgeu
24- jal
25- jalr
26- lui
27- auipc
*/

//---------------------logic for ALU0-------------------------------
    //if instruction type is just alu op, alu_op = I_type[3:0]
    if (I_type0 < 5'd10) begin
        ALU0_opcode <= I_type0[3:0];
        ALU0_op1 <= Vj_in0;
        ALU0_op2 <= Vk_in0; 
    end
    //if instrucctions are branches, beq and bne use alu_op of sub
    else if (I_type0 == 5'd18 || I_type0 == 5'd19) begin
        ALU0_opcode <= 4'd1;
        ALU0_op1 <= Vj_in0;
        ALU0_op2 <= Vk_in0;              
    end
    //if instructions are blt or bge, alu op is slt and op1 and op2 are swapped
    else if (I_type0 == 5'd20 || I_type0 == 5'd21) begin
        ALU0_opcode <= 4'd8;
        ALU0_op1 <= Vj_in0; // Keep Vj as Op1 (rs1)
        ALU0_op2 <= Vk_in0; // Keep Vk as Op2 (rs2) 
    end 
    //if instructions are bltu or bgeu, alu op is sltu and op1, op2 are swapped
    else if (I_type0 == 5'd22 || I_type0 == 5'd23) begin
        ALU0_opcode <= 4'd9;
        ALU0_op1 <= Vj_in0; // Keep Vj as Op1 (rs1)
        ALU0_op2 <= Vk_in0; // Keep Vk as Op2 (rs2)                      
    end     
    //if instructions are jal, rd = pc+4 and pc +=immediate (pc held in Vk)
    else if (I_type0 == 5'd24) begin
        ALU0_opcode <= 4'd0;
        ALU0_op1 <= Vj_in0;
        ALU0_op2 <= Imm0;                      
    end    
    //if instructions are jalr, rd = Pc+4, Pc = Rs1 +imm
    else if (I_type0 == 5'd25) begin
        ALU0_opcode <= 4'd0;
        ALU0_op1 <= Vj_in0;
        ALU0_op2 <= Imm0;             
    end     
    //if instructions are lui, rd = imm << 12
    else if (I_type0 == 5'd26) begin
        ALU0_opcode <= 4'd5;
        ALU0_op1 <= Imm0;
        ALU0_op2 <= 32'd12;             
    end     
    //if instructions are auipc, rd = Pc +(imm << 12)
    else if (I_type0 == 5'd27) begin
        ALU0_opcode <= 4'd0;
        ALU0_op1 <= PC0;
        ALU0_op2 <=  (Imm0 << 32'd12);               
    end     
    //else if its a memory instruction or not a valid instr, nothing is output
    else begin
        ALU0_opcode <= 4'd0;
        ALU0_op1 <= 32'd0;
        ALU0_op2 <=  32'd0;     
    end
    
//---------------------logic for ALU1-------------------------------
    //if instruction type is just alu op, alu_op = I_type[3:0]
    if (I_type1 < 5'd10) begin
        ALU1_opcode <= I_type1[3:0];
        ALU1_op1 <= Vj_in1;
        ALU1_op2 <= Vk_in1; 
    end
    //if instrucctions are branches, beq and bne use alu_op of sub
    else if (I_type1 == 5'd18 || I_type1 == 5'd19) begin
        ALU1_opcode <= 4'd1;
        ALU1_op1 <= Vj_in1;
        ALU1_op2 <= Vk_in1;              
    end
    //if instructions are blt or bge, alu op is slt and op1 and op2 are swapped
    else if (I_type1 == 5'd20 || I_type1 == 5'd21) begin
        ALU1_opcode <= 4'd8;
        ALU1_op1 <= Vj_in1; // Keep Vj as Op1 (rs1)
        ALU1_op2 <= Vk_in1; // Keep Vk as Op2 (rs2) 
    end 
    //if instructions are bltu or bgeu, alu op is sltu and op1, op2 are swapped
    else if (I_type1 == 5'd22 || I_type1 == 5'd23) begin
        ALU1_opcode <= 4'd9;
        ALU1_op1 <= Vj_in0; // Keep Vj as Op1 (rs1)
        ALU1_op2 <= Vk_in0; // Keep Vk as Op2 (rs2)                      
    end     
    //if instructions are jal, rd = pc+4 and pc +=immediate (pc held in Vk)
    else if (I_type1 == 5'd24) begin
        ALU1_opcode <= 4'd0;
        ALU1_op1 <= Vj_in1;
        ALU1_op2 <= Imm1;                      
    end    
    //if instructions are jalr, rd = Pc+4, Pc = Rs1 +imm
    else if (I_type1 == 5'd25) begin
        ALU1_opcode <= 4'd0;
        ALU1_op1 <= Vj_in1;
        ALU1_op2 <= Imm1;             
    end     
    //if instructions are lui, rd = imm << 12
    else if (I_type1 == 5'd26) begin
        ALU1_opcode <= 4'd5;
        ALU1_op1 <= Imm1;
        ALU1_op2 <= 32'd12;             
    end     
    //if instructions are auipc, rd = Pc +(imm << 12)
    else if (I_type1 == 5'd27) begin
        ALU1_opcode <= 4'd0;
        ALU1_op1 <= PC1;
        ALU1_op2 <=  (Imm1 << 32'd12);               
    end     
    //else if its a memory instruction or not a valid instr, nothing is output
    else begin
        ALU1_opcode <= 4'd0;
        ALU1_op1 <= 32'd0;
        ALU1_op2 <=  32'd0;     
    end
    
//---------------------logic for ALU2-------------------------------
    //if instruction type is just alu op, alu_op = I_type[3:0]
    if (I_type2 < 5'd10) begin
        ALU2_opcode <= I_type2[3:0];
        ALU2_op1 <= Vj_in2;
        ALU2_op2 <= Vk_in2; 
    end
    //if instrucctions are branches, beq and bne use alu_op of sub
    else if (I_type2 == 5'd18 || I_type2 == 5'd19) begin
        ALU2_opcode <= 4'd1;
        ALU2_op1 <= Vj_in2;
        ALU2_op2 <= Vk_in2;              
    end
    //if instructions are blt or bge, alu op is slt and op1 and op2 are swapped
    else if (I_type2 == 5'd20 || I_type2 == 5'd21) begin
        ALU2_opcode <= 4'd8;
        ALU2_op1 <= Vj_in2; // Keep Vj as Op1 (rs1)
        ALU2_op2 <= Vk_in2; // Keep Vk as Op2 (rs2) 
    end 
    //if instructions are bltu or bgeu, alu op is sltu and op1, op2 are swapped
    else if (I_type2 == 5'd22 || I_type2 == 5'd23) begin
        ALU2_opcode <= 4'd9;
        ALU2_op1 <= Vj_in2; // Keep Vj as Op1 (rs1)
        ALU2_op2 <= Vk_in2; // Keep Vk as Op2 (rs2)                      
    end     
    //if instructions are jal, rd = pc+4 and pc +=immediate (pc held in Vk)
    else if (I_type2 == 5'd24) begin
        ALU2_opcode <= 4'd0;
        ALU2_op1 <= Vj_in2;
        ALU2_op2 <= Imm2;                      
    end    
    //if instructions are jalr, rd = Pc+4, Pc = Rs1 +imm
    else if (I_type2 == 5'd25) begin
        ALU2_opcode <= 4'd0;
        ALU2_op1 <= Vj_in2;
        ALU2_op2 <= Imm2;             
    end     
    //if instructions are lui, rd = imm << 12
    else if (I_type2 == 5'd26) begin
        ALU2_opcode <= 4'd5;
        ALU2_op1 <= Imm2;
        ALU2_op2 <= 32'd12;             
    end     
    //if instructions are auipc, rd = Pc +(imm << 12)
    else if (I_type2 == 5'd27) begin
        ALU2_opcode <= 4'd0;
        ALU2_op1 <= PC2;
        ALU2_op2 <=  (Imm2 << 32'd12);               
    end     
    //else if its a memory instruction or not a valid instr, nothing is output
    else begin
        ALU2_opcode <= 4'd0;
        ALU2_op1 <= 32'd0;
        ALU2_op2 <=  32'd0;     
    end
    
//---------------------logic for ALU3-------------------------------
    //if instruction type is just alu op, alu_op = I_type[3:0]
    if (I_type3 < 5'd10) begin
        ALU3_opcode <= I_type3[3:0];
        ALU3_op1 <= Vj_in3;
        ALU3_op2 <= Vk_in3; 
    end
    //if instrucctions are branches, beq and bne use alu_op of sub
    else if (I_type3 == 5'd18 || I_type3 == 5'd19) begin
        ALU3_opcode <= 4'd1;
        ALU3_op1 <= Vj_in3;
        ALU3_op2 <= Vk_in3;              
    end
    //if instructions are blt or bge, alu op is slt and op1 and op2 are swapped
    else if (I_type3 == 5'd20 || I_type3 == 5'd21) begin
        ALU3_opcode <= 4'd8;
        ALU3_op1 <= Vj_in3; // Keep Vj as Op1 (rs1)
        ALU3_op2 <= Vk_in3; // Keep Vk as Op2 (rs2) 
    end 
    //if instructions are bltu or bgeu, alu op is sltu and op1, op2 are swapped
    else if (I_type3 == 5'd22 || I_type3 == 5'd23) begin
        ALU3_opcode <= 4'd9;
        ALU3_op1 <= Vj_in3; // Keep Vj as Op1 (rs1)
        ALU3_op2 <= Vk_in3; // Keep Vk as Op2 (rs2)                      
    end     
    //if instructions are jal, rd = pc+4 and pc +=immediate (pc held in Vk)
    else if (I_type3 == 5'd24) begin
        ALU3_opcode <= 4'd0;
        ALU3_op1 <= Vj_in3;
        ALU3_op2 <= Imm3;                      
    end    
    //if instructions are jalr, rd = Pc+4, Pc = Rs1 +imm
    else if (I_type3 == 5'd25) begin
        ALU3_opcode <= 4'd0;
        ALU3_op1 <= Vj_in3;
        ALU3_op2 <= Imm3;             
    end     
    //if instructions are lui, rd = imm << 12
    else if (I_type3 == 5'd26) begin
        ALU3_opcode <= 4'd5;
        ALU3_op1 <= Imm3;
        ALU3_op2 <= 32'd12;             
    end     
    //if instructions are auipc, rd = Pc +(imm << 12)
    else if (I_type1 == 5'd27) begin
        ALU3_opcode <= 4'd0;
        ALU3_op1 <= PC3;
        ALU3_op2 <=  (Imm1 << 32'd12);               
    end     
    //else if its a memory instruction or not a valid instr, nothing is output
    else begin
        ALU3_opcode <= 4'd0;
        ALU3_op1 <= 32'd0;
        ALU3_op2 <=  32'd0;     
    end    
end



//---------------------------Memory address/operation logic
always @(*) begin
    ValidM <= Valid_mem;
    Mem_type_out <= Mem_type_in-10;
    Mem_data_out <= Mem_Vk;
    Mem_tag_out <= Mem_tag_in; 
    if (Pred_taken4) begin
        Mispredict4 <= 1'b1;
        Branch_target4 <= PC4 + 32'd4;
    end
    else begin
        Mispredict4 <= 1'b0;
        Branch_target4 <= PC4 + 32'd4;        
    end
end


reg taken_actual0, taken_actual1, taken_actual2, taken_actual3;

// Explicit sensitivity list containing ALL inputs read inside the block
always @(*) begin

//----------------------------------ALU 0 logic--------------------------------   
   // 1. Defaults / Passthrough
   ALU_tag_out0 = ALU_tag_in0;
   ValidA0      = Valid_ALU0;
   
   
   // Default values (CRITICAL: This is what prevents latches, not the sensitivity list!)
   ALU_result0    = 32'd0;
   Branch_target0 = 32'd0;
   Mispredict0    = 1'b0;
   
   // Initialize temporary variable
   taken_actual0 = 1'b0;

   // --- Arithmetic (ADD, SUB, etc.) ---
   if (I_type0 < 5'd10 || 5'd24 <= I_type0 && I_type0 < 5'd28) begin
       // Special Handling for LUI/AUIPC/JAL/JALR below, but default is Res0
       ALU_result0 = Res0;

       // EXCEPTION: JAL (24) & JALR (25)
       if (I_type0 == 5'd24 || I_type0 == 5'd25) begin
           ALU_result0 = Vk_in0; // Result is Link (PC+4)
           
           // Logic: Jumps are ALWAYS taken.
           if (Pred_taken0 == 1'b0) begin
               Mispredict0 = 1'b1;
               Branch_target0 = Res0; // Target is the calculated address
           end
       end
       // EXCEPTION: LUI (26) & AUIPC (27)
       else if (I_type0 == 5'd26 || I_type0 == 5'd27) begin
            // Result is Res0 (calculated in input block)
            if (Pred_taken0) begin
                Mispredict0 = 1'b1;
                Branch_target0 = PC0 + 32'd4;
            end
       end
       // STANDARD ARITHMETIC
       else begin
            if (Pred_taken0) begin
                Mispredict0 = 1'b1;
                Branch_target0 = PC0 + 32'd4;
            end
       end
   end
   
   // --- CONDITIONAL BRANCHES ---
   else begin
       // For branches, we don't write to Rd
       ALU_result0 = 32'd0;

       // 1. Determine Actual Direction (1-bit)
       if (I_type0 == 5'd18)      taken_actual0 = (Res0 == 0);      // BEQ
       else if (I_type0 == 5'd19) taken_actual0 = (Res0 != 0);      // BNE
       else if (I_type0 == 5'd20) taken_actual0 = (Res0[0] == 1);   // BLT
       else if (I_type0 == 5'd21) taken_actual0 = (Res0[0] == 0);   // BGE
       else if (I_type0 == 5'd22) taken_actual0 = (Res0[0] == 1);   // BLTU
       else if (I_type0 == 5'd23) taken_actual0 = (Res0[0] == 0);   // BGEU
       else taken_actual0 = 1'b0;

       // 2. Compare Actual vs Predicted
       if (taken_actual0 != Pred_taken0) begin
           Mispredict0 = 1'b1;
           Branch_target0 = (taken_actual0) ? (PC0 + Imm0) : (PC0 + 32'd4);
       end
   end
   
//------------------------------ALU 1 logic-------------------------------------------   
   
   // 1. Defaults / Passthrough
   ALU_tag_out1 = ALU_tag_in1;
   ValidA1      = Valid_ALU1;
   
   
   // Default values (CRITICAL: This is what prevents latches, not the sensitivity list!)
   ALU_result1    = 32'd0;
   Branch_target1 = 32'd0;
   Mispredict1    = 1'b0;
   
   // Initialize temporary variable
   taken_actual1 = 1'b0;

   // --- Arithmetic (ADD, SUB, etc.) ---
   if (I_type1 < 5'd10 || 5'd24 <= I_type1 && I_type1 < 5'd28) begin
       // Special Handling for LUI/AUIPC/JAL/JALR below, but default is Res0
       ALU_result1 = Res1;

       // EXCEPTION: JAL (24) & JALR (25)
       if (I_type1 == 5'd24 || I_type1 == 5'd25) begin
           ALU_result1 = Vk_in1; // Result is Link (PC+4)
           
           // Logic: Jumps are ALWAYS taken.
           if (Pred_taken1 == 1'b0) begin
               Mispredict1 = 1'b1;
               Branch_target1 = Res1; // Target is the calculated address
           end
       end
       // EXCEPTION: LUI (26) & AUIPC (27)
       else if (I_type1 == 5'd26 || I_type1 == 5'd27) begin
            // Result is Res0 (calculated in input block)
            if (Pred_taken1) begin
                Mispredict1 = 1'b1;
                Branch_target1 = PC1 + 32'd4;
            end
       end
       // STANDARD ARITHMETIC
       else begin
            if (Pred_taken1) begin
                Mispredict1 = 1'b1;
                Branch_target1 = PC1 + 32'd4;
            end
       end
   end
   
   // --- CONDITIONAL BRANCHES ---
   else begin
       // For branches, we don't write to Rd
       ALU_result1 = 32'd0;

       // 1. Determine Actual Direction (1-bit)
       if (I_type1 == 5'd18)      taken_actual1 = (Res1 == 0);      // BEQ
       else if (I_type1 == 5'd19) taken_actual1 = (Res1 != 0);      // BNE
       else if (I_type1 == 5'd20) taken_actual1 = (Res1[0] == 1);   // BLT
       else if (I_type1 == 5'd21) taken_actual1 = (Res1[0] == 0);   // BGE
       else if (I_type1 == 5'd22) taken_actual1 = (Res1[0] == 1);   // BLTU
       else if (I_type1 == 5'd23) taken_actual1 = (Res1[0] == 0);   // BGEU
       else taken_actual1 = 1'b0;

       // 2. Compare Actual vs Predicted
       if (taken_actual1 != Pred_taken1) begin
           Mispredict1 = 1'b1;
           Branch_target1 = (taken_actual1) ? (PC1 + Imm1) : (PC1 + 32'd4);
       end
   end

//----------------------------------ALU 2 logic--------------------------------   
   // 1. Defaults / Passthrough
   ALU_tag_out2 = ALU_tag_in2;
   ValidA2      = Valid_ALU2;
   
   
   // Default values (CRITICAL: This is what prevents latches, not the sensitivity list!)
   ALU_result2    = 32'd0;
   Branch_target2 = 32'd0;
   Mispredict2    = 1'b0;
   
   // Initialize temporary variable
   taken_actual2 = 1'b0;

   // --- Arithmetic (ADD, SUB, etc.) ---
   if (I_type2 < 5'd10 || 5'd24 <= I_type2 && I_type2 < 5'd28) begin
       // Special Handling for LUI/AUIPC/JAL/JALR below, but default is Res0
       ALU_result2 = Res2;

       // EXCEPTION: JAL (24) & JALR (25)
       if (I_type2 == 5'd24 || I_type2 == 5'd25) begin
           ALU_result2 = Vk_in2; // Result is Link (PC+4)
           
           // Logic: Jumps are ALWAYS taken.
           if (Pred_taken2 == 1'b0) begin
               Mispredict2 = 1'b1;
               Branch_target2 = Res2; // Target is the calculated address
           end
       end
       // EXCEPTION: LUI (26) & AUIPC (27)
       else if (I_type2 == 5'd26 || I_type2 == 5'd27) begin
            // Result is Res0 (calculated in input block)
            if (Pred_taken2) begin
                Mispredict2 = 1'b1;
                Branch_target2 = PC2 + 32'd4;
            end
       end
       // STANDARD ARITHMETIC
       else begin
            if (Pred_taken2) begin
                Mispredict2 = 1'b1;
                Branch_target2 = PC2 + 32'd4;
            end
       end
   end
   
   // --- CONDITIONAL BRANCHES ---
   else begin
       // For branches, we don't write to Rd
       ALU_result2 = 32'd0;

       // 1. Determine Actual Direction (1-bit)
       if (I_type2 == 5'd18)      taken_actual2 = (Res2 == 0);      // BEQ
       else if (I_type2 == 5'd19) taken_actual2 = (Res2 != 0);      // BNE
       else if (I_type2 == 5'd20) taken_actual2 = (Res2[0] == 1);   // BLT
       else if (I_type2 == 5'd21) taken_actual2 = (Res2[0] == 0);   // BGE
       else if (I_type2 == 5'd22) taken_actual2 = (Res2[0] == 1);   // BLTU
       else if (I_type2 == 5'd23) taken_actual2 = (Res2[0] == 0);   // BGEU
       else taken_actual2 = 1'b0;

       // 2. Compare Actual vs Predicted
       if (taken_actual2 != Pred_taken2) begin
           Mispredict2 = 1'b1;
           Branch_target2 = (taken_actual2) ? (PC2 + Imm2) : (PC2 + 32'd4);
       end
   end
   
//------------------------------ALU 3 logic-------------------------------------------   
   
   // 1. Defaults / Passthrough
   ALU_tag_out3 = ALU_tag_in3;
   ValidA3      = Valid_ALU3;
   
   
   // Default values (CRITICAL: This is what prevents latches, not the sensitivity list!)
   ALU_result3    = 32'd0;
   Branch_target3 = 32'd0;
   Mispredict3    = 1'b0;
   
   // Initialize temporary variable
   taken_actual3 = 1'b0;

   // --- Arithmetic (ADD, SUB, etc.) ---
   if (I_type3 < 5'd10 || 5'd24 <= I_type3 && I_type3 < 5'd28) begin
       // Special Handling for LUI/AUIPC/JAL/JALR below, but default is Res0
       ALU_result3 = Res3;

       // EXCEPTION: JAL (24) & JALR (25)
       if (I_type3 == 5'd24 || I_type3 == 5'd25) begin
           ALU_result3 = Vk_in3; // Result is Link (PC+4)
           
           // Logic: Jumps are ALWAYS taken.
           if (Pred_taken3 == 1'b0) begin
               Mispredict3 = 1'b1;
               Branch_target3 = Res3; // Target is the calculated address
           end
       end
       // EXCEPTION: LUI (26) & AUIPC (27)
       else if (I_type3 == 5'd26 || I_type3 == 5'd27) begin
            // Result is Res0 (calculated in input block)
            if (Pred_taken3) begin
                Mispredict3 = 1'b1;
                Branch_target3 = PC3 + 32'd4;
            end
       end
       // STANDARD ARITHMETIC
       else begin
            if (Pred_taken3) begin
                Mispredict3 = 1'b1;
                Branch_target3 = PC3 + 32'd4;
            end
       end
   end
   
   // --- CONDITIONAL BRANCHES ---
   else begin
       // For branches, we don't write to Rd
       ALU_result3 = 32'd0;

       // 1. Determine Actual Direction (1-bit)
       if (I_type3 == 5'd18)      taken_actual3 = (Res3 == 0);      // BEQ
       else if (I_type3 == 5'd19) taken_actual3 = (Res3 != 0);      // BNE
       else if (I_type3 == 5'd20) taken_actual3 = (Res3[0] == 1);   // BLT
       else if (I_type3 == 5'd21) taken_actual3 = (Res3[0] == 0);   // BGE
       else if (I_type3 == 5'd22) taken_actual3 = (Res3[0] == 1);   // BLTU
       else if (I_type3 == 5'd23) taken_actual3 = (Res3[0] == 0);   // BGEU
       else taken_actual3 = 1'b0;

       // 2. Compare Actual vs Predicted
       if (taken_actual3 != Pred_taken3) begin
           Mispredict3 = 1'b1;
           Branch_target3 = (taken_actual3) ? (PC3 + Imm3) : (PC3 + 32'd4);
       end
   end  
    
   // Passthrough placeholders
   ALU_tag_out1 = ALU_tag_in1; ValidA1 = Valid_ALU1;
   ALU_tag_out2 = ALU_tag_in2; ValidA2 = Valid_ALU2;
   ALU_tag_out3 = ALU_tag_in3; ValidA3 = Valid_ALU3;
end
endmodule