//This module holds the control unit. Takes in the Instruction from ROM and decodes into the appropriate signals

module Control_Unit(
    input wire [31:0] Instruction,
    input wire Reset, 
    output reg [4:0] Read_reg1,
    output reg [4:0] Read_reg2,
    output reg [4:0] Write_reg,
    output reg [3:0] Alu_opcode,
    output reg Immediate_enable,
    output reg RegWrite,
    output reg Jal,
    output reg Jalr,
    output reg Load,
    output reg Store,
    output reg Auipc,
    output reg Lui,
    output reg Beq,
    output reg Bne,
    output reg Blt,
    output reg Bge,
    output reg Bltu,
    output reg Bgeu,
    output reg Byte,
    output reg Half,
    output reg Word,
    output reg Unsigned,
    output reg ALU_operation,  
    output reg Done,
    output reg [31:0] Immediate
);

    // Extract opcode and function fields
    wire [6:0] Op_code = Instruction[6:0];
    wire [2:0] Funct3  = Instruction[14:12];
    wire [6:0] Funct7  = Instruction[31:25];
    
    // Immediate fields
    wire [11:0] I_type_imm = Instruction[31:20];
    wire [11:0] S_type_imm = {Instruction[31:25], Instruction[11:7]};
    wire [12:0] B_type_imm = {Instruction[31], Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};
    wire [19:0] U_type_imm = Instruction[31:12];
    wire [20:0] J_type_imm = {Instruction[31], Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0};

    always @(Instruction,
                Op_code,
                Funct7,
                Funct3,
                I_type_imm,
                S_type_imm,
                B_type_imm,
                J_type_imm,
                U_type_imm,
                Reset
            ) begin
        
        if (Reset == 1'b1) begin
            Read_reg1        = 5'h0;
            Read_reg2        = 5'h0;
            Write_reg        = 5'h0;
            Auipc            = 1'b0;
            Alu_opcode       = 4'h0;
            RegWrite         = 1'b0;
            Immediate_enable = 1'b0;
            Jal              = 1'b0;
            Jalr             = 1'b0;
            Load             = 1'b0;
            Load             = 1'b0;
            Store            = 1'b0;
            Auipc            = 1'b0;
            Lui              = 1'b0;
            Beq              = 1'b0;
            Bne              = 1'b0;
            Blt              = 1'b0;
            Bge              = 1'b0;
            Bltu             = 1'b0;
            Bgeu             = 1'b0;
            Byte             = 1'b0;
            Half             = 1'b0;
            Word             = 1'b0;
            Unsigned         = 1'b0;
            ALU_operation    = 1'b0;
            Done             = 1'b0;
            Immediate        = 32'h00000000;
        end
           
        // ----------------------
        // Instruction decoding
        // ----------------------
        case(Op_code)
            7'b1111111: begin //Done begin
                Read_reg1        = 5'h0;
                Read_reg2        = 5'h0;
                Write_reg        = 5'h0;
                RegWrite         = 1'b0;
                Auipc            = 1'b0;
                Alu_opcode       = 4'h0;
                Immediate_enable = 1'b0;
                Jal              = 1'b0;
                Jalr             = 1'b0;
                Load             = 1'b0;
                Store            = 1'b0;
                Lui              = 1'b0;
                Beq              = 1'b0;
                Bne              = 1'b0;
                Blt              = 1'b0;
                Bge              = 1'b0;
                Bltu             = 1'b0;
                Bgeu             = 1'b0;
                Byte             = 1'b0;
                Half             = 1'b0;
                Word             = 1'b0;
                Unsigned         = 1'b0;
                ALU_operation    = 1'b0;
                Immediate        = 32'h00000000;
                Done             = 1'b0; 
                if (Instruction == 32'hFFFFFFFF) begin
                    Done = 1'b1;
                end else begin
                    Done = 1'b0;
                end
            end
        
            7'b0110011: begin // R-type
                Read_reg1  = Instruction[19:15];
                Read_reg2  = Instruction[24:20];
                Write_reg  = Instruction[11:7];
                Auipc = 1'b0;
                Immediate_enable = 1'b0;
                Lui = 1'b0;
                Jal = 1'b0;
                Jalr = 1'b0;
                Immediate = 0;
                RegWrite         = 1'b1;
                Load = 1'b0;
                Store = 1'b0;
                Beq              = 1'b0;
                Bne              = 1'b0;
                Blt              = 1'b0;
                Bge              = 1'b0;
                Bltu             = 1'b0;                
                Bgeu = 1'b0;
                Byte             = 1'b0;
                Half             = 1'b0;
                Word             = 1'b0;
                Unsigned         = 1'b0;
                ALU_operation    = 1'b1;
                Done             = 1'b0;                    
        
                case({Funct7, Funct3})
                    10'b0000000000: Alu_opcode = 4'h0; // ADD
                    10'b0100000000: Alu_opcode = 4'h1; // SUB
                    10'b0000000111: Alu_opcode = 4'h4; // AND
                    10'b0000000110: Alu_opcode = 4'h3; // OR
                    10'b0000000100: Alu_opcode = 4'h2; // XOR
                    10'b0000000001: Alu_opcode = 4'h5; // SLL
                    10'b0000000101: Alu_opcode = 4'h6; // SRL
                    10'b0100000101: Alu_opcode = 4'h7; // SRA
                    10'b0000000010: Alu_opcode = 4'h8; // SLT
                    10'b0000000011: Alu_opcode = 4'h9; // SLTU
                    default: begin 
                        Alu_opcode = 4'h0;
                    end
                endcase
            end

            7'b0010011: begin // I-type ALU
                Read_reg1  = Instruction[19:15];
                Read_reg2 = 0; // NULL
                Write_reg  = Instruction[11:7];
                Auipc = 1'b0;
                Jal = 1'b0;
                Jalr = 1'b0;
                Load = 1'b0;
                Store = 1'b0;
                Immediate_enable = 1'b1;
                RegWrite = 1'b1;
                Lui = 1'b0;
                Immediate = {{20{I_type_imm[11]}}, I_type_imm};
                Beq              = 1'b0;
                Bne              = 1'b0;
                Blt              = 1'b0;
                Bge              = 1'b0;
                Bltu             = 1'b0;                
                Bgeu             = 1'b0;
                Byte             = 1'b0;
                Half             = 1'b0;
                Word             = 1'b0;
                Unsigned         = 1'b0;
                ALU_operation    = 1'b1;                
                Done             = 1'b0;
                                                
                case(Funct3)
                    3'b000: Alu_opcode = 4'h0; // ADDI
                    3'b010: Alu_opcode = 4'h8; // SLTI
                    3'b011: Alu_opcode = 4'h9; // SLTIU
                    3'b100: Alu_opcode = 4'h2; // XORI
                    3'b110: Alu_opcode = 4'h3; // ORI
                    3'b111: Alu_opcode = 4'h4; // ANDI
                    3'b001: begin // SLLI
                        Alu_opcode = 4'h5;
                        Immediate = {27'b0, I_type_imm[4:0]};
                    end
                    3'b101: begin
                        if(Funct7 == 7'b0000000) begin // SRLI
                            Alu_opcode = 4'h6;
                        end else if(Funct7 == 7'b0100000) begin // SRAI
                            Alu_opcode = 4'h7;
                        end
                        // Latching culprit
                        else begin
                        // What operation here?
                            Alu_opcode = 4'h0;
                        end
                        Immediate = {27'b0, I_type_imm[4:0]};
                    end
                    default: begin
                        Alu_opcode = 4'h0;
                    end
                endcase
            end

            7'b0000011: begin // Load
                Read_reg1  = Instruction[19:15];
                Read_reg2 = 0;
                Write_reg  = Instruction[11:7];
                Auipc = 1'b0;
                Immediate_enable = 1'b1;
                Lui = 1'b0;
                Jal = 1'b0;
                Jalr = 1'b0;
                Immediate = {{20{I_type_imm[11]}}, I_type_imm};
                RegWrite = 1'b1;
                Load = 1'b1;
                Store = 1'b0;
                Alu_opcode = 4'd0;
                Beq              = 1'b0;
                Bne              = 1'b0;
                Blt              = 1'b0;
                Bge              = 1'b0;
                Bltu             = 1'b0;                
                Bgeu = 1'b0;
                Byte             = 1'b0;
                Half             = 1'b0;
                Word             = 1'b0;
                Unsigned         = 1'b0;
                ALU_operation    = 1'b0;                
                Done             = 1'b0;                
                                     
                case(Funct3)
                    3'b000: begin
                        Byte = 1'b1;  Half = 1'b0; Unsigned = 1'b0; Word = 1'b0; // LB
                        end
                    3'b001: begin
                        Byte = 1'b0;  Half = 1'b1; Unsigned = 1'b0; Word = 1'b0;   // LH
                        end
                    3'b010: begin
                        Byte = 1'b0;  Half = 1'b0; Unsigned = 1'b0; Word = 1'b1;   // LW
                        end
                    3'b100: begin 
                        Byte = 1'b1;  Half = 1'b0; Unsigned = 1'b1; Word = 1'b0;   // LBU
                        end
                    3'b101: begin
                        Byte = 1'b0;  Half = 1'b1; Unsigned = 1'b1; Word = 1'b0;  // LHU
                        end
                endcase
            end

            7'b0100011: begin // Store
                Read_reg1 = Instruction[19:15];
                Read_reg2 = Instruction[24:20];
                Write_reg = 0;
                Auipc = 1'b0;
                Immediate_enable = 1'b1;
                Lui = 1'b0;
                Jal = 1'b0;
                Jalr = 1'b0;
                Immediate = {{20{S_type_imm[11]}}, S_type_imm};
                RegWrite = 1'b0;
                Store = 1'b1;
                Load = 1'b0;
                Alu_opcode = 4'd0;
                Beq              = 1'b0;
                Bne              = 1'b0;
                Blt              = 1'b0;
                Bge              = 1'b0;
                Bltu             = 1'b0;                
                Bgeu = 1'b0;
                Byte             = 1'b0;
                Half             = 1'b0;
                Word             = 1'b0;
                Unsigned         = 1'b0;
                ALU_operation    = 1'b0;                               
                Done             = 1'b0;
                               
                case(Funct3)
                    3'b000: begin
                       Byte = 1'b1; Half = 1'b0; Word = 1'b0;// SB
                    end
                    3'b001: begin
                       Byte = 1'b0; Half = 1'b1; Word = 1'b0;// SH
                    end
                    3'b010: begin 
                       Byte = 1'b0; Half = 1'b0; Word = 1'b1; // SW
                    end
                    default: begin
                       Byte = 1'b0; Half = 1'b0; Word = 1'b0; // SW                    
                    end
                endcase
            end

            7'b1100011: begin // Branch
                Read_reg1 = Instruction[19:15];
                Read_reg2 = Instruction[24:20];
                Write_reg = 0;
                Auipc = 1'b0;
                Immediate_enable = 1'b0;
                RegWrite = 1'b0;
                Lui = 1'b0;
                Jal = 1'b0;
                Jalr = 1'b0;
                Store = 1'b0;
                Load = 1'b0;
                Immediate = {{19{B_type_imm[12]}}, B_type_imm}; // sign-extend
                Alu_opcode = 4'd1;
                Byte             = 1'b0;
                Half             = 1'b0;
                Word             = 1'b0;
                Unsigned         = 1'b0;
                ALU_operation    = 1'b0;                
                Done             = 1'b0;
                                
                case(Funct3)
                    3'b000: begin
                        Beq = 1'b1; 
                        Bne = 1'b0; 
                        Blt = 1'b0; 
                        Bge = 1'b0;
                        Bltu = 1'b0;
                        Bgeu = 1'b0;
                    end
                    3'b001: begin
                        Beq = 1'b0; 
                        Bne = 1'b1; 
                        Blt = 1'b0; 
                        Bge = 1'b0;
                        Bltu = 1'b0;
                        Bgeu = 1'b0;
                    end
                    3'b100: begin
                        Beq = 1'b0; 
                        Bne = 1'b0; 
                        Blt = 1'b1; 
                        Bge = 1'b0;
                        Bltu = 1'b0;
                        Bgeu = 1'b0;
                    end
                    3'b101: begin
                        Beq = 1'b0; 
                        Bne = 1'b0; 
                        Blt = 1'b0; 
                        Bge = 1'b1;
                        Bltu = 1'b0;
                        Bgeu = 1'b0;
                    end
                    3'b110: begin 
                        Beq = 1'b0; 
                        Bne = 1'b0; 
                        Blt = 1'b0; 
                        Bge = 1'b0;
                        Bltu = 1'b1;
                        Bgeu = 1'b0;
                        Alu_opcode = 4'h9;
                    end
                    3'b111: begin
                        Beq = 1'b0; 
                        Bne = 1'b0; 
                        Blt = 1'b0; 
                        Bge = 1'b0;
                        Bltu = 1'b0;
                        Bgeu = 1'b1;
                        Alu_opcode = 4'h9;
                    end
                    default: begin
                        Beq = 1'b1; 
                        Bne = 1'b0; 
                        Blt = 1'b0; 
                        Bge = 1'b0;
                        Bltu = 1'b0;
                        Bgeu = 1'b0;
                    end
                endcase
            end

            7'b1101111: begin // JAL
                Read_reg1 = 0;
                Read_reg2 = 0;
                Write_reg = Instruction[11:7];
                RegWrite = 1'b1;
                Auipc = 1'b0;
                Jal = 1'b1;
                Jalr = 1'b0;
                Lui = 1'b0;
                Store = 1'b0;
                Load = 1'b0;
                Immediate_enable = 1'b1;
                Immediate = {{11{J_type_imm[20]}}, J_type_imm}; // sign-extend
                Alu_opcode = 4'd0;
                Beq              = 1'b0;
                Bne              = 1'b0;
                Blt              = 1'b0;
                Bge              = 1'b0;
                Bltu             = 1'b0;                
                Bgeu = 1'b0;
                Byte             = 1'b0;
                Half             = 1'b0;
                Word             = 1'b0;
                Unsigned         = 1'b0;
                ALU_operation    = 1'b0;
                Done             = 1'b0;                                                
            end

            7'b1100111: begin // JALR
                Read_reg1 = Instruction[19:15];
                Read_reg2 = 0;
                Write_reg = Instruction[11:7];
                RegWrite = 1'b1;
                Auipc = 1'b0;
                Jalr = 1'b1;
                Jal = 1'b0;
                Lui = 1'b0;
                Load = 1'b0;
                Store = 1'b0;
                Immediate_enable = 1'b1;
                Immediate = {{20{I_type_imm[11]}}, I_type_imm};
                Alu_opcode = 4'd0;
                Beq              = 1'b0;
                Bne              = 1'b0;
                Blt              = 1'b0;
                Bge              = 1'b0;
                Bltu             = 1'b0;                
                Bgeu = 1'b0;                
                Byte             = 1'b0;
                Half             = 1'b0;
                Word             = 1'b0;
                Unsigned         = 1'b0;
                ALU_operation    = 1'b0; 
                Done             = 1'b0;                               
            end

            7'b0110111: begin // LUI
                Read_reg1 = 0;
                Read_reg2 = 0;
                Write_reg = Instruction[11:7];
                RegWrite = 1'b1;
                Auipc = 1'b0;
                Lui = 1'b1;
                Load = 1'b0;
                Store = 1'b0;
                Immediate_enable = 1'b1;
                Jal = 1'b0;
                Jalr = 1'b0;
                Immediate = {U_type_imm, 12'b0};
                Alu_opcode = 4'd0;
                Beq              = 1'b0;
                Bne              = 1'b0;
                Blt              = 1'b0;
                Bge              = 1'b0;
                Bltu             = 1'b0;                
                Bgeu = 1'b0;               
                Byte             = 1'b0;
                Half             = 1'b0;
                Word             = 1'b0;
                Unsigned         = 1'b0;
                ALU_operation    = 1'b0;
                Done             = 1'b0;                                
            end

            7'b0010111: begin // AUIPC
                Read_reg1 = 0;
                Read_reg2 = 0;
                Write_reg = Instruction[11:7];
                Auipc = 1'b1;
                Lui = 1'b0;
                Immediate_enable = 1'b1;
                RegWrite = 1'b1;
                Jal = 1'b0;
                Jalr = 1'b0;
                Load = 1'b0;
                Store = 1'b0;
                Immediate = {U_type_imm, 12'b0};
                Alu_opcode = 4'd0;
                Beq              = 1'b0;
                Bne              = 1'b0;
                Blt              = 1'b0;
                Bge              = 1'b0;
                Bltu             = 1'b0;                
                Bgeu = 1'b0;
                Byte             = 1'b0;
                Half             = 1'b0;
                Word             = 1'b0;
                Unsigned         = 1'b0;
                ALU_operation    = 1'b0;
                Done             = 1'b0;                                
            end

            default: begin
                // Keep defaults
                Read_reg1        = 5'h0;
                Read_reg2        = 5'h0;
                Write_reg        = 5'h0;
                Auipc            = 1'b0;
                Alu_opcode       = 4'd0;
                Immediate_enable = 1'b0;
                RegWrite = 1'b0;
                Jal              = 1'b0;
                Jalr             = 1'b0;
                Load            = 1'b0;
                Store            = 1'b0;
                Auipc            = 1'b0;
                Lui              = 1'b0;
                Beq              = 1'b0;
                Bne              = 1'b0;
                Blt              = 1'b0;
                Bge              = 1'b0;
                Bltu             = 1'b0;
                Bgeu             = 1'b0;
                Byte             = 1'b0;
                Half             = 1'b0;
                Word             = 1'b0;
                Unsigned         = 1'b0;
                ALU_operation    = 1'b0;                
                Done             = 1'b0;
                Immediate        = 32'h00000000;
            end
        endcase
    end
endmodule