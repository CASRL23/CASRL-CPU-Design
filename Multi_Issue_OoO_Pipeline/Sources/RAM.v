module RAM(
    input  wire Clk,
    input  wire [31:0] Address,
    input  wire [31:0] Data_in,
    input  wire Store, // Write Enable
    input  wire Byte, Half, Word, Unsigned, // Control signals
    output reg  [31:0] Data_out
);

    // 1. Calculate Word-Aligned Address
    wire [12:0] word_addr = Address[14:2]; // 32KB = 8192 words

    // 2. Generate 4-bit Write Enable Mask (Replaces Read-Modify-Write)
    reg [3:0] we;
    always @(*) begin
        we = 4'b0000;
        if (Store) begin
            if (Word) we = 4'b1111;
            else if (Half) begin
                // Write top half or bottom half based on Address[1]
                we = Address[1] ? 4'b1100 : 4'b0011; 
            end
            else if (Byte) begin
                // Write specific byte based on Address[1:0]
                case (Address[1:0])
                    2'b00: we = 4'b0001;
                    2'b01: we = 4'b0010;
                    2'b10: we = 4'b0100;
                    2'b11: we = 4'b1000;
                endcase
            end
        end
    end

    // 3. Align Input Data for Write
    // BRAM writes happen at fixed bit positions. We must shift data to the correct lane.
    reg [31:0] aligned_data_in;
    always @(*) begin
        aligned_data_in = Data_in; // Default for Word
        if (Byte) aligned_data_in = {4{Data_in[7:0]}}; // Replicate byte to all lanes
        else if (Half) aligned_data_in = {2{Data_in[15:0]}}; // Replicate half to both lanes
    end

    // 4. INFER BRAM (Synchronous Read & Write)
    reg [31:0] MEM [0:8191];
    reg [31:0] raw_data_out;

    always @(posedge Clk) begin
        // Write Port with Byte Enables
        if (we[0]) MEM[word_addr][7:0]   <= aligned_data_in[7:0];
        if (we[1]) MEM[word_addr][15:8]  <= aligned_data_in[15:8];
        if (we[2]) MEM[word_addr][23:16] <= aligned_data_in[23:16];
        if (we[3]) MEM[word_addr][31:24] <= aligned_data_in[31:24];

        // Synchronous Read (The major change!)
        // Data is available on the NEXT cycle
        raw_data_out <= MEM[word_addr];
    end

    // 5. Output Formatting (Combinational Logic AFTER the BRAM)
    // This handles LB, LH, LBU, LHU, LW logic
    // NOTE: This logic now operates on the data fetched in the PREVIOUS cycle.
    
    // We need to latch the lower bits of the address to know 
    // which byte/half to select during the read phase.
    reg [1:0] addr_latch;
    reg byte_latch, half_latch, word_latch, unsigned_latch;

    always @(posedge Clk) begin
        addr_latch     <= Address[1:0];
        byte_latch     <= Byte;
        half_latch     <= Half;
        word_latch     <= Word;
        unsigned_latch <= Unsigned;
    end

    always @(*) begin
        Data_out = 32'b0;
        if (word_latch) begin
            Data_out = raw_data_out;
        end
        else if (half_latch) begin
            if (addr_latch[1]) // Upper Half
                Data_out = unsigned_latch ? {16'b0, raw_data_out[31:16]} : {{16{raw_data_out[31]}}, raw_data_out[31:16]};
            else               // Lower Half
                Data_out = unsigned_latch ? {16'b0, raw_data_out[15:0]}  : {{16{raw_data_out[15]}}, raw_data_out[15:0]};
        end
        else if (byte_latch) begin
            case (addr_latch)
                2'b00: Data_out = unsigned_latch ? {24'b0, raw_data_out[7:0]}   : {{24{raw_data_out[7]}},  raw_data_out[7:0]};
                2'b01: Data_out = unsigned_latch ? {24'b0, raw_data_out[15:8]}  : {{24{raw_data_out[15]}}, raw_data_out[15:8]};
                2'b10: Data_out = unsigned_latch ? {24'b0, raw_data_out[23:16]} : {{24{raw_data_out[23]}}, raw_data_out[23:16]};
                2'b11: Data_out = unsigned_latch ? {24'b0, raw_data_out[31:24]} : {{24{raw_data_out[31]}}, raw_data_out[31:24]};
            endcase
        end
    end

endmodule