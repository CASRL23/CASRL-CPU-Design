//module holds 4 issue width execute stage
module Multi_Issue_Execute(
    input  wire [4*167-1:0] DE_in,
    input  wire [4*180-1:0] EM_outin,             // Used for Forwarding
    input  wire [4*172-1:0] MW_in,                // Used for Forwarding
    input  wire [31:0] WB_RAM_out0, WB_RAM_out1, WB_RAM_out2, WB_RAM_out3,
    output wire [4*180-1:0] EM_out 
);

//--------------------------------------------------------------------------------------
    // Split Internally
    wire [166:0] DE_in0 = DE_in[166:0];
    wire [166:0] DE_in1 = DE_in[333:167];
    wire [166:0] DE_in2 = DE_in[500:334];
    wire [166:0] DE_in3 = DE_in[667:501];
    
    wire [179:0] EM_outin0 = EM_outin[179:0];
    wire [179:0] EM_outin1 = EM_outin[359:180];
    wire [179:0] EM_outin2 = EM_outin[539:360];
    wire [179:0] EM_outin3 = EM_outin[719:540];
    
    wire [171:0] MW_out0 = MW_in[171:0];
    wire [171:0] MW_out1 = MW_in[343:172];
    wire [171:0] MW_out2 = MW_in[515:344];
    wire [171:0] MW_out3 = MW_in[687:516];

    // Get Values from Pipeline Register - 0
    wire Branch_predict0 = DE_in0[166];
    wire Done0 = DE_in0[165];
    wire [31:0] PC0 = DE_in0[164:133];
    wire RegWrite0 = DE_in0[132];
    wire Unsigned0 = DE_in0[131];
    wire Word0 = DE_in0[130];
    wire Half0 = DE_in0[129];
    wire Byte0 = DE_in0[128];
    wire Store0 = DE_in0[127];
    wire Load0 = DE_in0[126];
    wire Bgeu0 = DE_in0[125];
    wire Bltu0 = DE_in0[124];
    wire Bge0 = DE_in0[123];
    wire Blt0 = DE_in0[122];
    wire Bne0 = DE_in0[121];
    wire Beq0 = DE_in0[120];
    wire Lui0 = DE_in0[119];
    wire Auipc0 = DE_in0[118];
    wire Jalr0 = DE_in0[117];
    wire Jal0 = DE_in0[116];
    wire Immediate_enable0 = DE_in0[115];
    wire [3:0]  Alu_opcode0 = DE_in0[114:111];
    wire [4:0]  Write_reg0 = DE_in0[110:106];
    wire [4:0]  Read_reg2_0 = DE_in0[105:101];
    wire [4:0]  Read_reg1_0 = DE_in0[100:96];
    wire [31:0] Immediate0 = DE_in0[95:64];
    wire [31:0] Read_data2_0 = DE_in0[63:32];
    wire [31:0] Read_data1_0 = DE_in0[31:0];
    
    wire [31:0] Op1_0, Op2_0, Op1_1, Op2_1, Op1_2, Op2_2, Op1_3, Op2_3;
    wire [31:0] Alu_result0, Alu_result1, Alu_result2, Alu_result3, PC_plus4_0, Branch_target0;
    wire [1:0] ForwardA0, ForwardB0;
    reg Branch0;
    
    // Used for WB Forwarding Data
    wire WB_Jal0 = MW_out0[169];
    wire WB_Jalr0 = MW_out0[168];
    wire WB_Load0 = MW_out0[167];
    wire WB_Lui0 = MW_out0[166];
    wire WB_Auipc0 = MW_out0[165];
    wire [31:0] WB_Branch_target0 = MW_out0[159:128];
    wire [31:0] WB_Immediate0 = MW_out0[127:96];
    wire [31:0] WB_PC_plus4_0 = MW_out0[95:64];
    wire [31:0] WB_Alu_result0 = MW_out0[63:32];
    //wire [31:0] WB_RAM_out0 = MW_out0[31:0];
    wire [31:0] WB_data0;
    wire Branch_valid0 = Beq0 | Bne0 | Blt0 | Bge0 | Bltu0 | Bgeu0 | Jalr0 | Jal0;
    
    // Get Values from Pipeline Register - 1
    wire Branch_predict1 = DE_in1[166];
    wire Done1 = DE_in1[165];
    wire [31:0] PC1 = DE_in1[164:133];
    wire RegWrite1 = DE_in1[132];
    wire Unsigned1 = DE_in1[131];
    wire Word1 = DE_in1[130];
    wire Half1 = DE_in1[129];
    wire Byte1 = DE_in1[128];
    wire Store1 = DE_in1[127];
    wire Load1 = DE_in1[126];
    wire Bgeu1 = DE_in1[125];
    wire Bltu1 = DE_in1[124];
    wire Bge1 = DE_in1[123];
    wire Blt1 = DE_in1[122];
    wire Bne1 = DE_in1[121];
    wire Beq1 = DE_in1[120];
    wire Lui1 = DE_in1[119];
    wire Auipc1 = DE_in1[118];
    wire Jalr1 = DE_in1[117];
    wire Jal1 = DE_in1[116];
    wire Immediate_enable1 = DE_in1[115];
    wire [3:0]  Alu_opcode1 = DE_in1[114:111];
    wire [4:0]  Write_reg1 = DE_in1[110:106];
    wire [4:0]  Read_reg2_1 = DE_in1[105:101];
    wire [4:0]  Read_reg1_1 = DE_in1[100:96];
    wire [31:0] Immediate1 = DE_in1[95:64];
    wire [31:0] Read_data2_1 = DE_in1[63:32];
    wire [31:0] Read_data1_1 = DE_in1[31:0];
    
    
    wire [31:0] PC_plus4_1, Branch_target1;    
    wire [1:0] ForwardA1, ForwardB1;
    reg Branch1;
    
    // Used for WB Forwarding Data
    wire WB_Jal1 = MW_out1[169];
    wire WB_Jalr1 = MW_out1[168];
    wire WB_Load1 = MW_out1[167];
    wire WB_Lui1 = MW_out1[166];
    wire WB_Auipc1 = MW_out1[165];
    wire [31:0] WB_Branch_target1 = MW_out1[159:128];
    wire [31:0] WB_Immediate1 = MW_out1[127:96];
    wire [31:0] WB_PC_plus4_1 = MW_out1[95:64];
    wire [31:0] WB_Alu_result1 = MW_out1[63:32];
    //wire [31:0] WB_RAM_out1 = MW_out1[31:0];
    wire [31:0] WB_data1;
    wire Branch_valid1 = Beq1 | Bne1 | Blt1 | Bge1 | Bltu1 | Bgeu1 | Jalr1 | Jal1;
    
    // Get Values from Pipeline Register - 2
    wire Branch_predict2 = DE_in2[166];
    wire Done2 = DE_in2[165];
    wire [31:0] PC2 = DE_in2[164:133];
    wire RegWrite2 = DE_in2[132];
    wire Unsigned2 = DE_in2[131];
    wire Word2 = DE_in2[130];
    wire Half2 = DE_in2[129];
    wire Byte2 = DE_in2[128];
    wire Store2 = DE_in2[127];
    wire Load2 = DE_in2[126];
    wire Bgeu2 = DE_in2[125];
    wire Bltu2 = DE_in2[124];
    wire Bge2 = DE_in2[123];
    wire Blt2 = DE_in2[122];
    wire Bne2 = DE_in2[121];
    wire Beq2 = DE_in2[120];
    wire Lui2 = DE_in2[119];
    wire Auipc2 = DE_in2[118];
    wire Jalr2 = DE_in2[117];
    wire Jal2 = DE_in2[116];
    wire Immediate_enable2 = DE_in2[115];
    wire [3:0]  Alu_opcode2 = DE_in2[114:111];
    wire [4:0]  Write_reg2 = DE_in2[110:106];
    wire [4:0]  Read_reg2_2 = DE_in2[105:101];
    wire [4:0]  Read_reg1_2 = DE_in2[100:96];
    wire [31:0] Immediate2 = DE_in2[95:64];
    wire [31:0] Read_data2_2 = DE_in2[63:32];
    wire [31:0] Read_data1_2 = DE_in2[31:0];
    
    wire [31:0] PC_plus4_2, Branch_target2;    
    wire [1:0] ForwardA2, ForwardB2;
    reg Branch2;
    
    // Used for WB Forwarding Data
    wire WB_Jal2 = MW_out2[169];
    wire WB_Jalr2 = MW_out2[168];
    wire WB_Load2 = MW_out2[167];
    wire WB_Lui2 = MW_out2[166];
    wire WB_Auipc2 = MW_out2[165];
    wire [31:0] WB_Branch_target2 = MW_out2[159:128];
    wire [31:0] WB_Immediate2 = MW_out2[127:96];
    wire [31:0] WB_PC_plus4_2 = MW_out2[95:64];
    wire [31:0] WB_Alu_result2 = MW_out2[63:32];
    //wire [31:0] WB_RAM_out2 = MW_out2[31:0];
    wire [31:0] WB_data2;
    wire Branch_valid2 = Beq2 | Bne2 | Blt2 | Bge2 | Bltu2 | Bgeu2 | Jalr2 | Jal2;
    
    // Get Values from Pipeline Register - 3
    wire Branch_predict3 = DE_in3[166];
    wire Done3 = DE_in3[165];
    wire [31:0] PC3 = DE_in3[164:133];
    wire RegWrite3 = DE_in3[132];
    wire Unsigned3 = DE_in3[131];
    wire Word3 = DE_in3[130];
    wire Half3 = DE_in3[129];
    wire Byte3 = DE_in3[128];
    wire Store3 = DE_in3[127];
    wire Load3 = DE_in3[126];
    wire Bgeu3 = DE_in3[125];
    wire Bltu3 = DE_in3[124];
    wire Bge3 = DE_in3[123];
    wire Blt3 = DE_in3[122];
    wire Bne3 = DE_in3[121];
    wire Beq3 = DE_in3[120];
    wire Lui3 = DE_in3[119];
    wire Auipc3 = DE_in3[118];
    wire Jalr3 = DE_in3[117];
    wire Jal3 = DE_in3[116];
    wire Immediate_enable3 = DE_in3[115];
    wire [3:0]  Alu_opcode3 = DE_in3[114:111];
    wire [4:0]  Write_reg3 = DE_in3[110:106];
    wire [4:0]  Read_reg2_3 = DE_in3[105:101];
    wire [4:0]  Read_reg1_3 = DE_in3[100:96];
    wire [31:0] Immediate3 = DE_in3[95:64];
    wire [31:0] Read_data2_3 = DE_in3[63:32];
    wire [31:0] Read_data1_3 = DE_in3[31:0];

    wire [31:0] PC_plus4_3, Branch_target3;
    wire [1:0] ForwardA3, ForwardB3;
    reg Branch3;
    
    // Used for WB Forwarding Data
    wire WB_Jal3 = MW_out3[169];
    wire WB_Jalr3 = MW_out3[168];
    wire WB_Load3 = MW_out3[167];
    wire WB_Lui3 = MW_out3[166];
    wire WB_Auipc3 = MW_out3[165];
    wire [31:0] WB_Branch_target3 = MW_out3[159:128];
    wire [31:0] WB_Immediate3 = MW_out3[127:96];
    wire [31:0] WB_PC_plus4_3 = MW_out3[95:64];
    wire [31:0] WB_Alu_result3 = MW_out3[63:32];
    //wire [31:0] WB_RAM_out3 = MW_out3[31:0];
    wire [31:0] WB_data3;
    wire Branch_valid3 = Beq3 | Bne3 | Blt3 | Bge3 | Bltu3 | Bgeu3 | Jalr3 | Jal3;

    // 0th ALU
    // WB data mux (combinational)
    assign WB_data0 =
        WB_Load0   ? WB_RAM_out0    :
        (WB_Jalr0 || WB_Jal0) ? WB_PC_plus4_0  :
        WB_Lui0    ? WB_Immediate0  :
        WB_Auipc0  ? WB_Branch_target0 :
        WB_Alu_result0;  // default
    
    //pc incrementations for alu0
    assign PC_plus4_0 = PC0 + 4;
        
    // Multi-Lane Forwarding Logic - 0
    wire [1:0] ForwardA0_lane, ForwardB0_lane;

    Multi_Issue_Forwarding_Unit MIFWU0 (
        // EX/MEM stage - all 4 lanes
        .EX_MEM_RegWrite0(EM_outin0[176]),
        .EX_MEM_RegWrite1(EM_outin1[176]),
        .EX_MEM_RegWrite2(EM_outin2[176]),
        .EX_MEM_RegWrite3(EM_outin3[176]),
        .EX_MEM_Rd0(EM_outin0[68:64]),
        .EX_MEM_Rd1(EM_outin1[68:64]),
        .EX_MEM_Rd2(EM_outin2[68:64]),
        .EX_MEM_Rd3(EM_outin3[68:64]),
        
        // MEM/WB stage - all 4 lanes
        .MEM_WB_RegWrite0(MW_out0[170]),
        .MEM_WB_RegWrite1(MW_out1[170]),
        .MEM_WB_RegWrite2(MW_out2[170]),
        .MEM_WB_RegWrite3(MW_out3[170]),
        .MEM_WB_Rd0(MW_out0[164:160]),
        .MEM_WB_Rd1(MW_out1[164:160]),
        .MEM_WB_Rd2(MW_out2[164:160]),
        .MEM_WB_Rd3(MW_out3[164:160]),
        
        .DE_Rs1(Read_reg1_0),
        .DE_Rs2(Read_reg2_0),
        .ForwardA(ForwardA0),
        .ForwardB(ForwardB0),
        .ForwardA_lane(ForwardA0_lane),
        .ForwardB_lane(ForwardB0_lane)
    );
    
    // Create cross-lane muxes for EX/MEM forwarding
    wire [31:0] EX_MEM_forward_A0 = 
        (ForwardA0_lane == 2'b00) ? EM_outin0[31:0] :
        (ForwardA0_lane == 2'b01) ? EM_outin1[31:0] :
        (ForwardA0_lane == 2'b10) ? EM_outin2[31:0] :
        EM_outin3[31:0];

    wire [31:0] EX_MEM_forward_B0 = 
        (ForwardB0_lane == 2'b00) ? EM_outin0[31:0] :
        (ForwardB0_lane == 2'b01) ? EM_outin1[31:0] :
        (ForwardB0_lane == 2'b10) ? EM_outin2[31:0] :
        EM_outin3[31:0];
    
    // Create cross-lane muxes for MEM/WB forwarding
    wire [31:0] MEM_WB_forward_A0 = 
        (ForwardA0_lane == 2'b00) ? WB_data0 :
        (ForwardA0_lane == 2'b01) ? WB_data1 :
        (ForwardA0_lane == 2'b10) ? WB_data2 :
        WB_data3;
    
    wire [31:0] MEM_WB_forward_B0 = 
        (ForwardB0_lane == 2'b00) ? WB_data0 :
        (ForwardB0_lane == 2'b01) ? WB_data1 :
        (ForwardB0_lane == 2'b10) ? WB_data2 :
        WB_data3;
    
    // Replace the old Op1_0 assignment with:
    assign Op1_0 = (ForwardA0 == 2'b01) ? EX_MEM_forward_A0 :
                  (ForwardA0 == 2'b10) ? MEM_WB_forward_A0 :
                  Read_data1_0;
    
    // Replace the old Forwarded_Rs2_0 assignment with:
    wire [31:0] Forwarded_Rs2_0 = 
        (ForwardB0 == 2'b01) ? EX_MEM_forward_B0 :
        (ForwardB0 == 2'b10) ? MEM_WB_forward_B0 :
        Read_data2_0;
    
    // Immediate takes priority
    assign Op2_0 = (Immediate_enable0) ? Immediate0 : Forwarded_Rs2_0;    
    
    // ALU
    Alu alu0 (
        .Op1(Op1_0),
        .Op2(Op2_0),
        .Alu_result(Alu_result0),
        .Alu_op(Alu_opcode0)
    );
   
    assign Branch_target0 = Jalr0 ? Immediate0 + Op1_0  : PC0 + Immediate0;

    //This section holds the decision logic for the fetch unit
    always @(Jal0 or Jalr0 or Bne0 or Bge0 or Blt0 or Beq0 or Bgeu0 or Bltu0 or Alu_result0) begin
        if (Jal0 == 1'b1 || Jalr0 == 1'b1) begin
            Branch0 = 1'b1;
        end
        else if (Bne0 == 1'b1 && Alu_result0 != 32'h00000000) begin
            Branch0 = 1'b1;    
        end 
        else if (Bge0 == 1'b1 && Alu_result0[31] != 1'b1) begin
            Branch0 = 1'b1;    
        end
        else if (Blt0 == 1'b1 && Alu_result0[31] == 1'b1) begin
            Branch0 = 1'b1;   
        end
        else if (Beq0 == 1'b1 && Alu_result0 == 32'h0000000) begin
            Branch0 = 1'b1;    
        end
        else if (Bgeu0 == 1'b1 && Alu_result0[0] == 1'b0) begin
            Branch0 = 1'b1;    
        end
        else if (Bltu0 == 1'b1 && Alu_result0[0] == 1'b1) begin
            Branch0 = 1'b1;    
        end
        else begin
            Branch0 = 1'b0;
        end
    end

//---------------------------------------------------------------------------------------
    // 1st ALU
    // WB data mux (combinational)
    assign WB_data1 =
        WB_Load1   ? WB_RAM_out1    :
        (WB_Jalr1 || WB_Jal1) ? WB_PC_plus4_1  :
        WB_Lui1    ? WB_Immediate1  :
        WB_Auipc1  ? WB_Branch_target1 :
        WB_Alu_result1;
    
    //pc incrementations for alu0
    assign PC_plus4_1 = PC1 + 4;
    
    // Multi-Lane Forwarding Logic - 1
    wire [1:0] ForwardA1_lane, ForwardB1_lane;

    Multi_Issue_Forwarding_Unit MIFWU1 (
        // EX/MEM stage - all 4 lanes
        .EX_MEM_RegWrite0(EM_outin0[176]),
        .EX_MEM_RegWrite1(EM_outin1[176]),
        .EX_MEM_RegWrite2(EM_outin2[176]),
        .EX_MEM_RegWrite3(EM_outin3[176]),
        .EX_MEM_Rd0(EM_outin0[68:64]),
        .EX_MEM_Rd1(EM_outin1[68:64]),
        .EX_MEM_Rd2(EM_outin2[68:64]),
        .EX_MEM_Rd3(EM_outin3[68:64]),
        
        // MEM/WB stage - all 4 lanes
        .MEM_WB_RegWrite0(MW_out0[170]),
        .MEM_WB_RegWrite1(MW_out1[170]),
        .MEM_WB_RegWrite2(MW_out2[170]),
        .MEM_WB_RegWrite3(MW_out3[170]),
        .MEM_WB_Rd0(MW_out0[164:160]),
        .MEM_WB_Rd1(MW_out1[164:160]),
        .MEM_WB_Rd2(MW_out2[164:160]),
        .MEM_WB_Rd3(MW_out3[164:160]),
        
        .DE_Rs1(Read_reg1_1),
        .DE_Rs2(Read_reg2_1),
        .ForwardA(ForwardA1),
        .ForwardB(ForwardB1),
        .ForwardA_lane(ForwardA1_lane),
        .ForwardB_lane(ForwardB1_lane)
    );
    
    // Create cross-lane muxes for EX/MEM forwarding
    wire [31:0] EX_MEM_forward_A1 = 
        (ForwardA1_lane == 2'b00) ? EM_outin0[31:0] :
        (ForwardA1_lane == 2'b01) ? EM_outin1[31:0] :
        (ForwardA1_lane == 2'b10) ? EM_outin2[31:0] :
        EM_outin3[31:0];

    wire [31:0] EX_MEM_forward_B1 = 
        (ForwardB1_lane == 2'b00) ? EM_outin0[31:0] :
        (ForwardB1_lane == 2'b01) ? EM_outin1[31:0] :
        (ForwardB1_lane == 2'b10) ? EM_outin2[31:0] :
        EM_outin3[31:0];
    
    // Create cross-lane muxes for MEM/WB forwarding
    wire [31:0] MEM_WB_forward_A1 = 
        (ForwardA1_lane == 2'b00) ? WB_data0 :
        (ForwardA1_lane == 2'b01) ? WB_data1 :
        (ForwardA1_lane == 2'b10) ? WB_data2 :
        WB_data3;
    
    wire [31:0] MEM_WB_forward_B1 = 
        (ForwardB1_lane == 2'b00) ? WB_data0 :
        (ForwardB1_lane == 2'b01) ? WB_data1 :
        (ForwardB1_lane == 2'b10) ? WB_data2 :
        WB_data3;
    
    // Replace the old Op1_0 assignment with:
    assign Op1_1 = (ForwardA1 == 2'b01) ? EX_MEM_forward_A1 :
                  (ForwardA1 == 2'b10) ? MEM_WB_forward_A1 :
                  Read_data1_1;
    
    // Replace the old Forwarded_Rs2_0 assignment with:
    wire [31:0] Forwarded_Rs2_1 = 
        (ForwardB1 == 2'b01) ? EX_MEM_forward_B1 :
        (ForwardB1 == 2'b10) ? MEM_WB_forward_B1 :
        Read_data2_1;
    
    // Immediate takes priority
    assign Op2_1 = (Immediate_enable1) ? Immediate1 : Forwarded_Rs2_1;   
    
    // ALU
    Alu alu1 (
        .Op1(Op1_1),
        .Op2(Op2_1),
        .Alu_result(Alu_result1),
        .Alu_op(Alu_opcode1)
    );
   
    assign Branch_target1 = Jalr1 ? Immediate1 + Op1_1 : PC1 + Immediate1;

    //This section holds the decision logic for the fetch unit
    always @(Jal1 or Jalr1 or Bne1 or Bge1 or Blt1 or Beq1 or Bgeu1 or Bltu1 or Alu_result1) begin
        if (Jal1 == 1'b1 || Jalr1 == 1'b1) begin
            Branch1 = 1'b1;
        end
        else if (Bne1 == 1'b1 && Alu_result1 != 32'h00000000) begin
            Branch1 = 1'b1;    
        end 
        else if (Bge1 == 1'b1 && Alu_result1[31] != 1'b1) begin
            Branch1 = 1'b1;    
        end
        else if (Blt1 == 1'b1 && Alu_result1[31] == 1'b1) begin
            Branch1 = 1'b1;   
        end
        else if (Beq1 == 1'b1 && Alu_result1 == 32'h0000000) begin
            Branch1 = 1'b1;    
        end
        else if (Bgeu1 == 1'b1 && Alu_result1[0] == 1'b0) begin
            Branch1 = 1'b1;    
        end
        else if (Bltu1 == 1'b1 && Alu_result1[0] == 1'b1) begin
            Branch1 = 1'b1;    
        end
        else begin
            Branch1 = 1'b0;
        end
    end

//-------------------------------------------------------------------------------------
    // 2nd ALU
    // WB data mux (combinational)
    assign WB_data2 =
        WB_Load2   ? WB_RAM_out2    :
        (WB_Jalr2 || WB_Jal2) ? WB_PC_plus4_2  :
        WB_Lui2    ? WB_Immediate2  :
        WB_Auipc2  ? WB_Branch_target2 :
        WB_Alu_result2;
    
    //pc incrementations for alu0
    assign PC_plus4_2 = PC2 + 4;
      
    // Multi-Lane Forwarding Logic - 2
    wire [1:0] ForwardA2_lane, ForwardB2_lane;

    Multi_Issue_Forwarding_Unit MIFWU2 (
        // EX/MEM stage - all 4 lanes
        .EX_MEM_RegWrite0(EM_outin0[176]),
        .EX_MEM_RegWrite1(EM_outin1[176]),
        .EX_MEM_RegWrite2(EM_outin2[176]),
        .EX_MEM_RegWrite3(EM_outin3[176]),
        .EX_MEM_Rd0(EM_outin0[68:64]),
        .EX_MEM_Rd1(EM_outin1[68:64]),
        .EX_MEM_Rd2(EM_outin2[68:64]),
        .EX_MEM_Rd3(EM_outin3[68:64]),
        
        // MEM/WB stage - all 4 lanes
        .MEM_WB_RegWrite0(MW_out0[170]),
        .MEM_WB_RegWrite1(MW_out1[170]),
        .MEM_WB_RegWrite2(MW_out2[170]),
        .MEM_WB_RegWrite3(MW_out3[170]),
        .MEM_WB_Rd0(MW_out0[164:160]),
        .MEM_WB_Rd1(MW_out1[164:160]),
        .MEM_WB_Rd2(MW_out2[164:160]),
        .MEM_WB_Rd3(MW_out3[164:160]),
        
        .DE_Rs1(Read_reg1_2),
        .DE_Rs2(Read_reg2_2),
        .ForwardA(ForwardA2),
        .ForwardB(ForwardB2),
        .ForwardA_lane(ForwardA2_lane),
        .ForwardB_lane(ForwardB2_lane)
    );
    
    // Create cross-lane muxes for EX/MEM forwarding
    wire [31:0] EX_MEM_forward_A2 = 
        (ForwardA2_lane == 2'b00) ? EM_outin0[31:0] :
        (ForwardA2_lane == 2'b01) ? EM_outin1[31:0] :
        (ForwardA2_lane == 2'b10) ? EM_outin2[31:0] :
        EM_outin3[31:0];

    wire [31:0] EX_MEM_forward_B2 = 
        (ForwardB2_lane == 2'b00) ? EM_outin0[31:0] :
        (ForwardB2_lane == 2'b01) ? EM_outin1[31:0] :
        (ForwardB2_lane == 2'b10) ? EM_outin2[31:0] :
        EM_outin3[31:0];
    
    // Create cross-lane muxes for MEM/WB forwarding
    wire [31:0] MEM_WB_forward_A2 = 
        (ForwardA2_lane == 2'b00) ? WB_data0 :
        (ForwardA2_lane == 2'b01) ? WB_data1 :
        (ForwardA2_lane == 2'b10) ? WB_data2 :
        WB_data3;
    
    wire [31:0] MEM_WB_forward_B2 = 
        (ForwardB2_lane == 2'b00) ? WB_data0 :
        (ForwardB2_lane == 2'b01) ? WB_data1 :
        (ForwardB2_lane == 2'b10) ? WB_data2 :
        WB_data3;
    
    // Replace the old Op1_2 assignment with:
    assign Op1_2 = (ForwardA2 == 2'b01) ? EX_MEM_forward_A2 :
                  (ForwardA2 == 2'b10) ? MEM_WB_forward_A2 :
                  Read_data1_2;
    
    // Replace the old Forwarded_Rs2_2 assignment with:
    wire [31:0] Forwarded_Rs2_2 = 
        (ForwardB2 == 2'b01) ? EX_MEM_forward_B2 :
        (ForwardB2 == 2'b10) ? MEM_WB_forward_B2 :
        Read_data2_2;
    
    // Immediate takes priority
    assign Op2_2 = (Immediate_enable2) ? Immediate2 : Forwarded_Rs2_2;    
    
    // ALU
    Alu alu2 (
        .Op1(Op1_2),
        .Op2(Op2_2),
        .Alu_result(Alu_result2),
        .Alu_op(Alu_opcode2)
    );
   
    assign Branch_target2 = Jalr2 ? Immediate2 + Op1_2 : PC2 + Immediate2;

    //This section holds the decision logic for the fetch unit
    always @(Jal2 or Jalr2 or Bne2 or Bge2 or Blt2 or Beq2 or Bgeu2 or Bltu2 or Alu_result2) begin
        if (Jal2 == 1'b1 || Jalr2 == 1'b1) begin
            Branch2 = 1'b1;
        end
        else if (Bne2 == 1'b1 && Alu_result2 != 32'h00000000) begin
            Branch2 = 1'b1;    
        end 
        else if (Bge2 == 1'b1 && Alu_result2[31] != 1'b1) begin
            Branch2 = 1'b1;    
        end
        else if (Blt2 == 1'b1 && Alu_result2[31] == 1'b1) begin
            Branch2 = 1'b1;   
        end
        else if (Beq2 == 1'b1 && Alu_result2 == 32'h0000000) begin
            Branch2 = 1'b1;    
        end
        else if (Bgeu2 == 1'b1 && Alu_result2[0] == 1'b0) begin
            Branch2 = 1'b1;    
        end
        else if (Bltu2 == 1'b1 && Alu_result2[0] == 1'b1) begin
            Branch2 = 1'b1;    
        end
        else begin
            Branch2 = 1'b0;
        end
    end    
    
//-------------------------------------------------------------------------------------

    // WB data mux (combinational)
    assign WB_data3 =
        WB_Load3   ? WB_RAM_out3    :
        (WB_Jalr3 || WB_Jal3) ? WB_PC_plus4_3  :
        WB_Lui3    ? WB_Immediate3  :
        WB_Auipc3  ? WB_Branch_target3 :
        WB_Alu_result3;
    
    //pc incrementations for alu0
    assign PC_plus4_3 = PC3 + 4;
    
    // Multi-Lane Forwarding Logic - 3
    wire [1:0] ForwardA3_lane, ForwardB3_lane;

    Multi_Issue_Forwarding_Unit MIFWU3 (
        // EX/MEM stage - all 4 lanes
        .EX_MEM_RegWrite0(EM_outin0[176]),
        .EX_MEM_RegWrite1(EM_outin1[176]),
        .EX_MEM_RegWrite2(EM_outin2[176]),
        .EX_MEM_RegWrite3(EM_outin3[176]),
        .EX_MEM_Rd0(EM_outin0[68:64]),
        .EX_MEM_Rd1(EM_outin1[68:64]),
        .EX_MEM_Rd2(EM_outin2[68:64]),
        .EX_MEM_Rd3(EM_outin3[68:64]),
        
        // MEM/WB stage - all 4 lanes
        .MEM_WB_RegWrite0(MW_out0[170]),
        .MEM_WB_RegWrite1(MW_out1[170]),
        .MEM_WB_RegWrite2(MW_out2[170]),
        .MEM_WB_RegWrite3(MW_out3[170]),
        .MEM_WB_Rd0(MW_out0[164:160]),
        .MEM_WB_Rd1(MW_out1[164:160]),
        .MEM_WB_Rd2(MW_out2[164:160]),
        .MEM_WB_Rd3(MW_out3[164:160]),
        
        .DE_Rs1(Read_reg1_3),
        .DE_Rs2(Read_reg2_3),
        .ForwardA(ForwardA3),
        .ForwardB(ForwardB3),
        .ForwardA_lane(ForwardA3_lane),
        .ForwardB_lane(ForwardB3_lane)
    );
    
    // Create cross-lane muxes for EX/MEM forwarding
    wire [31:0] EX_MEM_forward_A3 = 
        (ForwardA3_lane == 2'b00) ? EM_outin0[31:0] :
        (ForwardA3_lane == 2'b01) ? EM_outin1[31:0] :
        (ForwardA3_lane == 2'b10) ? EM_outin2[31:0] :
        EM_outin3[31:0];

    wire [31:0] EX_MEM_forward_B3 = 
        (ForwardB3_lane == 2'b00) ? EM_outin0[31:0] :
        (ForwardB3_lane == 2'b01) ? EM_outin1[31:0] :
        (ForwardB3_lane == 2'b10) ? EM_outin2[31:0] :
        EM_outin3[31:0];
    
    // Create cross-lane muxes for MEM/WB forwarding
    wire [31:0] MEM_WB_forward_A3 = 
        (ForwardA3_lane == 2'b00) ? WB_data0 :
        (ForwardA3_lane == 2'b01) ? WB_data1 :
        (ForwardA3_lane == 2'b10) ? WB_data2 :
        WB_data3;
    
    wire [31:0] MEM_WB_forward_B3 = 
        (ForwardB3_lane == 2'b00) ? WB_data0 :
        (ForwardB3_lane == 2'b01) ? WB_data1 :
        (ForwardB3_lane == 2'b10) ? WB_data2 :
        WB_data3;
    
    // Replace the old Op1_2 assignment with:
    assign Op1_3 = (ForwardA3 == 2'b01) ? EX_MEM_forward_A3 :
                  (ForwardA3 == 2'b10) ? MEM_WB_forward_A3 :
                  Read_data1_3;
    
    // Replace the old Forwarded_Rs2_2 assignment with:
    wire [31:0] Forwarded_Rs2_3 = 
        (ForwardB3 == 2'b01) ? EX_MEM_forward_B3 :
        (ForwardB3 == 2'b10) ? MEM_WB_forward_B3 :
        Read_data2_3;
    
    // Immediate takes priority
    assign Op2_3 = (Immediate_enable3) ? Immediate3 : Forwarded_Rs2_3;     
    
    // ALU
    Alu alu3 (
        .Op1(Op1_3),
        .Op2(Op2_3),
        .Alu_result(Alu_result3),
        .Alu_op(Alu_opcode3)
    );
   
    assign Branch_target3 = Jalr3 ? Immediate3 + Op1_3 : PC3 + Immediate3;

    //This section holds the decision logic for the fetch unit
    always @(Jal3 or Jalr3 or Bne3 or Bge3 or Blt3 or Beq3 or Bgeu3 or Bltu3 or Alu_result3) begin
        if (Jal3 == 1'b1 || Jalr3 == 1'b1) begin
            Branch3 = 1'b1;
        end
        else if (Bne3 == 1'b1 && Alu_result3 != 32'h00000000) begin
            Branch3 = 1'b1;    
        end 
        else if (Bge3 == 1'b1 && Alu_result3[31] != 1'b1) begin
            Branch3 = 1'b1;    
        end
        else if (Blt3 == 1'b1 && Alu_result3[31] == 1'b1) begin
            Branch3 = 1'b1;   
        end
        else if (Beq3 == 1'b1 && Alu_result3 == 32'h0000000) begin
            Branch3 = 1'b1;    
        end
        else if (Bgeu3 == 1'b1 && Alu_result3[0] == 1'b0) begin
            Branch3 = 1'b1;    
        end
        else if (Bltu3 == 1'b1 && Alu_result3[0] == 1'b1) begin
            Branch3 = 1'b1;    
        end
        else begin
            Branch3 = 1'b0;
        end
    end
    
    // No check because no chance of older branch mispredict 
    wire [179:0] EM_out0 = {
        Branch_predict0, // 179
        Branch_valid0,   // 178
        Done0,           // 177
        RegWrite0,       // 176
        Branch0,         // 175
        Branch_target0,  // [174:143]
        Immediate0,      // [142:111]
        PC_plus4_0,       // [110:79]
        Unsigned0,       // 78
        Word0,           // 77
        Half0,           // 76
        Byte0,           // 75
        Store0,          // 74
        Load0,           // 73
        Lui0,            // 72
        Auipc0,          // 71
        Jalr0,           // 70
        Jal0,            // 69
        Write_reg0,      // [68:64]
        Forwarded_Rs2_0,  // [63:32] *Read_data_Rs2
        Alu_result0      // [31:0] 
    };
    
    // Checks for mispredict on older instr to make NOP
    wire [179:0] EM_out1 = (Branch_valid0 && (Branch_predict0 != Branch0)) ? {
        180'b0     
    } : {
        Branch_predict1, // 179
        Branch_valid1,   // 178
        Done1,           // 177
        RegWrite1,       // 176
        Branch1,         // 175
        Branch_target1,  // [174:143]
        Immediate1,      // [142:111]
        PC_plus4_1,       // [110:79]
        Unsigned1,       // 78
        Word1,           // 77
        Half1,           // 76
        Byte1,           // 75
        Store1,          // 74
        Load1,           // 73
        Lui1,            // 72
        Auipc1,          // 71
        Jalr1,           // 70
        Jal1,            // 69
        Write_reg1,      // [68:64]
        Forwarded_Rs2_1,  // [63:32] *Read_data_Rs2
        Alu_result1      // [31:0]     
    };
    
    // Checks for mispredict on older instr to make NOP
    wire [179:0] EM_out2 = (Branch_valid0 && (Branch_predict0 != Branch0)) ||
                           (Branch_valid1 && (Branch_predict1 != Branch1)) ? {
        180'b0    
    } : {
        Branch_predict2, // 179
        Branch_valid2,   // 178
        Done2,           // 177
        RegWrite2,       // 176
        Branch2,         // 175
        Branch_target2,  // [174:143]
        Immediate2,      // [142:111]
        PC_plus4_2,       // [110:79]
        Unsigned2,       // 78
        Word2,           // 77
        Half2,           // 76
        Byte2,           // 75
        Store2,          // 74
        Load2,           // 73
        Lui2,            // 72
        Auipc2,          // 71
        Jalr2,           // 70
        Jal2,            // 69
        Write_reg2,      // [68:64]
        Forwarded_Rs2_2,  // [63:32] *Read_data_Rs2
        Alu_result2      // [31:0]     
    };
    
    // Checks for mispredict on older instr to make NOP
    wire [179:0] EM_out3 = (Branch_valid0 && (Branch_predict0 != Branch0)) ||
                           (Branch_valid1 && (Branch_predict1 != Branch1)) ||
                           (Branch_valid2 && (Branch_predict2 != Branch2)) ? {
        180'b0     
    } : {
        Branch_predict3, // 179
        Branch_valid3,   // 178
        Done3,           // 177
        RegWrite3,       // 176
        Branch3,         // 175
        Branch_target3,  // [174:143]
        Immediate3,      // [142:111]
        PC_plus4_3,       // [110:79]
        Unsigned3,       // 78
        Word3,           // 77
        Half3,           // 76
        Byte3,           // 75
        Store3,          // 74
        Load3,           // 73
        Lui3,            // 72
        Auipc3,          // 71
        Jalr3,           // 70
        Jal3,            // 69
        Write_reg3,      // [68:64]
        Forwarded_Rs2_3,  // [63:32] *Read_data_Rs2
        Alu_result3      // [31:0]     
    };
        
    assign EM_out = {EM_out3, EM_out2, EM_out1, EM_out0};
endmodule