//This module is the register file. Holds all RISC-V 32 bit standard registers

//writes to up to 1 registers, reads from up to 2 registers. 
//There are special instructions such as jal and jalreg that write to the PC as well as Rd but the PC is separate
module Reg_file(
    output reg [31:0] Read_data1, Read_data2, 
    output wire [31:0] Display_out,
    input wire Clk, Reset, Load, WB_en,
    input wire [4:0] Read_reg1, Read_reg2, Write_reg, 
    input wire [31:0] Data_in
);
//wire for the register write enable
wire [31:0] Write_enable;

//Decoder that enables enables the intended register write_enable for writes
assign Write_enable = WB_en ?((32'b1 << Write_reg)&32'hFFFFFFFE) : 32'b0;

//wires for each registers outputs
wire [31:0] x1_out, x2_out, x3_out, x4_out, x5_out, x6_out, x7_out, x8_out, x9_out, x10_out,
            x11_out, x12_out, x13_out, x14_out, x15_out, x16_out, x17_out, x18_out, x19_out, x20_out,
            x21_out, x22_out, x23_out, x24_out, x25_out, x26_out, x27_out, x28_out, x29_out, x30_out, x31_out;
            

//x1 is the return address register, also called ra
Register_32_bit x1(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x1_out), .Write_enable(Write_enable[1]));
assign Display_out = x1_out;

//x2 is the stack pointer or sp
Register_32_bit x2(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x2_out), .Write_enable(Write_enable[2]));


//x3 is the global pointer or gp
Register_32_bit x3(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x3_out), .Write_enable(Write_enable[3]));


//x4 is the thread pointer or tp
Register_32_bit x4(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x4_out), .Write_enable(Write_enable[4]));


//x5-x7 are temporary registers called t0-t2
Register_32_bit x5(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x5_out), .Write_enable(Write_enable[5]));
Register_32_bit x6(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x6_out), .Write_enable(Write_enable[6]));
Register_32_bit x7(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x7_out), .Write_enable(Write_enable[7]));


//x8 is the saved/frame pointer or s0/fp
Register_32_bit x8(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x8_out), .Write_enable(Write_enable[8]));


//x9 is another saved register or s1
Register_32_bit x9(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x9_out), .Write_enable(Write_enable[9]));


//x10-x11 are function arguments or return values, denoted a0-a1
Register_32_bit x10(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x10_out), .Write_enable(Write_enable[10]));
Register_32_bit x11(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x11_out), .Write_enable(Write_enable[11]));


//x12-x17 are more function arguments a2-7
Register_32_bit x12(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x12_out), .Write_enable(Write_enable[12]));
Register_32_bit x13(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x13_out), .Write_enable(Write_enable[13]));
Register_32_bit x14(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x14_out), .Write_enable(Write_enable[14]));
Register_32_bit x15(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x15_out), .Write_enable(Write_enable[15]));
Register_32_bit x16(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x16_out), .Write_enable(Write_enable[16]));
Register_32_bit x17(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x17_out), .Write_enable(Write_enable[17]));


//x18-x27 are more saved registers s2-s11
Register_32_bit x18(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x18_out), .Write_enable(Write_enable[18]));
Register_32_bit x19(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x19_out), .Write_enable(Write_enable[19]));
Register_32_bit x20(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x20_out), .Write_enable(Write_enable[20]));
Register_32_bit x21(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x21_out), .Write_enable(Write_enable[21]));
Register_32_bit x22(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x22_out), .Write_enable(Write_enable[22]));
Register_32_bit x23(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x23_out), .Write_enable(Write_enable[23]));
Register_32_bit x24(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x24_out), .Write_enable(Write_enable[24]));
Register_32_bit x25(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x25_out), .Write_enable(Write_enable[25]));
Register_32_bit x26(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x26_out), .Write_enable(Write_enable[26]));
Register_32_bit x27(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x27_out), .Write_enable(Write_enable[27]));


//x28-x31 are more temporary registers t3-t6
Register_32_bit x28(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x28_out), .Write_enable(Write_enable[28]));
Register_32_bit x29(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x29_out), .Write_enable(Write_enable[29]));
Register_32_bit x30(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x30_out), .Write_enable(Write_enable[30]));
Register_32_bit x31(.Clk(Clk), .Reset(Reset), .Data_in(Data_in), .Data_out(x31_out), .Write_enable(Write_enable[31]));



