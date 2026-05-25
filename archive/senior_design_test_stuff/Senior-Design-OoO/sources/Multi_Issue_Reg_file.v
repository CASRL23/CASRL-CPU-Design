//This module holds the 4 issue register file. Takes in up to 8 read register IDS and 4 register write IDs
//Enables writing up to 4 registers at a time

module Multi_Issue_Reg_file(

                            output reg [31:0] Data_out0, Data_out1, Data_out2, Data_out3, Data_out4, Data_out5, Data_out6, Data_out7,
                            output wire [31:0] Display_out,
                            input wire Clk, Reset,
                            input wire [3:0] WB_en,
                            input wire [4:0] Rs1_0, Rs2_0, Rs1_1, Rs2_1, Rs1_2, Rs2_2, Rs1_3, Rs2_3,
                            input wire [4:0] Rd0, Rd1, Rd2, Rd3,
                            input wire [31:0] Data_in0, Data_in1, Data_in2, Data_in3                         
                            );

//2d array to set up write enables for each write enable
reg [3:0] Writeback [31:0];

integer i;


always @(WB_en,Rs1_0, Rs2_0, Rs1_1, Rs2_1, Rs1_2, Rs2_2, Rs1_3, Rs2_3,
         Rd0, Rd1, Rd2, Rd3, Data_in0, Data_in1, Data_in2, Data_in3)begin
        // Clear all enables first
        for (i = 0; i < 32; i=i+1) begin
            Writeback[i] = 4'b0000;
        end

        // Set enables based on each bit
        if (WB_en[0]) begin
            Writeback[Rd0][0] = 1'b1; 
        end
        if (WB_en[1]) begin
            Writeback[Rd1][1] = 1'b1;
        end
        if (WB_en[2]) begin
            Writeback[Rd2][2] = 1'b1;
        end
        if (WB_en[3]) begin
            Writeback[Rd3][3] = 1'b1;    
        end
end

//wires for each registers outputs
(* mark_debug = "true", keep = "true" *)
wire [31:0] x1_out, x2_out, x3_out, x4_out, x5_out, x6_out, x7_out, x8_out, x9_out, x10_out,
            x11_out, x12_out, x13_out, x14_out, x15_out, x16_out, x17_out, x18_out, x19_out, x20_out,
            x21_out, x22_out, x23_out, x24_out, x25_out, x26_out, x27_out, x28_out, x29_out, x30_out, x31_out;


//x1 is the return address register, also called ra
Multi_Issue_Reg x1(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x1_out), .Write_enable(Writeback[1]));
assign Display_out = x1_out;

//x2 is the stack pointer or sp
Multi_Issue_Reg x2(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x2_out), .Write_enable(Writeback[2]));


//x3 is the global pointer or gp
Multi_Issue_Reg x3(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x3_out), .Write_enable(Writeback[3]));


//x4 is the thread pointer or tp
Multi_Issue_Reg x4(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x4_out), .Write_enable(Writeback[4]));


//x5-x7 are temporary registers called t0-t2
Multi_Issue_Reg x5(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x5_out), .Write_enable(Writeback[5]));
Multi_Issue_Reg x6(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x6_out), .Write_enable(Writeback[6]));
Multi_Issue_Reg x7(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x7_out), .Write_enable(Writeback[7]));

//x8 is the saved/frame pointer or s0/fp
Multi_Issue_Reg x8(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x8_out), .Write_enable(Writeback[8]));


//x9 is another saved register or s1
Multi_Issue_Reg x9(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x9_out), .Write_enable(Writeback[9]));

//x10-x11 are function arguments or return values, denoted a0-a1
Multi_Issue_Reg x10(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x10_out), .Write_enable(Writeback[10]));
Multi_Issue_Reg x11(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x11_out), .Write_enable(Writeback[11]));


// x12-x17: function arguments a2-a7
Multi_Issue_Reg x12(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x12_out), .Write_enable(Writeback[12]));
Multi_Issue_Reg x13(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x13_out), .Write_enable(Writeback[13]));
Multi_Issue_Reg x14(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x14_out), .Write_enable(Writeback[14]));
Multi_Issue_Reg x15(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x15_out), .Write_enable(Writeback[15]));
Multi_Issue_Reg x16(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x16_out), .Write_enable(Writeback[16]));
Multi_Issue_Reg x17(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x17_out), .Write_enable(Writeback[17]));

