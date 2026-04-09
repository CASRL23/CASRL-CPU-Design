// Load/Store Queue (LSQ) with Store-to-Load Forwarding and Byte-Level Matching
// Memory loads bypass LSQ and go directly to CDB
`timescale 10ns/1ps
module Load_store_queue #(
    parameter LSQ_SIZE   = 16,
    parameter LSQ_IDX_W  = 4  // log2(16) = 4
)(
    input  wire Clk, Reset,

    // Allocation (from RS)
    input  wire [4:0] instr_type_in,
    //    ALU   - 00000
    //    LB    - 00001
    //    LH    - 00010
    //    LW    - 00011
    //    LBU   - 00100
    //    LHU   - 00101
    //    SB    - 00110
    //    SH    - 00111
    //    SW    - 01000
    input  wire [5:0] register_in, 
    input  wire [31:0] addr_in,
    input  wire [31:0] data_in,   // 0s for Loads

    // Memory read interface (4 parallel reads)
    output reg [3:0] mem_read_en,
    output reg [31:0] mem_addr_r1, mem_addr_r2, mem_addr_r3, mem_addr_r4,    // Mem address for reads
    output reg [4:0] mem_type_r1, mem_type_r2, mem_type_r3, mem_type_r4,     // Mem type (word, half, byte) for reads
    output reg [5:0] mem_dest_reg_r1, mem_dest_reg_r2, mem_dest_reg_r3, mem_dest_reg_r4, // Destination reg for reads   
    input  wire [3:0] mem_rdy_r,

    // Memory write interface (1 write)
    output reg mem_write_en,
    output reg [31:0] mem_addr_w,
    output reg [31:0] mem_data_w,
    output reg [4:0] mem_type_w,
    input  wire mem_rdy_w,

    // Forwarded load output (to CDB) - only for store-to-load forwarding
    output reg [31:0] forward_data,
    output reg [5:0] forward_dest_reg,
    output reg forward_valid,

    // Queue status
    output wire queue_full
);

    // === LSQ entry state ===
    reg                      valid      [0:LSQ_SIZE-1];
    reg                      done       [0:LSQ_SIZE-1];  // Completed (issued or forwarded)
    reg                      is_store   [0:LSQ_SIZE-1];
    reg [5:0]                register   [0:LSQ_SIZE-1];
    reg [4:0]                instr_type [0:LSQ_SIZE-1];
    reg [31:0]               addr       [0:LSQ_SIZE-1];
    reg [31:0]               data       [0:LSQ_SIZE-1];

    // === Pointers ===
    reg [LSQ_IDX_W-1:0] head;
    reg [LSQ_IDX_W-1:0] tail;
    wire [LSQ_IDX_W-1:0] next_tail = tail + 1'b1;
    assign queue_full = (next_tail == head);

    integer i, j, k;
    integer issued_loads, issued_stores;
    integer entries_to_remove;
    reg [LSQ_IDX_W-1:0] temp_head;
    
    // Helper variables for forwarding logic
    reg forward_found;
    reg [31:0] forward_data_temp;
    reg [LSQ_IDX_W-1:0] idx_older;
    
    // Address overlap detection variables
    reg [1:0] store_size, load_size;
    reg [31:0] store_start, store_end;
    reg [31:0] load_start, load_end;
    reg overlap;
    reg fully_contained;
    
    // Byte extraction variables
    reg [1:0] byte_offset;
    reg [31:0] extracted_word;
    reg [31:0] extracted_half;
    reg [31:0] extracted_byte;
    reg sign_bit;
    reg needs_sign_ext;

    // === Reset and initialization ===
    always @(posedge Clk or posedge Reset) begin
        if (Reset) begin
            head <= 0;
            tail <= 0;
            forward_data <= 0;
            forward_dest_reg <= 0;
            forward_valid <= 0;

            mem_read_en  <= 4'b0;
            mem_write_en <= 1'b0;
            
            mem_addr_r1 <= 0;
            mem_type_r1 <= 0;
            mem_dest_reg_r1 <= 0;
      
            mem_addr_r2 <= 0;
            mem_type_r2 <= 0;
            mem_dest_reg_r2 <= 0;
       
            mem_addr_r3 <= 0;
            mem_type_r3 <= 0;
            mem_dest_reg_r3 <= 0;
       
            mem_addr_r4 <= 0;
            mem_type_r4 <= 0;
            mem_dest_reg_r4 <= 0;
                               
            mem_addr_w <= 0;
            mem_data_w <= 0;
            mem_type_w <= 0;

            for (i=0; i<LSQ_SIZE; i=i+1) begin
                valid[i] <= 0;
                done[i] <= 0;
                is_store[i] <= 0;
                instr_type[i] <= 0;
                addr[i] <= 0;
                data[i] <= 0;
                register[i] <= 0;
            end
        end else begin
            // Default outputs cleared
            mem_read_en  <= 4'b0;
            mem_write_en <= 1'b0;
            forward_valid <= 0;

            // === Allocation ===
            // Is a load or store instruction
            if ((instr_type_in >= 5'b00001 && instr_type_in <= 5'b01000) && !queue_full) begin
                valid[tail]      <= 1'b1;
                done[tail]       <= 1'b0;
                is_store[tail]   <= (instr_type_in >= 5'b00110 && instr_type_in <= 5'b01000);
                addr[tail]       <= addr_in;
                register[tail]   <= register_in;
                instr_type[tail] <= instr_type_in;
                data[tail]       <= data_in;
                tail <= next_tail;
            end

            // === Dispatch ===
            issued_loads  = 0;
            issued_stores = 0;

            for (i = 0; i < LSQ_SIZE; i = i + 1) begin
                if (valid[i] && !done[i]) begin
                    if (!is_store[i]) begin
                        // ========== LOAD ==========
                        forward_found = 0;
                        forward_data_temp = 0;
                        
                        // Determine load size (inlined get_size function)
                        case (instr_type[i])
                            5'b00001, 5'b00100: load_size = 2'd0; // LB, LBU (1 byte)
                            5'b00010, 5'b00101: load_size = 2'd1; // LH, LHU (2 bytes)
                            5'b00011:           load_size = 2'd2; // LW (4 bytes)
                            default:            load_size = 2'd2;
                        endcase
                        
                        // Calculate load address range
                        load_start = addr[i];
                        case (load_size)
                            2'd0: load_end = addr[i];         // +0 (1 byte)
                            2'd1: load_end = addr[i] + 1;     // +1 (2 bytes)
                            2'd2: load_end = addr[i] + 3;     // +3 (4 bytes)
                            default: load_end = addr[i];
                        endcase
                        
                        // Check if this load needs sign extension
                        needs_sign_ext = (instr_type[i] == 5'b00001) || (instr_type[i] == 5'b00010);
                        
                        // Scan all older stores for forwarding
                        for (j = 0; j < LSQ_SIZE; j = j + 1) begin
                            idx_older = (head + j) & (LSQ_SIZE - 1);
                            
                            if (idx_older == i) begin
                                j = LSQ_SIZE; // Break - reached current load
                            end else if (valid[idx_older] && is_store[idx_older]) begin
                                // Determine store size
                                case (instr_type[idx_older])
                                    5'b00110: store_size = 2'd0; // SB (1 byte)
                                    5'b00111: store_size = 2'd1; // SH (2 bytes)
                                    5'b01000: store_size = 2'd2; // SW (4 bytes)
                                    default:  store_size = 2'd2;
                                endcase
                                
                                // Calculate store address range
                                store_start = addr[idx_older];
                                case (store_size)
                                    2'd0: store_end = addr[idx_older];
                                    2'd1: store_end = addr[idx_older] + 1;
                                    2'd2: store_end = addr[idx_older] + 3;
                                    default: store_end = addr[idx_older];
                                endcase
                                
                                // Check for overlap
                                overlap = (load_start <= store_end) && (store_start <= load_end);
                                fully_contained = (store_start <= load_start) && (load_end <= store_end);
                                
                                if (overlap && fully_contained && !forward_found) begin
                                    // Can forward! Extract bytes
                                    byte_offset = load_start - store_start;
                                    
                                    // Extract based on load size and offset
                                    case (load_size)
                                        2'd0: begin // Load byte
                                            case (byte_offset[1:0])
                                                2'd0: extracted_byte = {24'b0, data[idx_older][7:0]};
                                                2'd1: extracted_byte = {24'b0, data[idx_older][15:8]};
                                                2'd2: extracted_byte = {24'b0, data[idx_older][23:16]};
                                                2'd3: extracted_byte = {24'b0, data[idx_older][31:24]};
                                            endcase
                                            
                                            if (needs_sign_ext) begin
                                                sign_bit = extracted_byte[7];
                                                forward_data_temp = {{24{sign_bit}}, extracted_byte[7:0]};
                                            end else begin
                                                forward_data_temp = extracted_byte;
                                            end
                                        end
                                        
                                        2'd1: begin // Load halfword
                                            case (byte_offset[1:0])
                                                2'd0: extracted_half = {16'b0, data[idx_older][15:0]};
                                                2'd1: extracted_half = {16'b0, data[idx_older][23:8]};
                                                2'd2: extracted_half = {16'b0, data[idx_older][31:16]};
                                                default: extracted_half = 32'b0;
                                            endcase
                                            
                                            if (needs_sign_ext) begin
                                                sign_bit = extracted_half[15];
                                                forward_data_temp = {{16{sign_bit}}, extracted_half[15:0]};
                                            end else begin
                                                forward_data_temp = extracted_half;
                                            end
                                        end
                                        
                                        2'd2: begin // Load word
                                            forward_data_temp = data[idx_older];
                                        end
                                        
                                        default: forward_data_temp = 32'b0;
                                    endcase
                                    
                                    forward_found = 1;
                                    j = LSQ_SIZE; // Break - found most recent match
                                end
                            end
                        end
                        
                        if (forward_found) begin
                            // Forward directly to CDB
                            done[i] <= 1'b1;
                            forward_data <= forward_data_temp;
                            forward_dest_reg <= register[i];
                            forward_valid <= 1'b1;
                        end else if (issued_loads < 4 && mem_rdy_r[issued_loads]) begin
                            mem_read_en[issued_loads] <= 1'b1;
                            case (issued_loads)
                                0: begin
                                    mem_addr_r1  <= addr[i];
                                    mem_type_r1  <= instr_type[i];
                                    mem_dest_reg_r1 <= register[i];
                                end
                                1: begin
                                    mem_addr_r2  <= addr[i];
                                    mem_type_r2  <= instr_type[i];
                                    mem_dest_reg_r2 <= register[i];
                                end
                                2: begin
                                    mem_addr_r3  <= addr[i];
                                    mem_type_r3  <= instr_type[i];
                                    mem_dest_reg_r3 <= register[i];
                                end
                                3: begin
                                    mem_addr_r4  <= addr[i];
                                    mem_type_r4  <= instr_type[i];
                                    mem_dest_reg_r4 <= register[i];
                                end
                            endcase
                        
                            done[i] <= 1'b1;
                            issued_loads = issued_loads + 1;
                        end                        
                    end else begin
                        // ========== STORE ==========
                        // Only issue stores from head (in-order commit)
                        if (i == head && issued_stores < 1 && mem_rdy_w) begin
                            mem_write_en <= 1'b1;
                            mem_addr_w   <= addr[i];
                            mem_data_w   <= data[i];
                            mem_type_w   <= instr_type[i];
                            done[i] <= 1'b1;
                            issued_stores = issued_stores + 1;
                        end
                    end
                end
            end

            // === Remove completed entries from head ===
            // Count how many consecutive entries at head are done
            entries_to_remove = 0;
            temp_head = head;
            for (k = 0; k < LSQ_SIZE; k = k + 1) begin
                if (temp_head != tail && valid[temp_head] && done[temp_head]) begin
                    entries_to_remove = entries_to_remove + 1;
                    temp_head = temp_head + 1'b1;
                end else begin
                    k = LSQ_SIZE; // Break out of loop
                end
            end
            
            // Invalidate all removed entries and update head pointer once
            for (k = 0; k < entries_to_remove; k = k + 1) begin
                valid[(head + k) & (LSQ_SIZE - 1)] <= 1'b0;
            end
            
            if (entries_to_remove > 0) begin
                head <= head + entries_to_remove;
            end
        end
    end
endmodule