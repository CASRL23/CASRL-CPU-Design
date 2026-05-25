`timescale 1ns / 1ps

module Multi_issue_Memory (
    input  wire Clk,
    input  wire [4*180-1:0] EM_in,
    output wire [7:0] UART_tx_byte,
    output wire UART_transmit_signal,
    input wire [7:0] UART_rx_byte,
    input wire [31:0] UART_status,
    

    output wire [4*172-1:0] MW_out   // Four 172-bit outputs concatenated
);



    // split EM_in into four 180-bit lanes
    wire [179:0] EM_in_0 = EM_in[179:0];
    wire [179:0] EM_in_1 = EM_in[359:180];
    wire [179:0] EM_in_2 = EM_in[539:360];
    wire [179:0] EM_in_3 = EM_in[719:540];

    // --- unpack lane 0
    wire Done_0         = EM_in_0[177];
    wire RegWrite_0     = EM_in_0[176];
    wire [31:0] Branch_target_0 = EM_in_0[174:143];
    wire [31:0] Immediate_0     = EM_in_0[142:111];
    wire [31:0] PC_plus4_0      = EM_in_0[110:79];
    wire Unsigned_0     = EM_in_0[78];
    wire Word_0         = EM_in_0[77];
    wire Half_0         = EM_in_0[76];
    wire Byte_0         = EM_in_0[75];
    wire Store_0        = EM_in_0[74];
    wire Load_0         = EM_in_0[73];
    wire Lui_0          = EM_in_0[72];
    wire Auipc_0        = EM_in_0[71];
    wire Jalr_0         = EM_in_0[70];
    wire Jal_0          = EM_in_0[69];
    wire [4:0] Write_reg_0 = EM_in_0[68:64];
    wire [31:0] Read_data2_0 = EM_in_0[63:32];
    wire [31:0] Alu_result_0 = EM_in_0[31:0];

    // --- unpack lane 1
    wire Done_1         = EM_in_1[177];
    wire RegWrite_1     = EM_in_1[176];
    wire [31:0] Branch_target_1 = EM_in_1[174:143];
    wire [31:0] Immediate_1     = EM_in_1[142:111];
    wire [31:0] PC_plus4_1      = EM_in_1[110:79];
    wire Unsigned_1     = EM_in_1[78];
    wire Word_1         = EM_in_1[77];
    wire Half_1         = EM_in_1[76];
    wire Byte_1         = EM_in_1[75];
    wire Store_1        = EM_in_1[74];
    wire Load_1         = EM_in_1[73];
    wire Lui_1          = EM_in_1[72];
    wire Auipc_1        = EM_in_1[71];
    wire Jalr_1         = EM_in_1[70];
    wire Jal_1          = EM_in_1[69];
    wire [4:0] Write_reg_1 = EM_in_1[68:64];
    wire [31:0] Read_data2_1 = EM_in_1[63:32];
    wire [31:0] Alu_result_1 = EM_in_1[31:0];

    // --- unpack lane 2
    wire Done_2         = EM_in_2[177];
    wire RegWrite_2     = EM_in_2[176];
    wire [31:0] Branch_target_2 = EM_in_2[174:143];
    wire [31:0] Immediate_2     = EM_in_2[142:111];
    wire [31:0] PC_plus4_2      = EM_in_2[110:79];
    wire Unsigned_2     = EM_in_2[78];
    wire Word_2         = EM_in_2[77];
    wire Half_2         = EM_in_2[76];
    wire Byte_2         = EM_in_2[75];
    wire Store_2        = EM_in_2[74];
    wire Load_2         = EM_in_2[73];
    wire Lui_2          = EM_in_2[72];
    wire Auipc_2        = EM_in_2[71];
    wire Jalr_2         = EM_in_2[70];
    wire Jal_2          = EM_in_2[69];
    wire [4:0] Write_reg_2 = EM_in_2[68:64];
    wire [31:0] Read_data2_2 = EM_in_2[63:32];
    wire [31:0] Alu_result_2 = EM_in_2[31:0];

    // --- unpack lane 3
    wire Done_3         = EM_in_3[177];
    wire RegWrite_3     = EM_in_3[176];
    wire [31:0] Branch_target_3 = EM_in_3[174:143];
    wire [31:0] Immediate_3     = EM_in_3[142:111];
    wire [31:0] PC_plus4_3      = EM_in_3[110:79];
    wire Unsigned_3     = EM_in_3[78];
    wire Word_3         = EM_in_3[77];
    wire Half_3         = EM_in_3[76];
    wire Byte_3         = EM_in_3[75];
    wire Store_3        = EM_in_3[74];
    wire Load_3         = EM_in_3[73];
    wire Lui_3          = EM_in_3[72];
    wire Auipc_3        = EM_in_3[71];
    wire Jalr_3         = EM_in_3[70];
    wire Jal_3          = EM_in_3[69];
    wire [4:0] Write_reg_3 = EM_in_3[68:64];
    wire [31:0] Read_data2_3 = EM_in_3[63:32];
    wire [31:0] Alu_result_3 = EM_in_3[31:0];

    // Instantiate single multi-port RAM
    wire [31:0] RAM_out_0;
    wire [31:0] RAM_out_1;
    wire [31:0] RAM_out_2;
    wire [31:0] RAM_out_3;

    Multi_Issue_RAM multi_ram (
        .Data_out0(RAM_out_0),
        .Data_out1(RAM_out_1),
        .Data_out2(RAM_out_2),
        .Data_out3(RAM_out_3),
        .Data_in0(Read_data2_0),
        .Data_in1(Read_data2_1),
        .Data_in2(Read_data2_2),
        .Data_in3(Read_data2_3),
        .Address0(Alu_result_0),
        .Address1(Alu_result_1),
        .Address2(Alu_result_2),
        .Address3(Alu_result_3),
        .Store0(Store_0),
        .Store1(Store_1),
        .Store2(Store_2),
        .Store3(Store_3),
        .Load0(Load_0),
        .Load1(Load_1),
        .Load2(Load_2),
        .Load3(Load_3),
        .Clk(Clk),
        .Byte0(Byte_0),
        .Byte1(Byte_1),
        .Byte2(Byte_2),
        .Byte3(Byte_3),
        .Half0(Half_0),
        .Half1(Half_1),
        .Half2(Half_2),
        .Half3(Half_3),
        .Word0(Word_0),
        .Word1(Word_1),
        .Word2(Word_2),
        .Word3(Word_3),
        .Unsigned0(Unsigned_0),
        .Unsigned1(Unsigned_1),
        .Unsigned2(Unsigned_2),
        .Unsigned3(Unsigned_3),
        
        .UART_TX_Byte(UART_tx_byte),
        .UART_transmit_signal(UART_transmit_signal),
        .UART_RX_Byte(UART_rx_byte),
        .UART_status(UART_status)
    );

    // Pack MW_out lanes: 172 bits each
    wire [171:0] MW_out_0 = {
        Done_0,
        RegWrite_0,
        Jal_0,
        Jalr_0,
        Load_0,
        Lui_0,
        Auipc_0,
        Write_reg_0,
        Branch_target_0,
        Immediate_0,
        PC_plus4_0,
        Alu_result_0,
        RAM_out_0
    };

    wire [171:0] MW_out_1 = {
        Done_1,
        RegWrite_1,
        Jal_1,
        Jalr_1,
        Load_1,
        Lui_1,
        Auipc_1,
        Write_reg_1,
        Branch_target_1,
        Immediate_1,
        PC_plus4_1,
        Alu_result_1,
        RAM_out_1
    };

    wire [171:0] MW_out_2 = {
        Done_2,
        RegWrite_2,
        Jal_2,
        Jalr_2,
        Load_2,
        Lui_2,
        Auipc_2,
        Write_reg_2,
        Branch_target_2,
        Immediate_2,
        PC_plus4_2,
        Alu_result_2,
        RAM_out_2
    };

    wire [171:0] MW_out_3 = {
        Done_3,
        RegWrite_3,
        Jal_3,
        Jalr_3,
        Load_3,
        Lui_3,
        Auipc_3,
        Write_reg_3,
        Branch_target_3,
        Immediate_3,
        PC_plus4_3,
        Alu_result_3,
        RAM_out_3
    };

    assign MW_out = {MW_out_3, MW_out_2, MW_out_1, MW_out_0};

endmodule