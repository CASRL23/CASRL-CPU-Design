module Multi_Issue_Dispatch#(
    parameter RS_SIZE = 128
)(
    input wire [RS_SIZE-1:0] Ready_bits, Is_mem,
    input wire Clk, Reset,
    
    // ALU Dispatch (Now registered - 1 cycle after issue)
    output reg [6:0] RS_index0, RS_index1, RS_index2, RS_index3,
    output reg       Valid_dispatch0, Valid_dispatch1, Valid_dispatch2, Valid_dispatch3,
    
    // Mem Dispatch
    output reg [6:0] RS_index4,
    output reg       Valid_dispatch4
);

    // State Registers (Round Robin Pointers)
    reg [6:0] ALU_dispatch_idx;
    reg [6:0] Mem_dispatch_idx;

    // Combinational search results (internal)
    reg [6:0] found_alu_0, found_alu_1, found_alu_2, found_alu_3;
    reg [6:0] found_mem_0;
    reg found_alu_valid_0, found_alu_valid_1, found_alu_valid_2, found_alu_valid_3;
    reg found_mem_valid_0;
    
    reg [6:0] next_alu_idx;
    reg [6:0] next_mem_idx;

    integer i;
    reg [2:0] alu_count;
    reg [6:0] search_idx;

    // ============================================================
    // COMBINATIONAL SEARCH LOGIC (same as before)
    // ============================================================
    always @(*) begin
        // Defaults
        next_alu_idx = ALU_dispatch_idx; 
        next_mem_idx = Mem_dispatch_idx;
        
        found_alu_0 = 0; found_alu_valid_0 = 0;
        found_alu_1 = 0; found_alu_valid_1 = 0;
        found_alu_2 = 0; found_alu_valid_2 = 0;
        found_alu_3 = 0; found_alu_valid_3 = 0;
        found_mem_0 = 0; found_mem_valid_0 = 0;
        
        // ALU Operations search
        alu_count = 0;
        for (i = 0; i < RS_SIZE; i = i + 1) begin
            search_idx = (ALU_dispatch_idx + i[6:0]) % RS_SIZE;
            
            if (Ready_bits[search_idx] && !Is_mem[search_idx] && alu_count < 3'd4) begin
                case (alu_count)
                    3'd0: begin found_alu_0 = search_idx; found_alu_valid_0 = 1; end
                    3'd1: begin found_alu_1 = search_idx; found_alu_valid_1 = 1; end
                    3'd2: begin found_alu_2 = search_idx; found_alu_valid_2 = 1; end
                    3'd3: begin found_alu_3 = search_idx; found_alu_valid_3 = 1; end
                endcase
                
                next_alu_idx = (search_idx + 1) % RS_SIZE;
                alu_count = alu_count + 1;
            end
        end

        // Memory Operations search
        for (i = 0; i < RS_SIZE; i = i + 1) begin
            search_idx = (Mem_dispatch_idx + i[6:0]) % RS_SIZE;
            
            if (!found_mem_valid_0 && Ready_bits[search_idx] && Is_mem[search_idx]) begin
                found_mem_0 = search_idx;
                found_mem_valid_0 = 1;
                next_mem_idx = (search_idx + 1) % RS_SIZE;
            end
        end
    end

    // ============================================================
    // SEQUENTIAL LOGIC - Register outputs AND update pointers
    // ============================================================
    always @(posedge Clk) begin
        if (Reset) begin
            ALU_dispatch_idx <= 7'd0;
            Mem_dispatch_idx <= 7'd0;
            
            // Reset outputs
            Valid_dispatch0 <= 1'b0;
            Valid_dispatch1 <= 1'b0;
            Valid_dispatch2 <= 1'b0;
            Valid_dispatch3 <= 1'b0;
            Valid_dispatch4 <= 1'b0;
            RS_index0 <= 7'd0;
            RS_index1 <= 7'd0;
            RS_index2 <= 7'd0;
            RS_index3 <= 7'd0;
            RS_index4 <= 7'd0;
        end
        else begin
            // Register the dispatch outputs (creates 1-cycle latency)
            Valid_dispatch0 <= found_alu_valid_0;
            RS_index0       <= found_alu_0;
            
            Valid_dispatch1 <= found_alu_valid_1;
            RS_index1       <= found_alu_1;
            
            Valid_dispatch2 <= found_alu_valid_2;
            RS_index2       <= found_alu_2;
            
            Valid_dispatch3 <= found_alu_valid_3;
            RS_index3       <= found_alu_3;
            
            Valid_dispatch4 <= found_mem_valid_0;
            RS_index4       <= found_mem_0;
            
            // Update pointers
            if (found_alu_valid_0 || found_alu_valid_1 || found_alu_valid_2 || found_alu_valid_3)
                ALU_dispatch_idx <= next_alu_idx;
            
            if (found_mem_valid_0)
                Mem_dispatch_idx <= next_mem_idx;
        end
    end

endmodule