//Mux to select which registers get their values sent out to the CPU
always @(Read_reg1, Read_reg2, WB_en, Write_reg, Data_in, x1_out, x2_out, x3_out, x4_out, x5_out,
         x6_out, x7_out, x8_out, x9_out, x10_out, x11_out, x12_out,
         x13_out, x14_out, x15_out, x16_out, x17_out, x18_out, x19_out,
         x20_out, x21_out, x22_out, x23_out, x24_out, x25_out, x26_out,
         x27_out, x28_out, x29_out, x30_out, x31_out) begin
    
    //Output the register indicated by Read_reg1
    case(Read_reg1)
        //if accessing register 0, output only 0s
        5'd0: Read_data1 = 32'h00000000;
        default: begin
            if (WB_en && (Write_reg == Read_reg1))
                Read_data1 = Data_in;   // bypass newly written value
            else begin
                case(Read_reg1)
                    //otherwise read out outputs from registers
                    5'd1:  Read_data1 = x1_out;
                    5'd2:  Read_data1 = x2_out;
                    5'd3:  Read_data1 = x3_out;
                    5'd4:  Read_data1 = x4_out;
                    5'd5:  Read_data1 = x5_out;
                    5'd6:  Read_data1 = x6_out;
                    5'd7:  Read_data1 = x7_out;
                    5'd8:  Read_data1 = x8_out;
                    5'd9:  Read_data1 = x9_out;
                    5'd10: Read_data1 = x10_out;
                    5'd11: Read_data1 = x11_out;
                    5'd12: Read_data1 = x12_out;
                    5'd13: Read_data1 = x13_out;
                    5'd14: Read_data1 = x14_out;
                    5'd15: Read_data1 = x15_out;
                    5'd16: Read_data1 = x16_out;
                    5'd17: Read_data1 = x17_out;
                    5'd18: Read_data1 = x18_out;
                    5'd19: Read_data1 = x19_out;
                    5'd20: Read_data1 = x20_out;
                    5'd21: Read_data1 = x21_out;
                    5'd22: Read_data1 = x22_out;
                    5'd23: Read_data1 = x23_out;
                    5'd24: Read_data1 = x24_out;
                    5'd25: Read_data1 = x25_out;
                    5'd26: Read_data1 = x26_out;
                    5'd27: Read_data1 = x27_out;
                    5'd28: Read_data1 = x28_out;
                    5'd29: Read_data1 = x29_out;
                    5'd30: Read_data1 = x30_out;
                    5'd31: Read_data1 = x31_out;
                    default: Read_data1 = 32'hz;
                endcase
            end
        end     
    endcase
    
    
    //Output the register indicated by Read_reg2
    case(Read_reg2)
        //if accessing register 0, output only 0s
        5'd0: Read_data2 = 32'h00000000;
        default: begin
            if (WB_en && (Write_reg == Read_reg2))
                Read_data2 = Data_in;   // bypass newly written value
            else begin
                case(Read_reg2)
                    //otherwise read out outputs from registers
                    5'd1:  Read_data2 = x1_out;
                    5'd2:  Read_data2 = x2_out;
                    5'd3:  Read_data2 = x3_out;
                    5'd4:  Read_data2 = x4_out;
                    5'd5:  Read_data2 = x5_out;
                    5'd6:  Read_data2 = x6_out;
                    5'd7:  Read_data2 = x7_out;
                    5'd8:  Read_data2 = x8_out;
                    5'd9:  Read_data2 = x9_out;
                    5'd10: Read_data2 = x10_out;
                    5'd11: Read_data2 = x11_out;
                    5'd12: Read_data2 = x12_out;
                    5'd13: Read_data2 = x13_out;
                    5'd14: Read_data2 = x14_out;
                    5'd15: Read_data2 = x15_out;
                    5'd16: Read_data2 = x16_out;
                    5'd17: Read_data2 = x17_out;
                    5'd18: Read_data2 = x18_out;
                    5'd19: Read_data2 = x19_out;
                    5'd20: Read_data2 = x20_out;
                    5'd21: Read_data2 = x21_out;
                    5'd22: Read_data2 = x22_out;
                    5'd23: Read_data2 = x23_out;
                    5'd24: Read_data2 = x24_out;
                    5'd25: Read_data2 = x25_out;
                    5'd26: Read_data2 = x26_out;
                    5'd27: Read_data2 = x27_out;
                    5'd28: Read_data2 = x28_out;
                    5'd29: Read_data2 = x29_out;
                    5'd30: Read_data2 = x30_out;
                    5'd31: Read_data2 = x31_out;
                    default: Read_data2 = 32'hz;
                    endcase
                end
            end
    endcase    
end
endmodule