// x18-x27: saved registers s2-s11
Multi_Issue_Reg x18(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x18_out), .Write_enable(Writeback[18]));
Multi_Issue_Reg x19(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x19_out), .Write_enable(Writeback[19]));
Multi_Issue_Reg x20(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x20_out), .Write_enable(Writeback[20]));
Multi_Issue_Reg x21(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x21_out), .Write_enable(Writeback[21]));
Multi_Issue_Reg x22(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x22_out), .Write_enable(Writeback[22]));
Multi_Issue_Reg x23(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x23_out), .Write_enable(Writeback[23]));
Multi_Issue_Reg x24(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x24_out), .Write_enable(Writeback[24]));
Multi_Issue_Reg x25(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x25_out), .Write_enable(Writeback[25]));
Multi_Issue_Reg x26(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x26_out), .Write_enable(Writeback[26]));
Multi_Issue_Reg x27(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x27_out), .Write_enable(Writeback[27]));

// x28-x31: temporary registers t3-t6
Multi_Issue_Reg x28(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x28_out), .Write_enable(Writeback[28]));
Multi_Issue_Reg x29(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x29_out), .Write_enable(Writeback[29]));
Multi_Issue_Reg x30(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x30_out), .Write_enable(Writeback[30]));
Multi_Issue_Reg x31(.Clk(Clk), .Reset(Reset), .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3), 
                    .Data_out(x31_out), .Write_enable(Writeback[31]));


//Mux to select which registers get their values sent out to the CPU
//Mux to select which registers get their values sent out to the CPU
always @(Rs1_0, Rs2_0, Rs1_1, Rs2_1, Rs1_2, Rs2_2, Rs1_3, Rs2_3, WB_en, 
        Rd0, Rd1, Rd2, Rd3, Data_in0, Data_in1, Data_in2, Data_in3, 
         x1_out, x2_out, x3_out, x4_out, x5_out,
         x6_out, x7_out, x8_out, x9_out, x10_out, x11_out, x12_out,
         x13_out, x14_out, x15_out, x16_out, x17_out, x18_out, x19_out,
         x20_out, x21_out, x22_out, x23_out, x24_out, x25_out, x26_out,
         x27_out, x28_out, x29_out, x30_out, x31_out) begin

//Output the register indicated by Rs1_0
    case(Rs1_0)
        5'd0: Data_out0 = 32'h00000000;
        default: begin
            // Check all write ports for bypass (priority order: 3 > 2 > 1 > 0)
            if (WB_en[3] && (Rd3 == Rs1_0))
                Data_out0 = Data_in3;
            else if (WB_en[2] && (Rd2 == Rs1_0))
                Data_out0 = Data_in2;
            else if (WB_en[1] && (Rd1 == Rs1_0))
                Data_out0 = Data_in1;
            else if (WB_en[0] && (Rd0 == Rs1_0))
                Data_out0 = Data_in0;
            else begin
                case(Rs1_0)  // <-- ADDED: need case statement here
                    5'd1:  Data_out0 = x1_out;
                    5'd2:  Data_out0 = x2_out;
                    5'd3:  Data_out0 = x3_out;
                    5'd4:  Data_out0 = x4_out;
                    5'd5:  Data_out0 = x5_out;
                    5'd6:  Data_out0 = x6_out;
                    5'd7:  Data_out0 = x7_out;
                    5'd8:  Data_out0 = x8_out;
                    5'd9:  Data_out0 = x9_out;
                    5'd10: Data_out0 = x10_out;
                    5'd11: Data_out0 = x11_out;
                    5'd12: Data_out0 = x12_out;
                    5'd13: Data_out0 = x13_out;
                    5'd14: Data_out0 = x14_out;
                    5'd15: Data_out0 = x15_out;
                    5'd16: Data_out0 = x16_out;
                    5'd17: Data_out0 = x17_out;
                    5'd18: Data_out0 = x18_out;
                    5'd19: Data_out0 = x19_out;
                    5'd20: Data_out0 = x20_out;
                    5'd21: Data_out0 = x21_out;
                    5'd22: Data_out0 = x22_out;
                    5'd23: Data_out0 = x23_out;
                    5'd24: Data_out0 = x24_out;
                    5'd25: Data_out0 = x25_out;
                    5'd26: Data_out0 = x26_out;
                    5'd27: Data_out0 = x27_out;
                    5'd28: Data_out0 = x28_out;
                    5'd29: Data_out0 = x29_out;
                    5'd30: Data_out0 = x30_out;
                    5'd31: Data_out0 = x31_out;
                    default: Data_out0 = 32'hz;    
                endcase
            end
        end   
    endcase
 
