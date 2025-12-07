`timescale 10ns/1ps
module Pipeline_CPU(
    output wire Done,
    output wire [31:0] Display_out,
    input wire Clk, Reset    
);

wire [64:0] FD_wire, FD_out;
wire [166:0] DE_wire, DE_out;
wire [179:0] EM_wire, EM_out;
wire [171:0] MW_wire, MW_out;
    
wire DE_write, EM_write, MW_write; 
assign DE_write = 1;
assign EM_write = 1;
assign MW_write = 1;

// Reg File writeback wires/regs
wire WB_en;
wire [4:0]  WB_addr;
wire [31:0] WB_data;

// Hazard Detection signals
wire FD_flush, DE_flush, PC_write, FD_write;

// ----------------------------------------------------------------------------------------------------------------
// FETCH
FETCH fetch_stage (
        .Clk(Clk),
        .Reset(Reset), 
        .EM_out(EM_out),       
        .FD_out(FD_wire),
        .PC_enable(PC_write),
        .Fetch_done(Done)    
    );
    
// Fetch-Decode Pipeline Reg
FD_pipeline FD_reg (
        .Clk(Clk), 
        .Reset(Reset || FD_flush),
        .en(FD_write),
        .din(FD_wire),
        .dout(FD_out)
    );
    
// ----------------------------------------------------------------------------------------------------------------
// DECODE
DECODE decode_stage (
        .Clk(Clk),
        .Reset(Reset),
        .E_branch(EM_out[175]),         // Branch signals from Execute Stage
        .E_valid_branch(EM_out[178]),
        .E_branch_predict(EM_out[179]),
        .WB_en(WB_en),
        .FD_in(FD_out),
        .WB_data(WB_data),   
        .DE_out(DE_wire),
        .DE_outin(DE_out),
        .WB_addr(WB_addr),
        .PC_write(PC_write),
        .FD_write(FD_write),
        .FD_flush(FD_flush),
        .DE_flush(DE_flush),
        .Display_out(Display_out)
    );
       
// Decode-Execute Reg
DE_pipeline DE_reg (
        .Clk(Clk),  
        .Reset(Reset || DE_flush),
        .en(DE_write),
        .din(DE_wire),
        .dout(DE_out)
    );

// ----------------------------------------------------------------------------------------------------------------
// EXECUTE
EXECUTE execute_stage (
        .Clk(Clk),
        .Reset(Reset),
        .DE_in(DE_out),
        .EM_outin(EM_out),
        .MW_out(MW_out),        
        .EM_out(EM_wire)      
    );

// Execute-Memory Pipeline Reg
EM_pipeline EM_reg (
        .Clk(Clk), 
        .Reset(Reset),
        .en(EM_write),
        .din(EM_wire),
        .dout(EM_out)
    );

// ----------------------------------------------------------------------------------------------------------------
// MEMORY
MEMORY memory_stage (
        .Clk(Clk),
        .EM_in(EM_out),
        .MW_out(MW_wire)
    );

// Memory-Writeback Pipeline Reg
MW_pipeline MW_reg (
        .Clk(Clk),
        .Reset(Reset),
        .en(MW_write),
        .din(MW_wire),
        .dout(MW_out)
    );

// ----------------------------------------------------------------------------------------------------------------
// WRITEBACK 
WRITEBACK writeback_stage (
        .Clk(Clk),
        .Reset(Reset),
        .MW_in(MW_out),
        .WB_en(WB_en),
        .WB_addr(WB_addr),
        .WB_data(WB_data),
        .Done(Done)
    );
endmodule

// Modules
module FETCH (
    input wire Clk, Reset, PC_enable, Fetch_done, 
    input wire [179:0] EM_out,
    output wire [64:0] FD_out
);
    wire [31:0] PC;
    wire [31:0] Instruction;
    
    wire Pred_taken;
    wire [31:0] Pred_target;
    
    // Compute correct PC based on actual branch outcome
    wire [31:0] PC_misprediction_correction = EM_out[175] ? EM_out[174:143] : (EM_out[110:79] + 32'd4);
    
    // Detect misprediction 
    wire Misprediction = (EM_out[178] && (EM_out[179] != EM_out[175]));
    
    Branch_predictor bp (
        .Clk(Clk),
        .Reset(Reset),
        .PC(PC),
        .Pred_taken(Pred_taken),
        .Pred_target(Pred_target),
        .Update_en(EM_out[178]),               // actual branch resolved
        .Update_taken(EM_out[175]),            // real outcome of branch
        .Update_pc(EM_out[110:79]),            // PC of the branch instr. from EXE
        .Update_target(EM_out[174:143])        // branch target
    );
    
    Fetch_unit fu (
        .Clk(Clk),
        .Reset(Reset),
        .Pc_enable(PC_enable),
        .Jalr(EM_out[70]),       
        .Fetch_done(Fetch_done),
        .Pred_taken(Pred_taken),
        .Misprediction(Misprediction),          
        .Pred_target(Pred_target),
        .Jalr_target(EM_out[174:143]),
        .PC_current(PC),
        .Branch_target(EM_out[174:143]),
        .PC_correction(PC_misprediction_correction),  
        .PC(PC)
    );

    // ROM
    ROM rom (
        .Pc(PC),
        .Instruction(Instruction)
    );
    
    assign FD_out = {
        Pred_taken,    // 64
        Instruction,   // [63:32]
        PC             // [31:0]
    };
endmodule

module DECODE (
    input  wire Clk, Reset, WB_en, E_branch, E_valid_branch, E_branch_predict,
    input wire [31:0] WB_data,
    input wire [4:0] WB_addr,
    input  wire [64:0] FD_in,
    input wire [166:0] DE_outin,
    output wire [166:0] DE_out,
    output wire PC_write, FD_write, FD_flush, DE_flush, 
    output wire [31:0] Display_out
);
    // Get Values from Pipeline Register
    wire Pred_taken = FD_in[64];
    wire [31:0] Instruction = FD_in[63:32];
    wire [31:0] PC = FD_in[31:0];
    
    // Internal Wires
    wire [31:0] Immediate, Read_data1, Read_data2;
    wire [4:0]  Read_reg1, Read_reg2, Write_reg;
    wire [3:0]  Alu_opcode;
    wire Immediate_enable, Jal, Jalr, RegWrite, Load, Store, Auipc, Lui;
    wire Beq, Bne, Blt, Bge, Bltu, Bgeu;
    wire Byte, Half, Word, Unsigned;
    wire ALU_operation, Done;
    wire Stall;
    
    // Control Unit
    Control_Unit cu (
        .Reset(Reset),
        .Instruction(Instruction),
        .Immediate(Immediate),
        .Read_reg1(Read_reg1),
        .Read_reg2(Read_reg2),
        .Write_reg(Write_reg),
        .Alu_opcode(Alu_opcode),
        .Immediate_enable(Immediate_enable),
        .Jal(Jal),
        .Jalr(Jalr),
        .RegWrite(RegWrite),
        .Load(Load),
        .Store(Store),
        .Auipc(Auipc),
        .Lui(Lui),
        .Beq(Beq),
        .Bne(Bne),
        .Blt(Blt),
        .Bge(Bge),
        .Bltu(Bltu),
        .Bgeu(Bgeu),
        .Byte(Byte),
        .Half(Half),
        .Word(Word),
        .Unsigned(Unsigned),
        .Done(Done),
        .ALU_operation(ALU_operation)
    );

    // Register File
    Reg_file rf (
        .Clk(Clk),
        .Reset(Reset),
        .Read_data1(Read_data1),
        .Read_data2(Read_data2),
        .Display_out(Display_out),
        .Read_reg1(Read_reg1),
        .Read_reg2(Read_reg2),
        .Write_reg(WB_addr),            // Write Register from Writeback Stage
        .Data_in(WB_data),              // Write Data from Writeback Stage
        .WB_en(WB_en)                   // Writeback Enable from Writeback Stage
    );
    
    Hazard_detection hd (
        .DE_MemRead(DE_outin[126]),
        .DE_Rd(DE_outin[110:106]),
        .FD_Rs1(Read_reg1),
        .FD_Rs2(Read_reg2),
        .E_branch(E_branch),                // From execute stage
        .E_pred_taken(E_branch_predict),    //Prediction from Fetch stage
        .E_valid_branch(E_valid_branch),    // From execute stage
        .PC_write(PC_write),
        .FD_write(FD_write),
        .FD_flush(FD_flush),
        .DE_flush(DE_flush),
        .Stall(Stall)
    );
    
    assign DE_out = (Stall) ? {
        Pred_taken,         // 166
        Done,               // 165    
        PC,                 // [164:133]
        18'b0,              // All Control Signals
        Alu_opcode,         // [114:111]
        Write_reg,          // [110:106]
        Read_reg2,          // [105:101]
        Read_reg1,          // [100:96]
        Immediate,          // [95:64]
        Read_data2,         // [63:32]
        Read_data1          // [31:0]         
    } : {
        Pred_taken,         // 166
        Done,               // 165
        PC,                 // [164:133]
        RegWrite,           // 132
        Unsigned,           // 131      
        Word,               // 130
        Half,               // 129
        Byte,               // 128
        Store,              // 127
        Load,               // 126
        Bgeu,               // 125
        Bltu,               // 124
        Bge,                // 123
        Blt,                // 122
        Bne,                // 121
        Beq,                // 120
        Lui,                // 119
        Auipc,              // 118
        Jalr,               // 117
        Jal,                // 116
        Immediate_enable,   // 115
        Alu_opcode,         // [114:111]
        Write_reg,          // [110:106]
        Read_reg2,          // [105:101]
        Read_reg1,          // [100:96]
        Immediate,          // [95:64]
        Read_data2,         // [63:32]
        Read_data1          // [31:0]         
    };
endmodule

module EXECUTE (
    input  wire Clk, Reset,
    input  wire [166:0] DE_in,
    input  wire [179:0] EM_outin,       // Used for Forwarding
    input  wire [171:0] MW_out,         // Used for Forwarding
    output wire [179:0] EM_out  
);
    
    // Get Values from Pipeline Register
    wire Branch_predict = DE_in[166];
    wire Done = DE_in[165];
    wire [31:0] PC = DE_in[164:133];
    wire RegWrite = DE_in[132];
    wire Unsigned = DE_in[131];
    wire Word = DE_in[130];
    wire Half = DE_in[129];
    wire Byte = DE_in[128];
    wire Store = DE_in[127];
    wire Load = DE_in[126];
    wire Bgeu = DE_in[125];
    wire Bltu = DE_in[124];
    wire Bge = DE_in[123];
    wire Blt = DE_in[122];
    wire Bne = DE_in[121];
    wire Beq = DE_in[120];
    wire Lui = DE_in[119];
    wire Auipc = DE_in[118];
    wire Jalr = DE_in[117];
    wire Jal = DE_in[116];
    wire Immediate_enable= DE_in[115];
    wire [3:0]  Alu_opcode = DE_in[114:111];
    wire [4:0]  Write_reg = DE_in[110:106];
    wire [4:0]  Read_reg2 = DE_in[105:101];
    wire [4:0]  Read_reg1 = DE_in[100:96];
    wire [31:0] Immediate = DE_in[95:64];
    wire [31:0] Read_data2 = DE_in[63:32];
    wire [31:0] Read_data1 = DE_in[31:0];
    
    wire [31:0] Op1, Op2;
    wire [31:0] Alu_result, Branch_target;
    wire [1:0] ForwardA, ForwardB;
    reg Branch;
    
    // Assigning 
    assign Branch_target = Jalr ? Op1 + Immediate : PC + Immediate;  // This is also used for AUIPC
    
    // Used for WB Forwarding Data
    wire WB_Jal = MW_out[169];
    wire WB_Jalr = MW_out[168];
    wire WB_Load = MW_out[167];
    wire WB_Lui = MW_out[166];
    wire WB_Auipc = MW_out[165];
    wire [31:0] WB_Branch_target = MW_out[159:128];
    wire [31:0] WB_Immediate = MW_out[127:96];
    wire [31:0] WB_PC_plus4 = MW_out[95:64];
    wire [31:0] WB_Alu_result = MW_out[63:32];
    wire [31:0] WB_RAM_out = MW_out[31:0];
    wire [31:0] WB_data;
    wire Branch_valid = Beq | Bne | Blt | Bge | Bltu | Bgeu | Jalr | Jal;
    
    // WB data mux (combinational)
    assign WB_data =
        WB_Load   ? WB_RAM_out    :
        (WB_Jalr || WB_Jal) ? WB_PC_plus4  :
        WB_Lui    ? WB_Immediate  :
        WB_Auipc  ? WB_Branch_target :
        WB_Alu_result;  // default
    
    Forwarding_unit fu (
        .EX_MEM_RegWrite(EM_outin[176]),
        .MEM_WB_RegWrite(MW_out[170]),
        .EX_MEM_Rd(EM_outin[68:64]),
        .MEM_WB_Rd(MW_out[164:160]),
        .DE_Rs1(Read_reg1),
        .DE_Rs2(Read_reg2),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );
  
    // Operand A
    assign Op1 = (ForwardA == 2'b01) ? EM_outin[31:0] :         // from EX/MEM ALU
                  (ForwardA == 2'b10) ? WB_data       :         // from WB stage
                  Read_data1;                                   // default (register file)
    
    // Operand B 
    wire [31:0] Forwarded_Rs2 = 
        (ForwardB == 2'b01) ? EM_outin[31:0] :  // from EX/MEM ALU
        (ForwardB == 2'b10) ? WB_data :         // from WB Stage
        Read_data2;                             // default

    // Immediate takes priority
    assign Op2 = (Immediate_enable) ? Immediate : Forwarded_Rs2;    
    
    // ALU
    Alu alu (
        .Op1(Op1),
        .Op2(Op2),
        .Alu_result(Alu_result),
        .Alu_op(Alu_opcode)
    );
   
    //This section holds the decision logic for the fetch unit
    always @(Jal or Jalr or Bne or Bge or Blt or Beq or Bgeu or Bltu or Alu_result) begin
        if (Jal == 1'b1 || Jalr == 1'b1) begin
            Branch = 1'b1;
        end
        else if (Bne == 1'b1 && Alu_result != 32'h00000000) begin
            Branch = 1'b1;    
        end 
        else if (Bge == 1'b1 && Alu_result[31] != 1'b1) begin
            Branch = 1'b1;    
        end
        else if (Blt == 1'b1 && Alu_result[31] == 1'b1) begin
            Branch = 1'b1;   
        end
        else if (Beq == 1'b1 && Alu_result == 32'h0000000) begin
            Branch = 1'b1;    
        end
        else if (Bgeu == 1'b1 && Alu_result[0] == 1'b0) begin   // Uses SLTU to check for branch
            Branch = 1'b1;    
        end
        else if (Bltu == 1'b1 && Alu_result[0] == 1'b1) begin
            Branch = 1'b1;    
        end
        else begin
            Branch = 1'b0;
        end
    end

    assign EM_out = {
        Branch_predict, // 179
        Branch_valid,   // 178
        Done,           // 177
        RegWrite,       // 176
        Branch,         // 175
        Branch_target,  // [174:143]
        Immediate,      // [142:111]
        PC,             // [110:79]
        Unsigned,       // 78
        Word,           // 77
        Half,           // 76
        Byte,           // 75
        Store,          // 74
        Load,           // 73
        Lui,            // 72
        Auipc,          // 71
        Jalr,           // 70
        Jal,            // 69
        Write_reg,      // [68:64]
        Forwarded_Rs2,  // [63:32] *Read_data_Rs2
        Alu_result      // [31:0]     
    };
endmodule

module MEMORY (
    input  wire Clk,
    input  wire [179:0] EM_in,
    output wire [171:0] MW_out
);  
    wire Done = EM_in[177];
    wire RegWrite = EM_in[176];
    wire [31:0] Branch_target = EM_in[174:143];
    wire [31:0] Immediate = EM_in[142:111];
    wire [31:0] PC = EM_in[110:79];
    wire Unsigned = EM_in[78];
    wire Word = EM_in[77];
    wire Half = EM_in[76];
    wire Byte = EM_in[75];
    wire Store = EM_in[74];
    wire Load = EM_in[73];
    wire Lui = EM_in[72];
    wire Auipc = EM_in[71];
    wire Jalr = EM_in[70];
    wire Jal = EM_in[69];
    wire [4:0] Write_reg = EM_in[68:64];
    wire [31:0] Read_data2 = EM_in[63:32];
    wire [31:0] Alu_result = EM_in[31:0];
    
    wire [31:0] RAM_out;
    // RAM
    RAM ram (
        .Clk(Clk),
        .Address(Alu_result),
        .Data_in(Read_data2),
        .Data_out(RAM_out),
        .Store(Store),
        .Byte(Byte),
        .Word(Word),
        .Half(Half),
        .Unsigned(Unsigned)
    );

    assign MW_out = {
        Done,           // 171
        RegWrite,       // 170 - WB_en
        Jal,            // 169
        Jalr,           // 168
        Load,           // 167
        Lui,            // 166
        Auipc,          // 165
        Write_reg,      // [164:160] - WB_addr
        Branch_target,  // [159:128]
        Immediate,      // [127:96]
        PC,             // [95:64]
        EM_in[31:0],    // [63:32] - ALU result
        RAM_out         // [31:0]
    };

endmodule

module WRITEBACK (
    input wire Clk, Reset,
    input  wire [171:0] MW_in,
    output wire WB_en,
    output wire [4:0] WB_addr,
    output wire [31:0] WB_data,
    output wire Done
);
    reg done_reg;
    assign WB_addr = MW_in[164:160];

    wire Jal= MW_in[169];
    wire Jalr = MW_in[168];
    wire Load = MW_in[167];
    wire Lui = MW_in[166];
    wire Auipc = MW_in[165];
    wire [31:0] Branch_target = MW_in[159:128];
    wire [31:0] Immediate = MW_in[127:96];
    wire [31:0] PC = MW_in[95:64];
    wire [31:0] Alu_result = MW_in[63:32];
    wire [31:0] RAM_out = MW_in[31:0];

    assign WB_data = Load  ? RAM_out :
                     (Jalr || Jal) ? PC + 32'd4   :
                     Lui   ? Immediate   :
                     Auipc ? Branch_target :
                             Alu_result;
     always @(posedge Clk or posedge Reset) begin
        if (Reset)
            done_reg <= 1'b0;
        else if (MW_in[171])    
            done_reg <= 1'b1;
     end
     
     assign Done = done_reg;  
     // Disable later writebacks if an earlier "done" is set
     assign WB_en = MW_in[170] && !Done;
     
endmodule