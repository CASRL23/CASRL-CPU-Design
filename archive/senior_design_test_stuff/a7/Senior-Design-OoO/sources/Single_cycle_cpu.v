`timescale 10ns/1ps

//This module holds the single cycle cpu of the RISC-V model

module Single_cycle_cpu(
    output wire [7:0] Display_out, 
    output wire Done,
    input wire Clk, Reset    
);

//Connecting wires between Fetch unit and rest of CPU
wire [31:0] Pc, Jalr_target, Branch_target;
wire [31:0] Pc_plus4;

//Connecting wire to hold instructions read from ROM
wire [31:0] Instruction;

//create wires to connect ALU to CPU
wire [31:0] Op1, Op2, Alu_result;
wire Pc_enable, Jalr, Done_wire;

//Connecting wires from control unit to the rest of the CPU
wire [31:0] Immediate;
wire [4:0] Read_reg1, Read_reg2, Write_reg;
wire [3:0] Alu_opcode;
wire Immediate_enable, Jal, Load, Store, Auipc, Lui,
     Beq, Bne, Blt, Bge, Bltu, Bgeu, Byte, Half, Word, Unsigned;
     wire WB_en;

//Wires to connect Regi file to CPU
wire [31:0] Read_data1, Read_data2;
reg [31:0] Data_in;

//Wires for RAM output
wire [31:0] RAM_out;

reg Branch; 

//Instantiate the Fetch Unit
Fetch_unit Single_cycle_fetch(.Pc_out(Pc), .Clk(Clk), .Reset(Reset),
                               .Jalr(Jalr), .Branch_target(Branch_target), .Jalr_target(Alu_result),

                               .Pc_enable(!Done_wire), .Branch(Branch));
//Instantiate the ROM
ROM Single_cycle_ROM(.Pc(Pc), .Instruction(Instruction));

//Instantiate control unit
Control_Unit Single_cycle_control_unit (
    .Instruction(Instruction), .Immediate(Immediate), .Read_reg1(Read_reg1), .Read_reg2(Read_reg2),.Write_reg(Write_reg),
    .Alu_opcode(Alu_opcode), .Immediate_enable(Immediate_enable), .Jal(Jal), .Jalr(Jalr), .Done(Done_wire),
    .Load(Load), .Store(Store), .Auipc(Auipc), .Lui(Lui), .Beq(Beq), .Bne(Bne), .ALU_operation(ALU_operation),
    .Blt(Blt), .Bge(Bge), .Bltu(Bltu), .Bgeu(Bgeu), .Byte(Byte), .Half(Half), .Word(Word), .Unsigned(Unsigned), .Reset(Reset), .RegWrite(WB_en)
);

//Instantiate Register file
Reg_file Single_cycle_reg_file(.Clk(Clk), .Reset(Reset), .Read_data1(Read_data1), .Read_data2(Read_data2),
                                .Load(Load), .Read_reg1(Read_reg1), .Read_reg2(Read_reg2), .Write_reg(Write_reg),
                                .Data_in(Data_in), .WB_en(WB_en), .Display_out(Display_out));



assign Op1 = Read_data1;

//Input Mux for ALU inputs. ALU can take either Rs1 and Rs2 or Rs1 and Immediate Values
assign Op2 = (Immediate_enable && (Instruction[6:0] != 7'h63)) ? Immediate : Read_data2; 

//Instantiate ALU
Alu Single_cycle_alu(.Op1(Op1), .Op2(Op2), .Alu_result(Alu_result), .Alu_op(Alu_opcode));

//Instantiate RAM
RAM Single_cycle_RAM(.Clk(Clk), .Address(Alu_result), .Data_in(Read_data2), .Data_out(RAM_out), .Store(Store),
                      .Byte(Byte), .Word(Word), .Half(Half), .Unsigned(Unsigned));
                      
 //Instantiate the ROM
//ROM Single_cycle_ROM(.Pc(Pc), .Instruction(Instruction));   
                      
//This section holds the decision logic for the fetch unit
always @(Jal, Jalr, Bne, Bge, Blt, Beq, Bgeu, Bltu, Alu_result) begin
    if (Jal == 1'b1) begin
        Branch = 1'b1;
    end
    else if (Jalr == 1'b1) begin
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
    else if (Bgeu == 1'b1 && Alu_result[31] != 1'b1) begin
        Branch = 1'b1;    
    end
    else if (Bltu == 1'b1 && Alu_result[31] == 1'b1) begin
        Branch = 1'b1;    
    end
    else begin
        Branch = 1'b0;
    end
end


//This section has the adders for the Program counter, PC+4, PC+immediate
Ripple_carry_lookahead_32bit Pc_plus_4(.Op1(Pc), .Op2(32'h00000004), .C_in(1'b0), .C_out(open), .Result(Pc_plus4));
Ripple_carry_lookahead_32bit Pc_plus_immediate(.Op1(Pc), .Op2(Immediate), .C_in(1'b0), .C_out(open), .Result(Branch_target));






//This section holds the logic foar deciding whether the Data_in to the register files comes from Alu, PC, or RAM
always @(Jalr, Load, Lui, Auipc, Alu_result, RAM_out, Pc_plus4, Immediate, Branch_target, Jal)begin
    if (Load == 1'b1) begin
        Data_in = RAM_out;
    end
    else if (Jalr == 1'b1 | Jal == 1'b1) begin
        Data_in = Pc_plus4;
    end
    else if (Lui == 1'b1) begin
        Data_in = Immediate; 
    end
    else if (Auipc == 1'b1) begin
        Data_in = Branch_target;
    end
    else begin
        Data_in = Alu_result;
    end
end 

assign Done = Done_wire;

endmodule


module Single_cycle_cpu_tb;
    reg Clk;
    reg Reset;
    wire Done;

    // Instantiate your CPU
    Single_cycle_cpu dut (
        .Done(Done),
        .Clk(Clk),
        .Reset(Reset)
    );

//    initial begin
        // Init
//        Reset = 0;
//        #10;
//        Clk   = 0;
//        Reset = 1;
//        #20;
//        Reset = 0;
//     end
     
    // Clock generation (100 MHz)
    always #5 Clk = ~Clk;

    initial begin
        // Init
        Clk   = 0;
        Reset = 0;
        #10;
        Reset = 1; #10;
        #10;
        Reset = 0;
 #20; #20; #20; #2000;
        // Run until Done or max cycles
       // wait(Done);
        $display("CPU signaled Done at time %t", $time);
        $stop;
    end
endmodule