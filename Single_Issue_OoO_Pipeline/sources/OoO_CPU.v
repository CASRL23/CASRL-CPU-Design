// top module for tomasulos single issue CPU
module Tomasulos_Single_Issue(
    input wire Clk, Reset, 
    output wire [31:0] Display_out,
    output wire Done
);

// ----------------------------------------------------------------------
// PARAMETERS
// ----------------------------------------------------------------------
parameter RS_ENTRIES = 16;
parameter DATA_SIZE = 32;
parameter TAG_SIZE = 7;

// ----------------------------------------------------------------------
// INTERNAL WIRES
// ----------------------------------------------------------------------

// -- Hazard / Stall --
wire Flush;             
wire Stall_from_Decode; 
wire Fetch_stall;       
wire ROM_IQ_stall;      

// -- Queue Status --
wire ROM_IQ_full, ROM_IQ_empty;
wire IQ_full, IQ_empty;
wire RS_full; 

// -- Fetch / Decode Wires --
wire [31:0] Instruction_F;
wire Pred_taken_F, Fetch_valid; 
wire [31:0] Instruction_D;
wire Pred_taken_D;

// -- Decode Output / IQ Input --
wire Branch_DI, Done_DI, Rs1_valid_DI, Rs2_valid_DI; 
wire [31:0] Vj_DI, Vk_DI, Mem_offset_DI;
wire [6:0] Rs1_tag_DI, Rs2_tag_DI;
wire [4:0] Instruction_type_DI, Rd_DI;

// -- IQ Output / Issue Input --
wire Valid_Issue_I; 
wire Rs1_valid_I, Rs2_valid_I; // From IQ: 1 = Pending (Tag), 0 = Ready (Value)
wire Pred_taken_I, Done_I;
wire [31:0] Vj_I, Vk_I, Mem_offset_I;
wire [6:0] Rs1_tag_I, Rs2_tag_I;
wire [4:0] Instruction_type_I, Rd_I;

// -- Issue <-> Dispatch Wires --
wire [RS_ENTRIES-1:0] Ready_bits_RS, Busy_bits_RS;
wire [TAG_SIZE-1:0] Read_idx_disp;
wire Read_enable_disp;
wire [DATA_SIZE-1:0] Vj_disp_read, Vk_disp_read, Mem_offset_disp_read;
wire [4:0] Instr_type_disp_read, Rd_disp_read;

// -- Issue -> Decode (RAT Update Feedback) --
wire [TAG_SIZE:0] Dest_tag_rf_wire; // {Valid, Tag}

// -- Dispatch -> Execute Wires --
wire Valid_Dispatch_E;
wire [DATA_SIZE-1:0] Vj_E, Vk_E, Mem_offset_E;
wire [TAG_SIZE-1:0] Dest_tag_E;
wire [4:0] Instr_type_E, Rd_E;

// -- Execute -> EM Reg / CDB Wires --
wire [DATA_SIZE-1:0] Mem_addr_EX, ALU_result_EX;
wire Branch_result_EX, Valid_branch_EX, Branch_mispredict_EX;
wire [TAG_SIZE-1:0] Dest_tag_WB_EX, Dest_tag_Mem_EX;
wire [3:0] Mem_type_EX;

// -- EM Reg -> Memory Wires --
wire [31:0] Vj_M, Addr_M;
wire [TAG_SIZE-1:0] Dest_tag_M;
wire [3:0] Mem_type_M;

// -- Memory -> Arbiter Wires --
wire [31:0] Data_Memory_Out;
wire Mem_busy_out;
wire [TAG_SIZE-1:0] Mem_tag_out; // Tag returning from Memory
wire Mem_valid_out;              // Indicates Mem has valid data for CDB

// -- Arbiter -> CDB Wires --
wire [DATA_SIZE-1:0] Arb_result;
wire [TAG_SIZE-1:0] Arb_tag;
wire Arb_valid;
wire Arb_reg_write;
wire Stall_ALU_from_Arb;
wire Stall_MEM_from_Arb;