//Output the register indicated by Rs2_0
    case(Rs2_0)
        5'd0: Data_out1 = 32'h00000000;
        default: begin
            // Check all write ports for bypass (priority order: 3 > 2 > 1 > 0)
            if (WB_en[3] && (Rd3 == Rs2_0))
                Data_out1 = Data_in3;
            else if (WB_en[2] && (Rd2 == Rs2_0))
                Data_out1 = Data_in2;
            else if (WB_en[1] && (Rd1 == Rs2_0))
                Data_out1 = Data_in1;
            else if (WB_en[0] && (Rd0 == Rs2_0))
                Data_out1 = Data_in0;
            else begin
                case(Rs2_0)
                    //if accessing register 0, output only 0s
                    5'd0: Data_out1 = 32'h00000000;
                    //otherwise read out outputs from registers
                    5'd1:  Data_out1 = x1_out;
                    5'd2:  Data_out1 = x2_out;
                    5'd3:  Data_out1 = x3_out;
                    5'd4:  Data_out1 = x4_out;
                    5'd5:  Data_out1 = x5_out;
                    5'd6:  Data_out1 = x6_out;
                    5'd7:  Data_out1 = x7_out;
                    5'd8:  Data_out1 = x8_out;
                    5'd9:  Data_out1 = x9_out;
                    5'd10: Data_out1 = x10_out;
                    5'd11: Data_out1 = x11_out;
                    5'd12: Data_out1 = x12_out;
                    5'd13: Data_out1 = x13_out;
                    5'd14: Data_out1 = x14_out;
                    5'd15: Data_out1 = x15_out;
                    5'd16: Data_out1 = x16_out;
                    5'd17: Data_out1 = x17_out;
                    5'd18: Data_out1 = x18_out;
                    5'd19: Data_out1 = x19_out;
                    5'd20: Data_out1 = x20_out;
                    5'd21: Data_out1 = x21_out;
                    5'd22: Data_out1 = x22_out;
                    5'd23: Data_out1 = x23_out;
                    5'd24: Data_out1 = x24_out;
                    5'd25: Data_out1 = x25_out;
                    5'd26: Data_out1 = x26_out;
                    5'd27: Data_out1 = x27_out;
                    5'd28: Data_out1 = x28_out;
                    5'd29: Data_out1 = x29_out;
                    5'd30: Data_out1 = x30_out;
                    5'd31: Data_out1 = x31_out;
                    default: Data_out1 = 32'hz;   
                endcase
            end
        end
    endcase
    
//Output the register indicated by Rs1_1
    case(Rs1_1)
        5'd0: Data_out2 = 32'h00000000;
        default: begin
            // Check all write ports for bypass (priority order: 3 > 2 > 1 > 0)
            if (WB_en[3] && (Rd3 == Rs1_1))
                Data_out2 = Data_in3;
            else if (WB_en[2] && (Rd2 == Rs1_1))
                Data_out2 = Data_in2;
            else if (WB_en[1] && (Rd1 == Rs1_1))
                Data_out2 = Data_in1;
            else if (WB_en[0] && (Rd0 == Rs1_1))
                Data_out2 = Data_in0;
            else begin
                case(Rs1_1)  // <-- ADDED: need case statement here
                    5'd1:  Data_out2 = x1_out;
                    5'd2:  Data_out2 = x2_out;
                    5'd3:  Data_out2 = x3_out;
                    5'd4:  Data_out2 = x4_out;
                    5'd5:  Data_out2 = x5_out;
                    5'd6:  Data_out2 = x6_out;
                    5'd7:  Data_out2 = x7_out;
                    5'd8:  Data_out2 = x8_out;
                    5'd9:  Data_out2 = x9_out;
                    5'd10: Data_out2 = x10_out;
                    5'd11: Data_out2 = x11_out;
                    5'd12: Data_out2 = x12_out;
                    5'd13: Data_out2 = x13_out;
                    5'd14: Data_out2 = x14_out;
                    5'd15: Data_out2 = x15_out;
                    5'd16: Data_out2 = x16_out;
                    5'd17: Data_out2 = x17_out;
                    5'd18: Data_out2 = x18_out;
                    5'd19: Data_out2 = x19_out;
                    5'd20: Data_out2 = x20_out;
                    5'd21: Data_out2 = x21_out;
                    5'd22: Data_out2 = x22_out;
                    5'd23: Data_out2 = x23_out;
                    5'd24: Data_out2 = x24_out;
                    5'd25: Data_out2 = x25_out;
                    5'd26: Data_out2 = x26_out;
                    5'd27: Data_out2 = x27_out;
                    5'd28: Data_out2 = x28_out;
                    5'd29: Data_out2 = x29_out;
                    5'd30: Data_out2 = x30_out;
                    5'd31: Data_out2 = x31_out;
                    default: Data_out2 = 32'hz;    
                endcase
            end
        end   
    endcase
 
