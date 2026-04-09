// Load/Store Queue (LSQ) with Store-to-Load Forwarding and Byte-Level Matching
`timescale 10ns/1ps
module Single_Issue_LSQ #(
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

    // Memory read interface (4 parallel loads)
    output reg [3:0] mem_read_en,
    output reg [31:0] mem_addr_r1, mem_addr_r2, mem_addr_r3, mem_addr_r4,
    output reg [4:0] mem_type_r1, mem_type_r2, mem_type_r3, mem_type_r4,
    output reg [5:0] mem_dest_reg_r1, mem_dest_reg_r2, mem_dest_reg_r3, mem_dest_reg_r4,
    input  wire [3:0] mem_rdy_r,

    // Memory write interface (1 write)
    output reg mem_write_en,
    output reg [31:0] mem_addr_w,
    output reg [31:0] mem_data_w,
    output reg [4:0] mem_type_w,
    input  wire mem_rdy_w,

    // Forwarded load output (to CDB)
    output reg [31:0] forward_data,
    output reg [5:0] forward_dest_reg,
    output reg forward_valid,

    // Queue status
    output wire queue_full
);

    // === LSQ entry state (registered) ===
    reg                      valid      [0:LSQ_SIZE-1];
    reg                      done       [0:LSQ_SIZE-1];
    reg                      is_store   [0:LSQ_SIZE-1];
    reg [5:0]                register   [0:LSQ_SIZE-1];
    reg [4:0]                instr_type [0:LSQ_SIZE-1];
    reg [31:0]               addr       [0:LSQ_SIZE-1];
    reg [31:0]               data       [0:LSQ_SIZE-1];

    // === Pointers (registered) ===
    reg [LSQ_IDX_W-1:0] head;
    reg [LSQ_IDX_W-1:0] tail;
    
    wire [LSQ_IDX_W-1:0] next_tail = tail + 1'b1;
    assign queue_full = (next_tail == head);

    // === Combinational signals (computed each cycle) ===
    reg [LSQ_SIZE-1:0] next_done;
    reg [LSQ_SIZE-1:0] next_valid;
    reg [LSQ_IDX_W-1:0] next_head;
    
    reg [3:0] next_mem_read_en;
    reg [31:0] next_mem_addr_r1, next_mem_addr_r2, next_mem_addr_r3, next_mem_addr_r4;
    reg [4:0] next_mem_type_r1, next_mem_type_r2, next_mem_type_r3, next_mem_type_r4;
    reg [5:0] next_mem_dest_reg_r1, next_mem_dest_reg_r2, next_mem_dest_reg_r3, next_mem_dest_reg_r4;
    
    reg next_mem_write_en;
    reg [31:0] next_mem_addr_w;
    reg [31:0] next_mem_data_w;
    reg [4:0] next_mem_type_w;
    
    reg next_forward_valid;
    reg [31:0] next_forward_data;
    reg [5:0] next_forward_dest_reg;

    // Loop variables
    integer i, j, k;
    
    reg can_issue_store;
    reg [31:0] store_addr;
    
    // Forwarding logic variables
    reg forward_found;
    reg [31:0] forward_data_temp;
    reg [LSQ_IDX_W-1:0] idx_older;
    
    // Address overlap detection
    reg [1:0] store_size, load_size;
    reg [31:0] store_start, store_end;
    reg [31:0] load_start, load_end;
    reg overlap;
    reg fully_contained;
    
    // Byte extraction
    reg [1:0] byte_offset;
    reg [31:0] extracted_byte;
    reg [31:0] extracted_half;
    reg sign_bit;
    reg needs_sign_ext;
    
    // Issue tracking
    integer issued_loads;
    integer issued_stores;
    reg [LSQ_IDX_W-1:0] temp_head;

    // =============================================
    // COMBINATIONAL LOGIC - Calculate next state
    // =============================================
    always @(valid[0], valid[1], valid[2], valid[3], valid[4], valid[5], valid[6], valid[7],
        valid[8], valid[9], valid[10], valid[11], valid[12], valid[13], valid[14], valid[15],
        done[0], done[1], done[2], done[3], done[4], done[5], done[6], done[7],
        done[8], done[9], done[10], done[11], done[12], done[13], done[14], done[15],
        is_store[0], is_store[1], is_store[2], is_store[3], is_store[4], is_store[5], is_store[6], is_store[7],
        is_store[8], is_store[9], is_store[10], is_store[11], is_store[12], is_store[13], is_store[14], is_store[15],
        instr_type[0], instr_type[1], instr_type[2], instr_type[3], instr_type[4], instr_type[5], instr_type[6], instr_type[7],
        instr_type[8], instr_type[9], instr_type[10], instr_type[11], instr_type[12], instr_type[13], instr_type[14], instr_type[15],
        addr[0], addr[1], addr[2], addr[3], addr[4], addr[5], addr[6], addr[7],
        addr[8], addr[9], addr[10], addr[11], addr[12], addr[13], addr[14], addr[15],
        data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7],
        data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15],
        register[0], register[1], register[2], register[3], register[4], register[5], register[6], register[7],
        register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15],
        head, mem_rdy_r, mem_rdy_w) begin
        // Initialize with current state
        for (i = 0; i < LSQ_SIZE; i = i + 1) begin
            next_done[i] = done[i];
            next_valid[i] = valid[i];
        end
        next_head = head;
        
        // Default outputs
        next_mem_read_en = 4'b0000;
        next_mem_write_en = 1'b0;
        next_forward_valid = 1'b0;
        next_forward_data = 32'b0;
        next_forward_dest_reg = 6'b0;
        
        next_mem_addr_r1 = 32'b0;
        next_mem_type_r1 = 5'b0;
        next_mem_dest_reg_r1 = 6'b0;
        
        next_mem_addr_r2 = 32'b0;
        next_mem_type_r2 = 5'b0;
        next_mem_dest_reg_r2 = 6'b0;
        
        next_mem_addr_r3 = 32'b0;
        next_mem_type_r3 = 5'b0;
        next_mem_dest_reg_r3 = 6'b0;
        
        next_mem_addr_r4 = 32'b0;
        next_mem_type_r4 = 5'b0;
        next_mem_dest_reg_r4 = 6'b0;
        
        next_mem_addr_w = 32'b0;
        next_mem_data_w = 32'b0;
        next_mem_type_w = 5'b0;

        // === Dispatch Logic ===
        issued_loads = 0;
        issued_stores = 0;

        for (i = 0; i < LSQ_SIZE; i = i + 1) begin
            if (valid[i] && !done[i]) begin
                if (!is_store[i]) begin
                    // ========== LOAD ==========
                    forward_found = 0;
                    forward_data_temp = 32'b0;
                    
                    // Determine load size
                    case (instr_type[i])
                        5'b00001, 5'b00100: load_size = 2'd0; // LB, LBU
                        5'b00010, 5'b00101: load_size = 2'd1; // LH, LHU
                        5'b00011:           load_size = 2'd2; // LW
                        default:            load_size = 2'd2;
                    endcase
                    
                    // Calculate load address range
                    load_start = addr[i];
                    case (load_size)
                        2'd0: load_end = addr[i];
                        2'd1: load_end = addr[i] + 32'd1;
                        2'd2: load_end = addr[i] + 32'd3;
                        default: load_end = addr[i];
                    endcase
                    
                    // Check if load needs sign extension
                    needs_sign_ext = (instr_type[i] == 5'b00001) || (instr_type[i] == 5'b00010);
                    
                    // Scan older stores for forwarding
                    for (j = 0; j < LSQ_SIZE; j = j + 1) begin
                        idx_older = (head + j[LSQ_IDX_W-1:0]) & (LSQ_SIZE - 1);
                        
                        if (idx_older == i[LSQ_IDX_W-1:0]) begin
                            j = LSQ_SIZE; // Break
                        end else if (valid[idx_older] && is_store[idx_older]) begin
                            // Determine store size
                            case (instr_type[idx_older])
                                5'b00110: store_size = 2'd0; // SB
                                5'b00111: store_size = 2'd1; // SH
                                5'b01000: store_size = 2'd2; // SW
                                default:  store_size = 2'd2;
                            endcase
                            
                            // Calculate store address range
                            store_start = addr[idx_older];
                            case (store_size)
                                2'd0: store_end = addr[idx_older];
                                2'd1: store_end = addr[idx_older] + 32'd1;
                                2'd2: store_end = addr[idx_older] + 32'd3;
                                default: store_end = addr[idx_older];
                            endcase
                            
                            // Check for overlap
                            overlap = (load_start <= store_end) && (store_start <= load_end);
                            fully_contained = (store_start <= load_start) && (load_end <= store_end);
                            
                            if (overlap && fully_contained && !forward_found) begin
                                // Calculate byte offset
                                byte_offset = (load_start - store_start);
                                
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
                                j = LSQ_SIZE; // Break
                            end
                        end
                    end
                    
                    if (forward_found) begin
                        // Mark as done and invalid
                        next_done[i] = 1'b1;
                        next_valid[i] = 1'b0;
                        next_forward_data = forward_data_temp;
                        next_forward_dest_reg = register[i];
                        next_forward_valid = 1'b1;
                    end else if (issued_loads < 4 && mem_rdy_r[issued_loads]) begin
                        // Issue to memory
                        next_mem_read_en[issued_loads] = 1'b1;
                        
                        case (issued_loads)
                            0: begin
                                next_mem_addr_r1 = addr[i];
                                next_mem_type_r1 = instr_type[i];
                                next_mem_dest_reg_r1 = register[i];
                            end
                            1: begin
                                next_mem_addr_r2 = addr[i];
                                next_mem_type_r2 = instr_type[i];
                                next_mem_dest_reg_r2 = register[i];
                            end
                            2: begin
                                next_mem_addr_r3 = addr[i];
                                next_mem_type_r3 = instr_type[i];
                                next_mem_dest_reg_r3 = register[i];
                            end
                            3: begin
                                next_mem_addr_r4 = addr[i];
                                next_mem_type_r4 = instr_type[i];
                                next_mem_dest_reg_r4 = register[i];
                            end
                        endcase
                        
                        next_done[i] = 1'b1;
                        next_valid[i] = 1'b0;
                        issued_loads = issued_loads + 1;
                    end
                    
                end else begin
                    // ========== STORE ==========
                    // Only issue from head (in-order)
                    if (issued_stores < 1 && mem_rdy_w) begin
                        can_issue_store = 1'b1;
                        store_addr = addr[i];
                        
                        for (j = 0; j < LSQ_SIZE; j = j + 1) begin
                            idx_older = (head + j[LSQ_IDX_W-1:0]) & (LSQ_SIZE - 1);
                            
                            if (idx_older == i[LSQ_IDX_W-1:0]) begin
                                j = LSQ_SIZE; // Break
                            end else if (valid[idx_older] && !done[idx_older] && !is_store[idx_older]) begin
                                // Check if addresses could overlap
                                // For simplicity, compare base addresses (could make more precise)
                                if (addr[idx_older] == store_addr) begin
                                    can_issue_store = 1'b0;
                                    j = LSQ_SIZE; // Break
                                end
                            end
                        end
                        
                        if (can_issue_store) begin
                            next_mem_write_en = 1'b1;
                            next_mem_addr_w = addr[i];
                            next_mem_data_w = data[i];
                            next_mem_type_w = instr_type[i];
                            next_done[i] = 1'b1;
                            issued_stores = issued_stores + 1;
                        end
                    end
                end
            end
        end

        // === Retire completed stores from head ===
        temp_head = head;

        for (k = 0; k < LSQ_SIZE; k = k + 1) begin
            if (next_valid[temp_head] && done[temp_head] && is_store[temp_head]) begin  // Changed: done[temp_head] instead of next_done[temp_head]
                // Retire store
                next_valid[temp_head] = 1'b0;
                next_done[temp_head] = 1'b0;
                temp_head = temp_head + 1'b1;
            end else if (!next_valid[temp_head]) begin
                // Skip invalid entries
                temp_head = temp_head + 1'b1;
            end else begin
                // Stop at first valid, non-done entry
                k = LSQ_SIZE; // Break
            end
        end
        
        next_head = temp_head;
    end

    // =============================================
    // SEQUENTIAL LOGIC - Apply state on clock edge
    // =============================================
    always @(posedge Clk or posedge Reset) begin
        if (Reset) begin
            head <= 0;
            tail <= 0;
            
            mem_read_en <= 4'b0;
            mem_write_en <= 1'b0;
            forward_valid <= 1'b0;
            forward_data <= 32'b0;
            forward_dest_reg <= 6'b0;
            
            mem_addr_r1 <= 32'b0;
            mem_type_r1 <= 5'b0;
            mem_dest_reg_r1 <= 6'b0;
            
            mem_addr_r2 <= 32'b0;
            mem_type_r2 <= 5'b0;
            mem_dest_reg_r2 <= 6'b0;
            
            mem_addr_r3 <= 32'b0;
            mem_type_r3 <= 5'b0;
            mem_dest_reg_r3 <= 6'b0;
            
            mem_addr_r4 <= 32'b0;
            mem_type_r4 <= 5'b0;
            mem_dest_reg_r4 <= 6'b0;
            
            mem_addr_w <= 32'b0;
            mem_data_w <= 32'b0;
            mem_type_w <= 5'b0;

            for (i = 0; i < LSQ_SIZE; i = i + 1) begin
                valid[i] <= 1'b0;
                done[i] <= 1'b0;
                is_store[i] <= 1'b0;
                instr_type[i] <= 5'b0;
                addr[i] <= 32'b0;
                data[i] <= 32'b0;
                register[i] <= 6'b0;
            end
            
        end else begin
            // Apply combinational outputs
            for (i = 0; i < LSQ_SIZE; i = i + 1) begin
                done[i] <= next_done[i];
                valid[i] <= next_valid[i];
            end
            
            head <= next_head;
            
            mem_read_en <= next_mem_read_en;
            mem_addr_r1 <= next_mem_addr_r1;
            mem_type_r1 <= next_mem_type_r1;
            mem_dest_reg_r1 <= next_mem_dest_reg_r1;
            
            mem_addr_r2 <= next_mem_addr_r2;
            mem_type_r2 <= next_mem_type_r2;
            mem_dest_reg_r2 <= next_mem_dest_reg_r2;
            
            mem_addr_r3 <= next_mem_addr_r3;
            mem_type_r3 <= next_mem_type_r3;
            mem_dest_reg_r3 <= next_mem_dest_reg_r3;
            
            mem_addr_r4 <= next_mem_addr_r4;
            mem_type_r4 <= next_mem_type_r4;
            mem_dest_reg_r4 <= next_mem_dest_reg_r4;
            
            mem_write_en <= next_mem_write_en;
            mem_addr_w <= next_mem_addr_w;
            mem_data_w <= next_mem_data_w;
            mem_type_w <= next_mem_type_w;
            
            forward_valid <= next_forward_valid;
            forward_data <= next_forward_data;
            forward_dest_reg <= next_forward_dest_reg;

            // === Allocation ===
            if ((instr_type_in >= 5'b00001 && instr_type_in <= 5'b01000) && !queue_full) begin
                valid[tail] <= 1'b1;
                done[tail] <= 1'b0;
                is_store[tail] <= (instr_type_in >= 5'b00110 && instr_type_in <= 5'b01000);
                addr[tail] <= addr_in;
                register[tail] <= register_in;
                instr_type[tail] <= instr_type_in;
                data[tail] <= data_in;
                tail <= next_tail;
            end
        end
    end

endmodule