// -- CDB Wires (Feedback to Issue/Decode) --
wire cdb_en_internal;
wire cdb_reg_write_internal;
wire [6:0] cdb_tag_internal;
wire [31:0] cdb_data_internal;

// ----------------------------------------------------------------------
// STALL & CONTROL LOGIC
// ----------------------------------------------------------------------
assign Fetch_stall = ROM_IQ_full || Stall_from_Decode;
assign Fetch_valid = !Fetch_stall;

assign ROM_IQ_stall = IQ_full || RS_full || Stall_from_Decode;

// IQ Valid Issue: If IQ not empty and RS not full, we have a valid issue
assign Valid_Issue_I = !IQ_empty && !RS_full;

// ----------------------------------------------------------------------
// MODULE INSTANTIATIONS
// ----------------------------------------------------------------------

// 1. Fetch Stage
OoO_Fetch OOOF(
    .Clk(Clk), 
    .Reset(Reset), 
    .Pc_enable((!Fetch_stall)), 
    .Jalr(1'b0),                          // Hardcoded 0 (JALR support optional)
    .Fetch_done(1'b0),                    // Hardcoded 0 (Run continuously)
    .Misprediction(Branch_mispredict_EX), // From Execute
    .Branch_target(ALU_result_EX),        // From Execute
    .PC_correction(32'd0),                // Simplified
    .Instruction(Instruction_F),    
    .Pred_taken_FD(Pred_taken_F)    
);

// 2. ROM Instruction Queue
//OoO_ROM_IQ #(.DATA_SIZE(32)) ROM_Queue (
//    .Clk(Clk), 
//    .Reset(Reset), 
//    .Stall(ROM_IQ_stall),           
//    .Flush(Flush),                 
//    .Fetch_valid(Fetch_valid),      
//    .Instr_in(Instruction_F),
//    .Instr_out(Instruction_D),
//    .Pred_taken_in(Pred_taken_F),
//    .Pred_taken_out(Pred_taken_D),
//    .full(ROM_IQ_full),
//    .empty(ROM_IQ_empty)
//);

// 3. Decode Stage
OoO_Decode OOOD(
    .Clk(Clk), 
    .Reset(Reset), 
    .Instruction(Instruction_D),     
    .Pred_taken_in(Pred_taken_D),    
    .Branch(Branch_DI),              
    .Branch_resolved(Valid_branch_EX), // From Execute: Indicates a branch finished
    
    // Renaming / RAT Updates (Feedback from Issue Stage)
    .issue_en(Dest_tag_rf_wire[7]),    // Valid Bit from Issue Allocation
    .issue_tag_in(Dest_tag_rf_wire[6:0]), // Tag from Issue Allocation
    .issue_rd_addr(Rd_I),              // Rd addr currently issuing from IQ
    
    // CDB Listening (Update Rename Table values)
    .wb_en(cdb_en_internal),    
    .wb_tag_in(cdb_tag_internal),
    .wb_data_in(cdb_data_internal),
    
    // Hazard Control
    .Decode_stall(Stall_from_Decode),      
    .Fetch_stall(), // Driven externally
    .Flush(Flush),                  
    
    // Outputs to IQ
    .Rs1_valid(Rs1_valid_DI), 
    .Rs2_valid(Rs2_valid_DI), 
    .Done(Done_DI), 
    .Display_out(Display_out),      
    .Vj_DI(Vj_DI),                  
    .Vk_DI(Vk_DI),                  
    .Mem_offset_DI(Mem_offset_DI),  
    .Rs1_tag_DI(Rs1_tag_DI), 
    .Rs2_tag_DI(Rs2_tag_DI),
    .Instruction_type_DI(Instruction_type_DI),
    .Rd_DI(Rd_DI)
);      

// 4. Instruction Queue (Decode -> Issue Buffer)
IQ Instruction_Queue (
    .Clk(Clk), 
    .Reset(Reset), 
    .Stall(ROM_IQ_stall),           
    .RS_full(RS_full),              
    .Done_in(Done_DI),
    .Pred_taken_in(Pred_taken_D),   
    .Vk_in(Vk_DI), 
    .Vj_in(Vj_DI), 
    .Mem_offset_in(Mem_offset_DI), 
    .Rs1_tag_in(Rs1_tag_DI), 
    .Rs2_tag_in(Rs2_tag_DI),
    .Instruction_type_in(Instruction_type_DI), 
    .Rd_in(Rd_DI),
    .Rs1_valid_in(Rs1_valid_DI),
    .Rs2_valid_in(Rs2_valid_DI),
    
    .full(IQ_full),
    .empty(IQ_empty),
    
    .Done_out(Done_I),                 
    .Pred_taken_out(Pred_taken_I),     
    .Vk_out(Vk_I),                     
    .Vj_out(Vj_I),                     
    .Mem_offset_out(Mem_offset_I),     
    .Rs1_tag_out(Rs1_tag_I),           
    .Rs2_tag_out(Rs2_tag_I),           
    .Instruction_type_out(Instruction_type_I), 
    .Rd_out(Rd_I),
    .Rs1_valid_out(Rs1_valid_I),
    .Rs2_valid_out(Rs2_valid_I)
);

// 5. RS Issue Stage (Allocation)
RS_Issue_Stage #(
    .RS_ENTRIES(RS_ENTRIES),
    .DATA_SIZE(DATA_SIZE),
    .TAG_SIZE(TAG_SIZE)
) RS_Issue (
    .Clk(Clk),
    .Reset(Reset),
    
    // Inputs from IQ
    .Vj_in(Vj_I),
    .Vk_in(Vk_I),
    .Mem_offset_in(Mem_offset_I),
    
    // GLUE LOGIC: Source = {Ready_Bit, Tag}
    // ~Rs_valid means "Ready/Value Valid". Rs_valid means "Pending/Tag Valid"
    .Rs1_source({ ~Rs1_valid_I, Rs1_tag_I }), 
    .Rs2_source({ ~Rs2_valid_I, Rs2_tag_I }), 
    
    .Instruction_type_in(Instruction_type_I),
    .Rd_in(Rd_I),
    .Valid_Issue(Valid_Issue_I),
    
    // CDB Inputs (Update Dependencies)
    .CDB_result(cdb_data_internal),
    .CDB_tag(cdb_tag_internal),
    .Valid_CDB(cdb_en_internal),
    
    // Outputs
    .Ready_bits(Ready_bits_RS),
    .Busy_bits(Busy_bits_RS),
    .RS_Full(RS_full),
    .Dest_tag_to_RF(Dest_tag_rf_wire), // {Valid, Tag} -> Goes to Decode RAT
    
    // Read Interface (Feedback from Dispatch)
    .Read_idx(Read_idx_disp),
    .Read_enable(Read_enable_disp),
    .Vj_read(Vj_disp_read),
    .Vk_read(Vk_disp_read),
    .Instruction_type_read(Instr_type_disp_read),
    .Dest_reg_read(Rd_disp_read),
    .Mem_offset_read(Mem_offset_disp_read)
);

// 6. RS Dispatch Stage (Select & Forward)
RS_Dispatch #(
    .RS_ENTRIES(RS_ENTRIES),
    .DATA_SIZE(DATA_SIZE),
    .TAG_SIZE(TAG_SIZE)
) RS_Dispatch (
    .Clk(Clk),
    .Reset(Reset),
    
    // Inputs from Issue
    .Ready_bits(Ready_bits_RS),
    .Vj_read(Vj_disp_read),
    .Vk_read(Vk_disp_read),
    .Instruction_type_read(Instr_type_disp_read),
    .Dest_reg_read(Rd_disp_read),
    .Mem_offset_read(Mem_offset_disp_read),
    
    // Feedback to Issue (To clear Busy bit)
    .Read_idx(Read_idx_disp),
    .Read_enable(Read_enable_disp),
    
    // Outputs to Execute (Registered inside Dispatch)
    .Valid_out(Valid_Dispatch_E),
    .Vj_out(Vj_E),
    .Vk_out(Vk_E),
    .Dest_tag_out(Dest_tag_E),
    .Instruction_type_out(Instr_type_E),
    .Rd_out(Rd_E),
    .Mem_offset_out(Mem_offset_E)
);

// 7. Execute Stage (ALU)
OoO_Execute #(
    .DATA_WIDTH(DATA_SIZE),
    .RS_TAG(TAG_SIZE)
) OOOE (
    .Vj(Vj_E),
    .Vk(Vk_E),
    .Mem_offset(Mem_offset_E),
    .Dest_tag_in(Dest_tag_E),
    .Instruction_type(Instr_type_E),
    .Pred_taken_in(1'b0), // Prediction usually flows through RS, default 0
    
    .Mem_addr(Mem_addr_EX),
    .ALU_result(ALU_result_EX),
    .Branch_result(Branch_result_EX),
    .Valid_branch(Valid_branch_EX),
    .Branch_mispredict(Branch_mispredict_EX),
    .Dest_tag_out_WB(Dest_tag_WB_EX),
    .Dest_tag_out_Mem(Dest_tag_Mem_EX),
    .Mem_type(Mem_type_EX)
);

// 8. Execute-Memory Pipeline Register
OoO_EM_reg OOOEM (
    .Clk(Clk), 
    .Reset(Reset), 
    .Flush(Flush),
    .Vj_in(Vj_E),          // Store Data passes through
    .Addr_in(Mem_addr_EX), 
    .Dest_tag_in(Dest_tag_Mem_EX),
    .Instr_type_in({1'b0, Mem_type_EX}), 
    
    .Vj_out(Vj_M),
    .Addr_out(Addr_M),
    .Dest_tag_out(Dest_tag_M),
    .Mem_type(Mem_type_M)
);

// 9. Memory Stage
OoO_Mem OOOM(
    .Clk(Clk), 
    .Vj(Vj_M), 
    .Dest_tag_in(Dest_tag_M), 
    .Instr_type(Mem_type_M), 
    
    // Outputs to Arbiter
    .Data_out(Data_Memory_Out), 
    .Dest_tag_out(Mem_tag_out), 
    .Mem_busy(Mem_busy_out), 
    .Load(Mem_valid_out) // Assuming .Load() indicates valid load result
);

// 10. CDB Arbiter
CDB_Arbiter #(
    .DATA_WIDTH(DATA_SIZE),
    .TAG_WIDTH(TAG_SIZE)
) CDBA (
    // From ALU
    .ALU_result(ALU_result_EX),
    .ALU_tag(Dest_tag_WB_EX),
    .ALU_valid(Dest_tag_WB_EX != 0), // Valid if tag is non-zero
    
    // From Memory
    .MEM_result(Data_Memory_Out),
    .MEM_tag(Mem_tag_out),
    .MEM_valid(Mem_valid_out),
    
    // Outputs to CDB
    .CDB_result(Arb_result),
    .CDB_tag(Arb_tag),
    .CDB_valid(Arb_valid),
    .CDB_reg_write(Arb_reg_write),
    
    // Stalls
    .Stall_ALU(Stall_ALU_from_Arb),
    .Stall_MEM(Stall_MEM_from_Arb)
);

// 11. Single Issue CDB (Pipeline Register/Bus Driver)
Single_Issue_CDB SICDB (
    .Clk(Clk), 
    .Reset(Reset), 
    .Valid_broadcast_in(Arb_valid), 
    .Reg_write_in(Arb_reg_write), 
    .Result_in(Arb_result), 
    .RS_tag_in(Arb_tag), 
    
    .RS_tag_out(cdb_tag_internal),
    .Valid_broadcast_out(cdb_en_internal), 
    .Reg_write_out(cdb_reg_write_internal),
    .Result_out(cdb_data_internal)
);

// Connect Done Signal
assign Done = Done_I;

endmodule