//Output the register indicated by Rs2_1
    case(Rs2_1)
        5'd0: Data_out3 = 32'h00000000;
        default: begin
            // Check all write ports for bypass (priority order: 3 > 2 > 1 > 0)
            if (WB_en[3] && (Rd3 == Rs2_1))
                Data_out3 = Data_in3;
            else if (WB_en[2] && (Rd2 == Rs2_1))
                Data_out3 = Data_in2;
            else if (WB_en[1] && (Rd1 == Rs2_1))
                Data_out3 = Data_in1;
            else if (WB_en[0] && (Rd0 == Rs2_1))
                Data_out3 = Data_in0;
            else begin
                case(Rs2_1)
                    //if accessing register 0, output only 0s
                    5'd0: Data_out3 = 32'h00000000;
                    //otherwise read out outputs from registers
                    5'd1:  Data_out3 = x1_out;
                    5'd2:  Data_out3 = x2_out;
                    5'd3:  Data_out3 = x3_out;
                    5'd4:  Data_out3 = x4_out;
                    5'd5:  Data_out3 = x5_out;
                    5'd6:  Data_out3 = x6_out;
                    5'd7:  Data_out3 = x7_out;
                    5'd8:  Data_out3 = x8_out;
                    5'd9:  Data_out3 = x9_out;
                    5'd10: Data_out3 = x10_out;
                    5'd11: Data_out3 = x11_out;
                    5'd12: Data_out3 = x12_out;
                    5'd13: Data_out3 = x13_out;
                    5'd14: Data_out3 = x14_out;
                    5'd15: Data_out3 = x15_out;
                    5'd16: Data_out3 = x16_out;
                    5'd17: Data_out3 = x17_out;
                    5'd18: Data_out3 = x18_out;
                    5'd19: Data_out3 = x19_out;
                    5'd20: Data_out3 = x20_out;
                    5'd21: Data_out3 = x21_out;
                    5'd22: Data_out3 = x22_out;
                    5'd23: Data_out3 = x23_out;
                    5'd24: Data_out3 = x24_out;
                    5'd25: Data_out3 = x25_out;
                    5'd26: Data_out3 = x26_out;
                    5'd27: Data_out3 = x27_out;
                    5'd28: Data_out3 = x28_out;
                    5'd29: Data_out3 = x29_out;
                    5'd30: Data_out3 = x30_out;
                    5'd31: Data_out3 = x31_out;
                    default: Data_out3 = 32'hz;   
                endcase
            end
        end
    endcase       
    
