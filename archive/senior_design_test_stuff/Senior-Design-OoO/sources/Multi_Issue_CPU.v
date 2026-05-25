`timescale 10ns/1ps

module Multi_Issue_CPU(
    output wire Done,
//    output wire [31:0] Display_out,
    input wire Clk,
    input wire Reset,
    
    output wire [7:0] UART_tx_byte,
    output wire UART_transmit_signal,
    input wire [7:0] UART_rx_byte,
    input wire [31:0] UART_status
    );

// Pipeline Register Wires
wire [4*65-1:0]  FD_out;        // FETCH -> DECODE
wire [4*167-1:0] DE_out;        // DECODE -> EXECUTE
wire [4*180-1:0] EM_out;        // EXECUTE -> MEMORY
wire [4*172-1:0] MW_out;        // MEMORY -> WRITEBACK 

wire [64:0] FD_out0, FD_out1, FD_out2, FD_out3; 
wire [166:0] DE_out0, DE_out1, DE_out2, DE_out3; 
wire [179:0] EM_out0, EM_out1, EM_out2, EM_out3; 
wire [171:0] MW_out0, MW_out1, MW_out2, MW_out3; 

// EM_out bits that are used for Fetch (Execute-Memory feedback)
wire [31:0] branch_pc0 = EM_out0[110:79] - 32'd4;
wire [31:0] branch_pc1 = EM_out1[110:79] - 32'd4;
wire [31:0] branch_pc2 = EM_out2[110:79] - 32'd4;
wire [31:0] branch_pc3 = EM_out3[110:79] - 32'd4;
wire jalr0 = EM_out0[70];
wire jalr1 = EM_out1[70];
wire jalr2 = EM_out2[70];
wire jalr3 = EM_out3[70];

//          {EX_Prediction:Update_en}{Update_taken}{Branch_target}{PC of Branch Instr. EX}{Jalr} 
wire [67:0] EM_fb0 = {EM_out0[179:178], EM_out0[175], EM_out0[174:143], branch_pc0, jalr0 };
wire [67:0] EM_fb1 = {EM_out1[179:178], EM_out1[175], EM_out1[174:143], branch_pc1, jalr1 };
wire [67:0] EM_fb2 = {EM_out2[179:178], EM_out2[175], EM_out2[174:143], branch_pc2, jalr2 };
wire [67:0] EM_fb3 = {EM_out3[179:178], EM_out3[175], EM_out3[174:143], branch_pc3, jalr3 };

// Combined into one bus
wire [4*68-1:0] EM_feedback = {EM_fb3, EM_fb2, EM_fb1, EM_fb0};

// ------------------- Writeback outputs-------------------
wire WB_en0, WB_en1, WB_en2, WB_en3;
wire [4:0] WB_addr0, WB_addr1, WB_addr2, WB_addr3;
wire [31:0] WB_data0, WB_data1, WB_data2, WB_data3;

wire [2:0] Num_issued;
reg [2:0] Num_issued_reg;

always @(negedge Clk) begin
    if (Reset)
        Num_issued_reg <= 3'd4;  // Default: all 4 can issue
    else
        Num_issued_reg <= Num_issued;
end

wire [3:0] PC_en;
wire Flush, FD_write;
assign FD_write = 1'b1;

// ------------------- FETCH -------------------
Multi_Issue_Fetch Fetch_Stage (
    .Clk(Clk),
    .Reset(Reset),
    .PC_enable(PC_en),
    .Fetch_done(Done),
    .EM_feedback(EM_feedback),  
    .FD_out(FD_out),
    .Num_issued(Num_issued_reg)
);
// ---------------------------------------------

// Fetch-Decode Pipeline Regs
FD_pipeline FD_reg0 (.Clk(Clk), .Reset(Reset || Flush), .en(FD_write), .din(FD_out[64:0]), .dout(FD_out0));
FD_pipeline FD_reg1 (.Clk(Clk), .Reset(Reset || Flush), .en(FD_write), .din(FD_out[129:65]), .dout(FD_out1));
FD_pipeline FD_reg2 (.Clk(Clk), .Reset(Reset || Flush), .en(FD_write), .din(FD_out[194:130]), .dout(FD_out2));
FD_pipeline FD_reg3 (.Clk(Clk), .Reset(Reset || Flush), .en(FD_write), .din(FD_out[259:195]), .dout(FD_out3));

// ------------------- DECODE -------------------
Multi_Issue_Decode Decode_Stage (
    .Clk(Clk),
    .Reset(Reset),
    .display_out(Display_out),
     
    // 4-way packed fetch/decode inputs
    .FD_in({FD_out3, FD_out2, FD_out1, FD_out0}),

    // Hazard detection / forwarding inputs (from DE_pipeline outputs)
    .DE_MemRead({DE_out3[126], DE_out2[126], DE_out1[126], DE_out0[126]}),
    .E_branch({EM_out3[175], EM_out2[175], EM_out1[175], EM_out0[175]}),
    .E_pred_taken({EM_out3[179], EM_out2[179], EM_out1[179], EM_out0[179]}),
    .E_valid_branch({EM_out3[178], EM_out2[178], EM_out1[178], EM_out0[178]}),
    .DE_Rd({DE_out3[110:106], DE_out2[110:106], DE_out1[110:106], DE_out0[110:106]}),
    
    // Register file writeback feedback
    .WB_en({WB_en3, WB_en2, WB_en1, WB_en0}),
    .WB_addr({WB_addr3, WB_addr2, WB_addr1, WB_addr0}),
    .WB_data({WB_data3, WB_data2, WB_data1, WB_data0}),

    .DE_out(DE_out),
    .Num_issued(Num_issued),     // Num of Instr issued
    .PC_en(PC_en),
    .Flush(Flush)
);
// ----------------------------------------------

// Decode-Execute Pipeline Regs
DE_pipeline DE_reg0 (.Clk(Clk), .Reset(Reset || Flush), .en(1'b1), .din(DE_out[166:0]), .dout(DE_out0));
DE_pipeline DE_reg1 (.Clk(Clk), .Reset(Reset || Flush), .en(1'b1), .din(DE_out[333:167]), .dout(DE_out1));
DE_pipeline DE_reg2 (.Clk(Clk), .Reset(Reset || Flush), .en(1'b1), .din(DE_out[500:334]), .dout(DE_out2));
DE_pipeline DE_reg3 (.Clk(Clk), .Reset(Reset || Flush), .en(1'b1), .din(DE_out[667:501]), .dout(DE_out3));

// ------------------- EXECUTE -------------------
Multi_Issue_Execute Execute_Stage (
    .DE_in({DE_out3, DE_out2, DE_out1, DE_out0}),   
    .EM_outin({EM_out3, EM_out2, EM_out1, EM_out0}),
    .MW_in({MW_out3, MW_out2, MW_out1, MW_out0}),
    .EM_out(EM_out)
    );  
// ----------------------------------------------
   
// Execute Memory Pipeline Regs
EM_pipeline EM_reg0 (.Clk(Clk), .Reset(Reset), .en(1'b1), .din(EM_out[179:0]),  .dout(EM_out0));
EM_pipeline EM_reg1 (.Clk(Clk), .Reset(Reset), .en(1'b1), .din(EM_out[359:180]), .dout(EM_out1));
EM_pipeline EM_reg2 (.Clk(Clk), .Reset(Reset), .en(1'b1), .din(EM_out[539:360]), .dout(EM_out2));          
EM_pipeline EM_reg3 (.Clk(Clk), .Reset(Reset), .en(1'b1), .din(EM_out[719:540]), .dout(EM_out3));    
        
// ------------------- MEMORY -------------------
Multi_issue_Memory Memory_Stage (
    .Clk(Clk),
    .EM_in({EM_out3, EM_out2, EM_out1, EM_out0}),
    .MW_out(MW_out),
    .UART_rx_byte(UART_rx_byte),
    .UART_tx_byte(UART_tx_byte),
    .UART_transmit_signal(UART_transmit_signal),
    .UART_status(UART_status)
);
// ----------------------------------------------

// Memory Writeback Pipeline Regs
MW_pipeline MW_reg0 (.Clk(Clk), .Reset(Reset), .en(1'b1), .din(MW_out[171:0]), .dout(MW_out0));
MW_pipeline MW_reg1 (.Clk(Clk), .Reset(Reset), .en(1'b1), .din(MW_out[343:172]), .dout(MW_out1));
MW_pipeline MW_reg2 (.Clk(Clk), .Reset(Reset), .en(1'b1), .din(MW_out[515:344]), .dout(MW_out2));          
MW_pipeline MW_reg3 (.Clk(Clk), .Reset(Reset), .en(1'b1), .din(MW_out[687:516]), .dout(MW_out3));    

// ------------------- WRITEBACK -------------------
Multi_Issue_Writeback Writeback_Stage (
    .Clk(Clk),
    .Reset(Reset),
    .MW_in({MW_out3, MW_out2, MW_out1, MW_out0}), 
    .WB_en0(WB_en0),
    .WB_addr0(WB_addr0),
    .WB_data0(WB_data0),
    .WB_en1(WB_en1),
    .WB_addr1(WB_addr1),
    .WB_data1(WB_data1),
    .WB_en2(WB_en2),
    .WB_addr2(WB_addr2),
    .WB_data2(WB_data2),
    .WB_en3(WB_en3),
    .WB_addr3(WB_addr3),
    .WB_data3(WB_data3),
    .Done(Done)
);
// -----------------------------------------------
endmodule
