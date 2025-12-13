module Multi_Issue_RAM(
    output reg [31:0] Data_out0, Data_out1, Data_out2, Data_out3,
    input  wire [31:0] Data_in0, Data_in1, Data_in2, Data_in3, 
    input  wire [31:0] Address0, Address1, Address2, Address3,
    input  wire Store0, Store1, Store2, Store3, 
    input  wire Clk,
    input  wire Byte0, Byte1, Byte2, Byte3, 
    input  wire Half0, Half1, Half2, Half3, 
    input  wire Word0, Word1, Word2, Word3, 
    input  wire Unsigned0, Unsigned1, Unsigned2, Unsigned3
);

    // 32K words = 128 KB RAM per bank
    // Each bank gets ONE write port and ONE read port 
    (* ram_style = "block" *) reg [31:0] RAM0 [0:32767];
    (* ram_style = "block" *) reg [31:0] RAM1 [0:32767];
    (* ram_style = "block" *) reg [31:0] RAM2 [0:32767];
    (* ram_style = "block" *) reg [31:0] RAM3 [0:32767];
    
    // Compute word addresses
    wire [14:0] word_addr0 = Address0[16:2];
    wire [14:0] word_addr1 = Address1[16:2];
    wire [14:0] word_addr2 = Address2[16:2];
    wire [14:0] word_addr3 = Address3[16:2];
    
    // Determine if store is present
    wire any_store = Store0 | Store1 | Store2 | Store3;
    
    // Select the active store's signals
    wire [14:0] store_addr = Store3 ? word_addr3 : Store2 ? word_addr2 : Store1 ? word_addr1 : word_addr0;
    wire [31:0] store_data_in = Store3 ? Data_in3 : Store2 ? Data_in2 : Store1 ? Data_in1 : Data_in0;
    wire [1:0] store_addr_lsb = Store3 ? Address3[1:0] : Store2 ? Address2[1:0] : Store1 ? Address1[1:0] : Address0[1:0];
    wire store_byte = Store3 ? Byte3 : Store2 ? Byte2 : Store1 ? Byte1 : Byte0;
    wire store_half = Store3 ? Half3 : Store2 ? Half2 : Store1 ? Half1 : Half0;
    wire store_word = Store3 ? Word3 : Store2 ? Word2 : Store1 ? Word1 : Word0;
    
    // Read data from RAM (synchronous) - these are PURE BRAM reads
    reg [31:0] ram_read0, ram_read1, ram_read2, ram_read3;
    
    reg [14:0] store_addr_r;
    reg [31:0] store_data_r;
    reg [1:0] store_addr_lsb_r;
    reg store_byte_r, store_half_r, store_word_r;
    reg any_store_r;
    
    // Registers for read addresses (to detect hazards)
    reg [14:0] word_addr0_r, word_addr1_r, word_addr2_r, word_addr3_r;
    
    //Registers for address bits needed for byte/half selection
    reg [1:0] addr_lsb0_r, addr_lsb1_r, addr_lsb2_r, addr_lsb3_r;
    reg addr_bit1_0_r, addr_bit1_1_r, addr_bit1_2_r, addr_bit1_3_r;
    reg byte0_r, byte1_r, byte2_r, byte3_r;
    reg half0_r, half1_r, half2_r, half3_r;
    reg word0_r, word1_r, word2_r, word3_r;
    reg unsigned0_r, unsigned1_r, unsigned2_r, unsigned3_r;
    
    // SYNCHRONOUS BRAM 
    always @(posedge Clk) begin
        ram_read0 <= RAM0[word_addr0];
        ram_read1 <= RAM1[word_addr1];
        ram_read2 <= RAM2[word_addr2];
        ram_read3 <= RAM3[word_addr3];
        
        // Register the CURRENT cycle's store info for NEXT cycle's forwarding
        store_addr_r <= store_addr;
        store_data_r <= store_data_in;
        store_addr_lsb_r <= store_addr_lsb;
        store_byte_r <= store_byte;
        store_half_r <= store_half;
        store_word_r <= store_word;
        any_store_r <= any_store;
        
        // Register the CURRENT cycle's read addresses
        word_addr0_r <= word_addr0;
        word_addr1_r <= word_addr1;
        word_addr2_r <= word_addr2;
        word_addr3_r <= word_addr3;
        
        // Control signals for output formatting
        addr_lsb0_r <= Address0[1:0];
        addr_lsb1_r <= Address1[1:0];
        addr_lsb2_r <= Address2[1:0];
        addr_lsb3_r <= Address3[1:0];
        
        addr_bit1_0_r <= Address0[1];
        addr_bit1_1_r <= Address1[1];
        addr_bit1_2_r <= Address2[1];
        addr_bit1_3_r <= Address3[1];
        
        byte0_r <= Byte0;
        byte1_r <= Byte1;
        byte2_r <= Byte2;
        byte3_r <= Byte3;
        
        half0_r <= Half0;
        half1_r <= Half1;
        half2_r <= Half2;
        half3_r <= Half3;
        
        word0_r <= Word0;
        word1_r <= Word1;
        word2_r <= Word2;
        word3_r <= Word3;
        
        unsigned0_r <= Unsigned0;
        unsigned1_r <= Unsigned1;
        unsigned2_r <= Unsigned2;
        unsigned3_r <= Unsigned3;
        
        // Write to all banks with byte/half/word enables
        if (any_store) begin
            if (store_word) begin
                // Full word write to all banks
                RAM0[store_addr] <= store_data_in;
                RAM1[store_addr] <= store_data_in;
                RAM2[store_addr] <= store_data_in;
                RAM3[store_addr] <= store_data_in;
            end else if (store_half) begin
                // Half-word write to all banks
                if (store_addr_lsb[1]) begin
                    // Upper halfword
                    RAM0[store_addr][31:16] <= store_data_in[15:0];
                    RAM1[store_addr][31:16] <= store_data_in[15:0];
                    RAM2[store_addr][31:16] <= store_data_in[15:0];
                    RAM3[store_addr][31:16] <= store_data_in[15:0];
                end else begin
                    // Lower halfword
                    RAM0[store_addr][15:0] <= store_data_in[15:0];
                    RAM1[store_addr][15:0] <= store_data_in[15:0];
                    RAM2[store_addr][15:0] <= store_data_in[15:0];
                    RAM3[store_addr][15:0] <= store_data_in[15:0];
                end
            end else if (store_byte) begin
                // Byte write to all banks
                case (store_addr_lsb)
                    2'b00: begin
                        RAM0[store_addr][7:0] <= store_data_in[7:0];
                        RAM1[store_addr][7:0] <= store_data_in[7:0];
                        RAM2[store_addr][7:0] <= store_data_in[7:0];
                        RAM3[store_addr][7:0] <= store_data_in[7:0];
                    end
                    2'b01: begin
                        RAM0[store_addr][15:8] <= store_data_in[7:0];
                        RAM1[store_addr][15:8] <= store_data_in[7:0];
                        RAM2[store_addr][15:8] <= store_data_in[7:0];
                        RAM3[store_addr][15:8] <= store_data_in[7:0];
                    end
                    2'b10: begin
                        RAM0[store_addr][23:16] <= store_data_in[7:0];
                        RAM1[store_addr][23:16] <= store_data_in[7:0];
                        RAM2[store_addr][23:16] <= store_data_in[7:0];
                        RAM3[store_addr][23:16] <= store_data_in[7:0];
                    end
                    2'b11: begin
                        RAM0[store_addr][31:24] <= store_data_in[7:0];
                        RAM1[store_addr][31:24] <= store_data_in[7:0];
                        RAM2[store_addr][31:24] <= store_data_in[7:0];
                        RAM3[store_addr][31:24] <= store_data_in[7:0];
                    end
                endcase
            end
        end
    end
    
    // Function to compute what the full word WILL BE after a partial write
    function [31:0] compute_forwarded_value;
        input [31:0] old_data;     // Data currently in RAM (from ram_read)
        input [31:0] write_data;   // Data being written
        input [1:0] addr_lsb;      // Address LSBs
        input is_byte, is_half, is_word;
        begin
            if (is_word) begin
                compute_forwarded_value = write_data;
            end else if (is_half) begin
                if (addr_lsb[1])
                    compute_forwarded_value = {write_data[15:0], old_data[15:0]};
                else
                    compute_forwarded_value = {old_data[31:16], write_data[15:0]};
            end else if (is_byte) begin
                case (addr_lsb)
                    2'b00: compute_forwarded_value = {old_data[31:8], write_data[7:0]};
                    2'b01: compute_forwarded_value = {old_data[31:16], write_data[7:0], old_data[7:0]};
                    2'b10: compute_forwarded_value = {old_data[31:24], write_data[7:0], old_data[15:0]};
                    2'b11: compute_forwarded_value = {write_data[7:0], old_data[23:0]};
                endcase
            end else begin
                compute_forwarded_value = old_data;
            end
        end
    endfunction
    
    // COMBINATIONAL output logic with forwarding
    // This happens AFTER the BRAM reads are registered
    reg [31:0] final_data0, final_data1, final_data2, final_data3;
    
    always @(any_store_r, store_addr_r, word_addr0_r, word_addr1_r, word_addr2_r, word_addr3_r,
         ram_read0, ram_read1, ram_read2, ram_read3,
         store_data_r, store_addr_lsb_r, store_byte_r, store_half_r, store_word_r,
         word0_r, word1_r, word2_r, word3_r,
         half0_r, half1_r, half2_r, half3_r,
         byte0_r, byte1_r, byte2_r, byte3_r,
         unsigned0_r, unsigned1_r, unsigned2_r, unsigned3_r,
         addr_bit1_0_r, addr_bit1_1_r, addr_bit1_2_r, addr_bit1_3_r,
         addr_lsb0_r, addr_lsb1_r, addr_lsb2_r, addr_lsb3_r) begin
         
        // Port 0: Check if PREV cycle's store matches PREV cycle's read address
        if (any_store_r && (store_addr_r == word_addr0_r)) begin
            // Same-cycle store-to-load forwarding
            final_data0 = compute_forwarded_value(ram_read0, store_data_r, store_addr_lsb_r,
                                                  store_byte_r, store_half_r, store_word_r);
        end else begin
            final_data0 = ram_read0;
        end
        
        // Port 0 output formatting
        if (word0_r) begin
            Data_out0 = final_data0;
        end else if (half0_r) begin
            if (addr_bit1_0_r) begin
                Data_out0 = unsigned0_r ? {16'b0, final_data0[31:16]} : {{16{final_data0[31]}}, final_data0[31:16]};
            end else begin
                Data_out0 = unsigned0_r ? {16'b0, final_data0[15:0]} : {{16{final_data0[15]}}, final_data0[15:0]};
            end
        end else if (byte0_r) begin
            case (addr_lsb0_r)
                2'b00: Data_out0 = unsigned0_r ? {24'b0, final_data0[7:0]}   : {{24{final_data0[7]}},  final_data0[7:0]};
                2'b01: Data_out0 = unsigned0_r ? {24'b0, final_data0[15:8]}  : {{24{final_data0[15]}}, final_data0[15:8]};
                2'b10: Data_out0 = unsigned0_r ? {24'b0, final_data0[23:16]} : {{24{final_data0[23]}}, final_data0[23:16]};
                2'b11: Data_out0 = unsigned0_r ? {24'b0, final_data0[31:24]} : {{24{final_data0[31]}}, final_data0[31:24]};
            endcase
        end else begin
            Data_out0 = 32'b0;
        end
        
        // Port 1
        if (any_store_r && (store_addr_r == word_addr1_r)) begin
            final_data1 = compute_forwarded_value(ram_read1, store_data_r, store_addr_lsb_r,
                                                  store_byte_r, store_half_r, store_word_r);
        end else begin
            final_data1 = ram_read1;
        end
        
        if (word1_r) begin
            Data_out1 = final_data1;
        end else if (half1_r) begin
            if (addr_bit1_1_r) begin
                Data_out1 = unsigned1_r ? {16'b0, final_data1[31:16]} : {{16{final_data1[31]}}, final_data1[31:16]};
            end else begin
                Data_out1 = unsigned1_r ? {16'b0, final_data1[15:0]} : {{16{final_data1[15]}}, final_data1[15:0]};
            end
        end else if (byte1_r) begin
            case (addr_lsb1_r)
                2'b00: Data_out1 = unsigned1_r ? {24'b0, final_data1[7:0]}   : {{24{final_data1[7]}},  final_data1[7:0]};
                2'b01: Data_out1 = unsigned1_r ? {24'b0, final_data1[15:8]}  : {{24{final_data1[15]}}, final_data1[15:8]};
                2'b10: Data_out1 = unsigned1_r ? {24'b0, final_data1[23:16]} : {{24{final_data1[23]}}, final_data1[23:16]};
                2'b11: Data_out1 = unsigned1_r ? {24'b0, final_data1[31:24]} : {{24{final_data1[31]}}, final_data1[31:24]};
            endcase
        end else begin
            Data_out1 = 32'b0;
        end
        
        // Port 2
        if (any_store_r && (store_addr_r == word_addr2_r)) begin
            final_data2 = compute_forwarded_value(ram_read2, store_data_r, store_addr_lsb_r,
                                                  store_byte_r, store_half_r, store_word_r);
        end else begin
            final_data2 = ram_read2;
        end
        
        if (word2_r) begin
            Data_out2 = final_data2;
        end else if (half2_r) begin
            if (addr_bit1_2_r) begin
                Data_out2 = unsigned2_r ? {16'b0, final_data2[31:16]} : {{16{final_data2[31]}}, final_data2[31:16]};
            end else begin
                Data_out2 = unsigned2_r ? {16'b0, final_data2[15:0]} : {{16{final_data2[15]}}, final_data2[15:0]};
            end
        end else if (byte2_r) begin
            case (addr_lsb2_r)
                2'b00: Data_out2 = unsigned2_r ? {24'b0, final_data2[7:0]}   : {{24{final_data2[7]}},  final_data2[7:0]};
                2'b01: Data_out2 = unsigned2_r ? {24'b0, final_data2[15:8]}  : {{24{final_data2[15]}}, final_data2[15:8]};
                2'b10: Data_out2 = unsigned2_r ? {24'b0, final_data2[23:16]} : {{24{final_data2[23]}}, final_data2[23:16]};
                2'b11: Data_out2 = unsigned2_r ? {24'b0, final_data2[31:24]} : {{24{final_data2[31]}}, final_data2[31:24]};
            endcase
        end else begin
            Data_out2 = 32'b0;
        end
        
        // Port 3
        if (any_store_r && (store_addr_r == word_addr3_r)) begin
            final_data3 = compute_forwarded_value(ram_read3, store_data_r, store_addr_lsb_r,
                                                  store_byte_r, store_half_r, store_word_r);
        end else begin
            final_data3 = ram_read3;
        end
        
        if (word3_r) begin
            Data_out3 = final_data3;
        end else if (half3_r) begin
            if (addr_bit1_3_r) begin
                Data_out3 = unsigned3_r ? {16'b0, final_data3[31:16]} : {{16{final_data3[31]}}, final_data3[31:16]};
            end else begin
                Data_out3 = unsigned3_r ? {16'b0, final_data3[15:0]} : {{16{final_data3[15]}}, final_data3[15:0]};
            end
        end else if (byte3_r) begin
            case (addr_lsb3_r)
                2'b00: Data_out3 = unsigned3_r ? {24'b0, final_data3[7:0]}   : {{24{final_data3[7]}},  final_data3[7:0]};
                2'b01: Data_out3 = unsigned3_r ? {24'b0, final_data3[15:8]}  : {{24{final_data3[15]}}, final_data3[15:8]};
                2'b10: Data_out3 = unsigned3_r ? {24'b0, final_data3[23:16]} : {{24{final_data3[23]}}, final_data3[23:16]};
                2'b11: Data_out3 = unsigned3_r ? {24'b0, final_data3[31:24]} : {{24{final_data3[31]}}, final_data3[31:24]};
            endcase
        end else begin
            Data_out3 = 32'b0;
        end
    end
    
endmodule