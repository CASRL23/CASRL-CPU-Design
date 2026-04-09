

// This module holds the architectural register file (ARF) and
// the Register Alias Table (RAT) in one "smart" module.
// It replaces the 32 individual register instances with arrays.

module OoO_Reg_file#(
    parameter DATA_WIDTH = 32,
    parameter REG_COUNT = 32,
    parameter REG_ADDR_WIDTH = 5,
    parameter RS_TAG_SIZE = 7
)(
    output reg [DATA_WIDTH-1:0] Read_data1, 
    output reg [DATA_WIDTH-1:0] Read_data2, 
    output wire [DATA_WIDTH-1:0] Display_out,

    input wire Clk, 
    input wire Reset, 

    // --- Read Ports (for RS/Issue) ---
    input wire [REG_ADDR_WIDTH-1:0] Read_reg1,
    input wire [REG_ADDR_WIDTH-1:0] Read_reg2,
    output reg [RS_TAG_SIZE-1:0] Rs1_tag_out, 
    output reg [RS_TAG_SIZE-1:0] Rs2_tag_out,
    output reg Rs1_valid, // 1 = Data is valid, 0 = Tag is valid
    output reg Rs2_valid,

    // --- Issue Port (from Issue Stage - updates the RAT) ---
    input wire issue_en,
    input wire [REG_ADDR_WIDTH-1:0] issue_rd_addr,
    input wire [RS_TAG_SIZE-1:0] issue_tag_in,

    // --- Writeback Port (from CDB) ---
    input wire wb_en,
    input wire [RS_TAG_SIZE-1:0] wb_tag_in, // Tag from CDB
    input wire [DATA_WIDTH-1:0] wb_data_in   // Data from CDB
);

    // 
    // --- Internal Storage ---
    // 1. The Architectural Register File (Data)
    reg [DATA_WIDTH-1:0] reg_data_array [0:REG_COUNT-1];
    
    // 2. The Register Alias Table (Tags)
    reg [RS_TAG_SIZE-1:0] RS_tag [0:REG_COUNT-1];
    
    // 3. The Valid Bits (1 bit per register)
    // We'll define: 1'b0 = Data is valid
    //              1'b1 = Data is invalid (waiting for tag)
    reg [REG_COUNT-1:0] Tag_invalid; // Renamed from Tag_valid for clarity

    integer i;

    // Assign x1's data to the debug display port
    assign Display_out = reg_data_array[1];

//-------------------------------------------------------------------------
//  Combinational Read Logic (Reading from ARF/RAT)
//-------------------------------------------------------------------------
// This block handles reading operands for issuing instructions.
// It checks the valid bit and provides either data or a tag.
// It also includes bypass logic for results from the current cycle's writeback.
//-------------------------------------------------------------------------
    always @(Read_reg1, Read_reg2, wb_en, wb_data_in, Rs1_valid, Rs2_valid,
             Rs1_tag_out, Rs2_tag_out, Tag_invalid, RS_tag, reg_data_array, wb_tag_in) begin
        // --- Read Port 1 Logic ---
        if (Read_reg1 == 5'd0) begin
            // x0 is always 0 and always valid
            Read_data1  = 32'h0;
            Rs1_valid   = 1'b1; // Data is valid
            Rs1_tag_out = 7'h0;
        end else if (Tag_invalid[Read_reg1] == 1'b1) begin
            // Data is INVALID (pending), so output the tag
            Read_data1  = 32'hxxxxxxxx; // Data is garbage
            Rs1_valid   = 1'b0;         // Signal that data is NOT valid
            Rs1_tag_out = RS_tag[Read_reg1];
        end else begin
            // Data is VALID, output the data from the array
            Read_data1  = reg_data_array[Read_reg1];
            Rs1_valid   = 1'b1;         // Signal that data IS valid
            Rs1_tag_out = 7'h0;         // No tag
        end

        // --- Read Port 2 Logic (Identical) ---
        if (Read_reg2 == 5'd0) begin
            Read_data2  = 32'h0;
            Rs2_valid   = 1'b1;
            Rs2_tag_out = 7'h0;
        end else if (Tag_invalid[Read_reg2] == 1'b1) begin
            Read_data2  = 32'hxxxxxxxx;
            Rs2_valid   = 1'b0;
            Rs2_tag_out = RS_tag[Read_reg2];
        end else begin
            Read_data2  = reg_data_array[Read_reg2];
            Rs2_valid   = 1'b1;
            Rs2_tag_out = 7'h0;
        end

        // --- Bypass Logic ---
        // If an operand is not valid but the tag matches the
        // one being broadcast on the CDB *this cycle*, grab the data.
        if (wb_en && !Rs1_valid && (Rs1_tag_out == wb_tag_in)) begin
            Read_data1 = wb_data_in;
            Rs1_valid  = 1'b1;
        end
        if (wb_en && !Rs2_valid && (Rs2_tag_out == wb_tag_in)) begin
            Read_data2 = wb_data_in;
            Rs2_valid  = 1'b1;
        end
    end

//-------------------------------------------------------------------------
//  Sequential Write Logic (Reset, Writeback, Issue)
//-------------------------------------------------------------------------
// This block handles all state changes to the register file.
// - Reset: Clears all data and marks all registers as valid.
// - Writeback: Listens to the CDB and updates data/valid bits.
// - Issue: Marks a register as invalid and stores the new tag.
//-------------------------------------------------------------------------
    always @(posedge Clk or posedge Reset) begin
        if (Reset) begin
            // On reset, all registers are valid (0) and contain 0
            for (i = 0; i < REG_COUNT; i = i + 1) begin
                reg_data_array[i] <= 32'h0;
                Tag_invalid[i]    <= 1'b0; // 0 = Valid Data
                RS_tag[i]         <= 7'h0;
            end
        end else begin
            
            // --- 1. Handle Writeback (Snooping the CDB) ---
            // This checks all 31 registers in parallel
            if (wb_en) begin
                for (i = 1; i < REG_COUNT; i = i + 1) begin // Start from 1, x0 is read-only
                    // Check if this register (i) is waiting for the tag on the bus
                    if (Tag_invalid[i] == 1'b1 && RS_tag[i] == wb_tag_in) begin
                        reg_data_array[i] <= wb_data_in; // Write the data
                        Tag_invalid[i]    <= 1'b0;      // Mark as valid
                    end
                end
            end

            // --- 2. Handle Issue (Writing a new Tag) ---
            // This has priority over writeback.
            if (issue_en) begin
                if (issue_rd_addr != 5'd0) begin
                    // A new instruction is being issued
                    RS_tag[issue_rd_addr]   <= issue_tag_in; // Store the new tag
                    Tag_invalid[issue_rd_addr] <= 1'b1;     // Mark as invalid (waiting)
                end
            end

        end
    end

endmodule