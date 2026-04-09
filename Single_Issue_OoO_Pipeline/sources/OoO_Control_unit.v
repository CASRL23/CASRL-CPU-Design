module OoO_Control_Unit(
    input wire [31:0] Instruction, 
    output reg [4:0] Read_reg1,
    output reg [4:0] Read_reg2,
    output reg [4:0] Write_reg,
    output reg [4:0] Instruction_type,
    output reg Immediate_enable, 
    output reg Has_Rd,
    output reg Done,
    output reg [31:0] Immediate
);

    // Extract opcode and function fields
    wire [6:0] Op_code = Instruction[6:0];
    wire [2:0] Funct3  = Instruction[14:12];
    wire [6:0] Funct7  = Instruction[31:25];
    
    // Immediate fields (Extraction remains unchanged)
    wire [11:0] I_type_imm = Instruction[31:20];
    wire [11:0] S_type_imm = {Instruction[31:25], Instruction[11:7]};
    wire [12:0] B_type_imm = {Instruction[31], Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};
    wire [19:0] U_type_imm = Instruction[31:12];
    wire [20:0] J_type_imm = {Instruction[31], Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0};

    // This block is now purely combinational, driven only by the instruction
    always @(*) begin
        
        // 1. DEFAULT ASSIGNMENTS (Prevents Latches)
        // Everything defaults to 0 (or safe values) if not assigned in a case.
        Read_reg1        = 5'd0;
        Read_reg2        = 5'd0;
        Write_reg        = 5'd0;
        Instruction_type = 5'd0;
        Immediate_enable = 1'b0;
        Immediate        = 32'd0;
        Done             = 1'b0; // Default state is NOT done
        Has_Rd           = 1'b0;

        // 1. Done signal
        if (Instruction == 32'hffffffff) begin
            Done = 1'b1;
        end
        // 2. INSTRUCTION DECODING
        case(Op_code)
    
            7'b0110011: begin // R-type
                Read_reg1 = Instruction[19:15];
                Read_reg2 = Instruction[24:20];
                Write_reg = Instruction[11:7];
                Has_Rd    = 1'b1;
                
                case({Funct7, Funct3})
                    10'b0000000000: Instruction_type = 5'h0; // ADD
                    10'b0100000000: Instruction_type = 5'h1; // SUB
                    10'b0000000111: Instruction_type = 5'h4; // AND
                    10'b0000000110: Instruction_type = 5'h3; // OR
                    10'b0000000100: Instruction_type = 5'h2; // XOR
                    10'b0000000001: Instruction_type = 5'h5; // SLL
                    10'b0000000101: Instruction_type = 5'h6; // SRL
                    10'b0100000101: Instruction_type = 5'h7; // SRA
                    10'b0000000010: Instruction_type = 5'h8; // SLT
                    10'b0000000011: Instruction_type = 5'h9; // SLTU
                endcase
            end

            7'b0010011: begin // I-type ALU
                Read_reg1 = Instruction[19:15];
                Write_reg = Instruction[11:7];
                Immediate_enable = 1'b1;
                Immediate = {{20{I_type_imm[11]}}, I_type_imm}; // Sign Ext
                Has_Rd    = 1'b1;

                case(Funct3)
                    3'b000: Instruction_type = 5'd0; // ADDI
                    3'b010: Instruction_type = 5'd8; // SLTI
                    3'b011: Instruction_type = 5'd9; // SLTIU
                    3'b100: Instruction_type = 5'd2; // XORI
                    3'b110: Instruction_type = 5'd3; // ORI
                    3'b111: Instruction_type = 5'd4; // ANDI
                    3'b001: begin // SLLI
                        Instruction_type = 5'd5;
                        Immediate = {27'b0, I_type_imm[4:0]}; // Shamt
                    end
                    3'b101: begin
                        Immediate = {27'b0, I_type_imm[4:0]}; // Shamt
                        if(Funct7 == 7'b0000000)      Instruction_type = 5'd6; // SRLI
                        else if(Funct7 == 7'b0100000) Instruction_type = 5'd7; // SRAI
                    end
                endcase
            end

            7'b0000011: begin // Load
                Read_reg1 = Instruction[19:15];
                Write_reg = Instruction[11:7];
                Immediate_enable = 1'b1;
                Immediate = {{20{I_type_imm[11]}}, I_type_imm};
                Has_Rd    = 1'b1;
                
                case(Funct3)
                    3'b000: Instruction_type = 5'd10; // LB
                    3'b001: Instruction_type = 5'd11; // LH
                    3'b010: Instruction_type = 5'd12; // LW
                    3'b100: Instruction_type = 5'd13; // LBU
                    3'b101: Instruction_type = 5'd14; // LHU
                endcase
            end

            7'b0100011: begin // Store
                Read_reg1 = Instruction[19:15];
                Read_reg2 = Instruction[24:20];
                // Write_reg is 0 (default)
                Immediate_enable = 1'b1;
                Immediate = {{20{S_type_imm[11]}}, S_type_imm};
                
                case(Funct3)
                    3'b000: Instruction_type = 5'd15; // SB
                    3'b001: Instruction_type = 5'd16; // SH
                    3'b010: Instruction_type = 5'd17; // SW
                endcase
            end

            7'b1100011: begin // Branch
                Read_reg1 = Instruction[19:15];
                Read_reg2 = Instruction[24:20];
                // Write_reg is 0
                Immediate = {{19{B_type_imm[12]}}, B_type_imm};
                
                case(Funct3)
                    3'b000: Instruction_type = 5'd18; // BEQ
                    3'b001: Instruction_type = 5'd19; // BNE
                    3'b100: Instruction_type = 5'd20; // BLT
                    3'b101: Instruction_type = 5'd21; // BGE
                    3'b110: Instruction_type = 5'd22; // BLTU
                    3'b111: Instruction_type = 5'd23; // BGEU
                endcase
            end

            7'b1101111: begin // JAL
                Write_reg = Instruction[11:7];
                Immediate_enable = 1'b1;
                Immediate = {{11{J_type_imm[20]}}, J_type_imm};
                Instruction_type = 5'd0; // ADD-like operation on PC
                Has_Rd = 1'b1;
            end

            7'b1100111: begin // JALR
                Read_reg1 = Instruction[19:15];
                Write_reg = Instruction[11:7];
                Immediate_enable = 1'b1;
                Immediate = {{20{I_type_imm[11]}}, I_type_imm};
                Instruction_type = 5'd24;
                Has_Rd = 1'b1;
            end

            7'b0110111: begin // LUI
                Write_reg = Instruction[11:7];
                Immediate_enable = 1'b1;
                Immediate = {U_type_imm, 12'b0};
                Instruction_type = 5'd25;
                Has_Rd = 1'b1;
            end

            7'b0010111: begin // AUIPC
                Write_reg = Instruction[11:7];
                Immediate_enable = 1'b1;
                Immediate = {U_type_imm, 12'b0};
                Instruction_type = 5'd26;
                Has_Rd = 1'b1;
            end
            
            // default case handled by the defaults at top
        endcase
    end
endmodule