//Output the register indicated by Rs1_2
    case(Rs1_2)
        5'd0: Data_out4 = 32'h00000000;
        default: begin
            // Check all write ports for bypass (priority order: 3 > 2 > 1 > 0)
            if (WB_en[3] && (Rd3 == Rs1_2))
                Data_out4 = Data_in3;
            else if (WB_en[2] && (Rd2 == Rs1_2))
                Data_out4 = Data_in2;
            else if (WB_en[1] && (Rd1 == Rs1_2))
                Data_out4 = Data_in1;
            else if (WB_en[0] && (Rd0 == Rs1_2))
                Data_out4 = Data_in0;
            else begin
                case(Rs1_2)  // <-- ADDED: need case statement here
                    5'd1:  Data_out4 = x1_out;
                    5'd2:  Data_out4 = x2_out;
                    5'd3:  Data_out4 = x3_out;
                    5'd4:  Data_out4 = x4_out;
                    5'd5:  Data_out4 = x5_out;
                    5'd6:  Data_out4 = x6_out;
                    5'd7:  Data_out4 = x7_out;
                    5'd8:  Data_out4 = x8_out;
                    5'd9:  Data_out4 = x9_out;
                    5'd10: Data_out4 = x10_out;
                    5'd11: Data_out4 = x11_out;
                    5'd12: Data_out4 = x12_out;
                    5'd13: Data_out4 = x13_out;
                    5'd14: Data_out4 = x14_out;
                    5'd15: Data_out4 = x15_out;
                    5'd16: Data_out4 = x16_out;
                    5'd17: Data_out4 = x17_out;
                    5'd18: Data_out4 = x18_out;
                    5'd19: Data_out4 = x19_out;
                    5'd20: Data_out4 = x20_out;
                    5'd21: Data_out4 = x21_out;
                    5'd22: Data_out4 = x22_out;
                    5'd23: Data_out4 = x23_out;
                    5'd24: Data_out4 = x24_out;
                    5'd25: Data_out4 = x25_out;
                    5'd26: Data_out4 = x26_out;
                    5'd27: Data_out4 = x27_out;
                    5'd28: Data_out4 = x28_out;
                    5'd29: Data_out4 = x29_out;
                    5'd30: Data_out4 = x30_out;
                    5'd31: Data_out4 = x31_out;
                    default: Data_out4 = 32'hz;    
                endcase
            end
        end   
    endcase
 
//Output the register indicated by Rs2_2
    case(Rs2_2)
        5'd0: Data_out5 = 32'h00000000;
        default: begin
            // Check all write ports for bypass (priority order: 3 > 2 > 1 > 0)
            if (WB_en[3] && (Rd3 == Rs2_2))
                Data_out5 = Data_in3;
            else if (WB_en[2] && (Rd2 == Rs2_2))
                Data_out5 = Data_in2;
            else if (WB_en[1] && (Rd1 == Rs2_2))
                Data_out5 = Data_in1;
            else if (WB_en[0] && (Rd0 == Rs2_2))
                Data_out5 = Data_in0;
            else begin
                case(Rs2_2)
                    //if accessing register 0, output only 0s
                    5'd0: Data_out5 = 32'h00000000;
                    //otherwise read out outputs from registers
                    5'd1:  Data_out5 = x1_out;
                    5'd2:  Data_out5 = x2_out;
                    5'd3:  Data_out5 = x3_out;
                    5'd4:  Data_out5 = x4_out;
                    5'd5:  Data_out5 = x5_out;
                    5'd6:  Data_out5 = x6_out;
                    5'd7:  Data_out5 = x7_out;
                    5'd8:  Data_out5 = x8_out;
                    5'd9:  Data_out5 = x9_out;
                    5'd10: Data_out5 = x10_out;
                    5'd11: Data_out5 = x11_out;
                    5'd12: Data_out5 = x12_out;
                    5'd13: Data_out5 = x13_out;
                    5'd14: Data_out5 = x14_out;
                    5'd15: Data_out5 = x15_out;
                    5'd16: Data_out5 = x16_out;
                    5'd17: Data_out5 = x17_out;
                    5'd18: Data_out5 = x18_out;
                    5'd19: Data_out5 = x19_out;
                    5'd20: Data_out5 = x20_out;
                    5'd21: Data_out5 = x21_out;
                    5'd22: Data_out5 = x22_out;
                    5'd23: Data_out5 = x23_out;
                    5'd24: Data_out5 = x24_out;
                    5'd25: Data_out5 = x25_out;
                    5'd26: Data_out5 = x26_out;
                    5'd27: Data_out5 = x27_out;
                    5'd28: Data_out5 = x28_out;
                    5'd29: Data_out5 = x29_out;
                    5'd30: Data_out5 = x30_out;
                    5'd31: Data_out5 = x31_out;
                    default: Data_out5 = 32'hz;   
                endcase
            end
        end
    endcase

