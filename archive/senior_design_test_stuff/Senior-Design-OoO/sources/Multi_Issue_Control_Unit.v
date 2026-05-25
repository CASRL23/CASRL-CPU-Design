`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2025 02:04:02 PM
// Design Name: 
// Module Name: Multi_Issue_Control_Unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Multi_Issue_Control_Unit(
                //inputs each instruction
                input wire [31:0] Instruction_0, Instruction_1, Instruction_2, Instruction_3,
                input wire Reset,
                //output for each control unit

                //control unit 0
                output wire [4:0] Read_reg1_0,
                output wire [4:0] Read_reg2_0,
                output wire [4:0] Write_reg_0,
                output wire [3:0] Alu_opcode_0,
                output wire Immediate_enable_0,
                output wire RegWrite_0,
                output wire Jal_0,
                output wire Jalr_0,
                output wire Load_0,
                output wire Store_0,
                output wire Auipc_0,
                output wire Lui_0,
                output wire Beq_0,
                output wire Bne_0,
                output wire Blt_0,
                output wire Bge_0,
                output wire Bltu_0,
                output wire Bgeu_0,
                output wire Byte_0,
                output wire Half_0,
                output wire Word_0,
                output wire Unsigned_0,
                output wire ALU_operation_0,  
                output wire Done_0,
                output wire [31:0] Immediate_0,
                
                
                //control unit 1  
                output wire [4:0] Read_reg1_1,
                output wire [4:0] Read_reg2_1,
                output wire [4:0] Write_reg_1,
                output wire [3:0] Alu_opcode_1,
                output wire Immediate_enable_1,
                output wire RegWrite_1,
                output wire Jal_1,
                output wire Jalr_1,
                output wire Load_1,
                output wire Store_1,
                output wire Auipc_1,
                output wire Lui_1,
                output wire Beq_1,
                output wire Bne_1,
                output wire Blt_1,
                output wire Bge_1,
                output wire Bltu_1,
                output wire Bgeu_1,
                output wire Byte_1,
                output wire Half_1,
                output wire Word_1,
                output wire Unsigned_1,
                output wire ALU_operation_1,  
                output wire Done_1,
                output wire [31:0] Immediate_1, 
                
                
                //control unit 2
                output wire [4:0] Read_reg1_2,
                output wire [4:0] Read_reg2_2,
                output wire [4:0] Write_reg_2,
                output wire [3:0] Alu_opcode_2,
                output wire Immediate_enable_2,
                output wire RegWrite_2,
                output wire Jal_2,
                output wire Jalr_2,
                output wire Load_2,
                output wire Store_2,
                output wire Auipc_2,
                output wire Lui_2,
                output wire Beq_2,
                output wire Bne_2,
                output wire Blt_2,
                output wire Bge_2,
                output wire Bltu_2,
                output wire Bgeu_2,
                output wire Byte_2,
                output wire Half_2,
                output wire Word_2,
                output wire Unsigned_2,
                output wire ALU_operation_2,  
                output wire Done_2,
                output wire [31:0] Immediate_2,
                
                
                //control unit 3
                output wire [4:0] Read_reg1_3,
                output wire [4:0] Read_reg2_3,
                output wire [4:0] Write_reg_3,
                output wire [3:0] Alu_opcode_3,
                output wire Immediate_enable_3,
                output wire RegWrite_3,
                output wire Jal_3,
                output wire Jalr_3,
                output wire Load_3,
                output wire Store_3,
                output wire Auipc_3,
                output wire Lui_3,
                output wire Beq_3,
                output wire Bne_3,
                output wire Blt_3,
                output wire Bge_3,
                output wire Bltu_3,
                output wire Bgeu_3,
                output wire Byte_3,
                output wire Half_3,
                output wire Word_3,
                output wire Unsigned_3,
                output wire ALU_operation_3,  
                output wire Done_3,
                output wire [31:0] Immediate_3                                                                            
    );
    

Control_Unit Multi_Issue_Control0(        
        .Reset(Reset),
        .Instruction(Instruction_0),
        .Immediate(Immediate_0),
        .Read_reg1(Read_reg1_0),
        .Read_reg2(Read_reg2_0),
        .Write_reg(Write_reg_0),
        .Alu_opcode(Alu_opcode_0),
        .Immediate_enable(Immediate_enable_0),
        .Jal(Jal_0),
        .Jalr(Jalr_0),
        .RegWrite(RegWrite_0),
        .Load(Load_0),
        .Store(Store_0),
        .Auipc(Auipc_0),
        .Lui(Lui_0),
        .Beq(Beq_0),
        .Bne(Bne_0),
        .Blt(Blt_0),
        .Bge(Bge_0),
        .Bltu(Bltu_0),
        .Bgeu(Bgeu_0),
        .Byte(Byte_0),
        .Half(Half_0),
        .Word(Word_0),
        .Unsigned(Unsigned_0),
        .Done(Done_0),
        .ALU_operation(ALU_operation_0));
        
        
Control_Unit Multi_Issue_Control1(
        .Reset(Reset),
        .Instruction(Instruction_1),
        .Immediate(Immediate_1),
        .Read_reg1(Read_reg1_1),
        .Read_reg2(Read_reg2_1),
        .Write_reg(Write_reg_1),
        .Alu_opcode(Alu_opcode_1),
        .Immediate_enable(Immediate_enable_1),
        .Jal(Jal_1),
        .Jalr(Jalr_1),
        .RegWrite(RegWrite_1),
        .Load(Load_1),
        .Store(Store_1),
        .Auipc(Auipc_1),
        .Lui(Lui_1),
        .Beq(Beq_1),
        .Bne(Bne_1),
        .Blt(Blt_1),
        .Bge(Bge_1),
        .Bltu(Bltu_1),
        .Bgeu(Bgeu_1),
        .Byte(Byte_1),
        .Half(Half_1),
        .Word(Word_1),
        .Unsigned(Unsigned_1),
        .Done(Done_1),
        .ALU_operation(ALU_operation_1)        
);


Control_Unit Multi_Issue_Control2(
        .Reset(Reset),
        .Instruction(Instruction_2),
        .Immediate(Immediate_2),
        .Read_reg1(Read_reg1_2),
        .Read_reg2(Read_reg2_2),
        .Write_reg(Write_reg_2),
        .Alu_opcode(Alu_opcode_2),
        .Immediate_enable(Immediate_enable_2),
        .Jal(Jal_2),
        .Jalr(Jalr_2),
        .RegWrite(RegWrite_2),
        .Load(Load_2),
        .Store(Store_2),
        .Auipc(Auipc_2),
        .Lui(Lui_2),
        .Beq(Beq_2),
        .Bne(Bne_2),
        .Blt(Blt_2),
        .Bge(Bge_2),
        .Bltu(Bltu_2),
        .Bgeu(Bgeu_2),
        .Byte(Byte_2),
        .Half(Half_2),
        .Word(Word_2),
        .Unsigned(Unsigned_2),
        .Done(Done_2),
        .ALU_operation(ALU_operation_2)
);
Control_Unit Multi_Issue_Control3(
        .Reset(Reset),
        .Instruction(Instruction_3),
        .Immediate(Immediate_3),
        .Read_reg1(Read_reg1_3),
        .Read_reg2(Read_reg2_3),
        .Write_reg(Write_reg_3),
        .Alu_opcode(Alu_opcode_3),
        .Immediate_enable(Immediate_enable_3),
        .Jal(Jal_3),
        .Jalr(Jalr_3),
        .RegWrite(RegWrite_3),
        .Load(Load_3),
        .Store(Store_3),
        .Auipc(Auipc_3),
        .Lui(Lui_3),
        .Beq(Beq_3),
        .Bne(Bne_3),
        .Blt(Blt_3),
        .Bge(Bge_3),
        .Bltu(Bltu_3),
        .Bgeu(Bgeu_3),
        .Byte(Byte_3),
        .Half(Half_3),
        .Word(Word_3),
        .Unsigned(Unsigned_3),
        .Done(Done_3),
        .ALU_operation(ALU_operation_3)
);
endmodule