//Output the register indicated by Rs1_3
    case(Rs1_3)
        5'd0: Data_out6 = 32'h00000000;
        default: begin
            // Check all write ports for bypass (priority order: 3 > 2 > 1 > 0)
            if (WB_en[3] && (Rd3 == Rs1_3))
                Data_out6 = Data_in3;
            else if (WB_en[2] && (Rd2 == Rs1_3))
                Data_out6 = Data_in2;
            else if (WB_en[1] && (Rd1 == Rs1_3))
                Data_out6 = Data_in1;
            else if (WB_en[0] && (Rd0 == Rs1_3))
                Data_out6 = Data_in0;
            else begin
                case(Rs1_3)  // <-- ADDED: need case statement here
                    5'd1:  Data_out6 = x1_out;
                    5'd2:  Data_out6 = x2_out;
                    5'd3:  Data_out6 = x3_out;
                    5'd4:  Data_out6 = x4_out;
                    5'd5:  Data_out6 = x5_out;
                    5'd6:  Data_out6 = x6_out;
                    5'd7:  Data_out6 = x7_out;
                    5'd8:  Data_out6 = x8_out;
                    5'd9:  Data_out6 = x9_out;
                    5'd10: Data_out6 = x10_out;
                    5'd11: Data_out6 = x11_out;
                    5'd12: Data_out6 = x12_out;
                    5'd13: Data_out6 = x13_out;
                    5'd14: Data_out6 = x14_out;
                    5'd15: Data_out6 = x15_out;
                    5'd16: Data_out6 = x16_out;
                    5'd17: Data_out6 = x17_out;
                    5'd18: Data_out6 = x18_out;
                    5'd19: Data_out6 = x19_out;
                    5'd20: Data_out6 = x20_out;
                    5'd21: Data_out6 = x21_out;
                    5'd22: Data_out6 = x22_out;
                    5'd23: Data_out6 = x23_out;
                    5'd24: Data_out6 = x24_out;
                    5'd25: Data_out6 = x25_out;
                    5'd26: Data_out6 = x26_out;
                    5'd27: Data_out6 = x27_out;
                    5'd28: Data_out6 = x28_out;
                    5'd29: Data_out6 = x29_out;
                    5'd30: Data_out6 = x30_out;
                    5'd31: Data_out6 = x31_out;
                    default: Data_out6 = 32'hz;    
                endcase
            end
        end   
    endcase
 
//Output the register indicated by Rs2_3
    case(Rs2_3)
        5'd0: Data_out7 = 32'h00000000;
        default: begin
            // Check all write ports for bypass (priority order: 3 > 2 > 1 > 0)
            if (WB_en[3] && (Rd3 == Rs2_3))
                Data_out7 = Data_in3;
            else if (WB_en[2] && (Rd2 == Rs2_3))
                Data_out7 = Data_in2;
            else if (WB_en[1] && (Rd1 == Rs2_3))
                Data_out7 = Data_in1;
            else if (WB_en[0] && (Rd0 == Rs2_3))
                Data_out7 = Data_in0;
            else begin
                case(Rs2_3)
                    //if accessing register 0, output only 0s
                    5'd0: Data_out7 = 32'h00000000;
                    //otherwise read out outputs from registers
                    5'd1:  Data_out7 = x1_out;
                    5'd2:  Data_out7 = x2_out;
                    5'd3:  Data_out7 = x3_out;
                    5'd4:  Data_out7 = x4_out;
                    5'd5:  Data_out7 = x5_out;
                    5'd6:  Data_out7 = x6_out;
                    5'd7:  Data_out7 = x7_out;
                    5'd8:  Data_out7 = x8_out;
                    5'd9:  Data_out7 = x9_out;
                    5'd10: Data_out7 = x10_out;
                    5'd11: Data_out7 = x11_out;
                    5'd12: Data_out7 = x12_out;
                    5'd13: Data_out7 = x13_out;
                    5'd14: Data_out7 = x14_out;
                    5'd15: Data_out7 = x15_out;
                    5'd16: Data_out7 = x16_out;
                    5'd17: Data_out7 = x17_out;
                    5'd18: Data_out7 = x18_out;
                    5'd19: Data_out7 = x19_out;
                    5'd20: Data_out7 = x20_out;
                    5'd21: Data_out7 = x21_out;
                    5'd22: Data_out7 = x22_out;
                    5'd23: Data_out7 = x23_out;
                    5'd24: Data_out7 = x24_out;
                    5'd25: Data_out7 = x25_out;
                    5'd26: Data_out7 = x26_out;
                    5'd27: Data_out7 = x27_out;
                    5'd28: Data_out7 = x28_out;
                    5'd29: Data_out7 = x29_out;
                    5'd30: Data_out7 = x30_out;
                    5'd31: Data_out7 = x31_out;
                    default: Data_out7 = 32'hz;   
                endcase
            end
        end
    endcase     
end

endmodule