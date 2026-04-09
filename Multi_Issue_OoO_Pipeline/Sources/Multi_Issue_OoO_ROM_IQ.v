// Multi-issue Out-of-Order ROM-Decode Instruction Queue
// Circular buffer with branch flush support and dynamic read/write
module Multi_Issue_ROM_IQ#(
    parameter IQ_size = 16,
    parameter Index_size = 4 // log base 2 of IQ size
)(
    input wire Clk, Reset, Flush, Stall,
    input wire [31:0] Instr_in0, Instr_in1, Instr_in2, Instr_in3,
    input wire [31:0] PC_in0, PC_in1, PC_in2, PC_in3,
    input wire [2:0] Num_instr_in, // How many instructions to write (0-4)
    input wire Branch_detected, // Branch detected in decode stage
    input wire [1:0] Branch_position, // Position of branch in current block (0-3)
    input wire [2:0] Num_instr_out, // How many instructions decode stage can consume (0-4)
    
    output reg Is_full,
    output reg Is_empty,
    output reg [2:0] Num_available, // How many valid instructions available to read
    output reg [31:0] PC_out0, PC_out1, PC_out2, PC_out3,
    output reg [31:0] Instr_out0, Instr_out1, Instr_out2, Instr_out3
);

    reg [31:0] Instr [IQ_size-1:0];
    reg [31:0] PC [IQ_size-1:0];
    reg [IQ_size-1:0] Valid; // Valid bits
    reg [Index_size-1:0] Head, Tail;
    reg [Index_size:0] Count; // Number of valid entries (needs extra bit)
    
    wire [Index_size:0] Space_available;
    wire [2:0] Actual_write_count;
    wire [2:0] Actual_read_count;
    wire [3:0] Num_to_flush;
    
    // Calculate available space
    assign Space_available = IQ_size - Count;
    
    // Determine how many instructions to flush after branch
    // If branch is at position 0: flush next 7 (2 blocks)
    // If branch is at position 1: flush next 6 
    // If branch is at position 2: flush next 5
    // If branch is at position 3: flush next 4
    assign Num_to_flush = Branch_detected ? (4'd8 - {2'b0, Branch_position} - 4'd1) : 4'd0;
    
    // Determine actual write count (min of requested and available space)
    assign Actual_write_count = (Stall) ? 3'd0 :
                                (Num_instr_in > Space_available[2:0]) ? Space_available[2:0] : 
                                Num_instr_in;
    
    // Determine actual read count (min of requested and available entries)
    assign Actual_read_count = (Num_instr_out > Count[2:0]) ? Count[2:0] : Num_instr_out;
    
    // Status outputs
    always @(*) begin
        Is_full = (Space_available == 0);
        Is_empty = (Count == 0);
        Num_available = (Count >= 4) ? 3'd4 : Count[2:0];
    end
    
    // Output logic - combinational read from head
    // Use wire indices for cleaner code
    wire [Index_size-1:0] head_idx0 = Head;
    wire [Index_size-1:0] head_idx1 = (Head + 1) % IQ_size;
    wire [Index_size-1:0] head_idx2 = (Head + 2) % IQ_size;
    wire [Index_size-1:0] head_idx3 = (Head + 3) % IQ_size;
    
    always @(*) begin
        // Output 0
        PC_out0 = PC[head_idx0];
        Instr_out0 = Instr[head_idx0];
        if (!Valid[head_idx0]) begin
            PC_out0 = 32'h0;
            Instr_out0 = 32'h00000013; // NOP
        end
        
        // Output 1
        PC_out1 = PC[head_idx1];
        Instr_out1 = Instr[head_idx1];
        if (!Valid[head_idx1]) begin
            PC_out1 = 32'h0;
            Instr_out1 = 32'h00000013; // NOP
        end
        
        // Output 2
        PC_out2 = PC[head_idx2];
        Instr_out2 = Instr[head_idx2];
        if (!Valid[head_idx2]) begin
            PC_out2 = 32'h0;
            Instr_out2 = 32'h00000013; // NOP
        end
        
        // Output 3
        PC_out3 = PC[head_idx3];
        Instr_out3 = Instr[head_idx3];
        if (!Valid[head_idx3]) begin
            PC_out3 = 32'h0;
            Instr_out3 = 32'h00000013; // NOP
        end
    end
    
    // Synchronous write/update logic
    integer i;
    always @(posedge Clk) begin
        if (Reset || Flush) begin
            Head <= 0;
            Tail <= 0;
            Count <= 0;
            Valid <= {IQ_size{1'b0}};
            for (i = 0; i < IQ_size; i = i + 1) begin
                Instr[i] <= 32'h00000013; // NOP
                PC[i] <= 32'h0;
            end
        end else begin
            // Handle branch flush first (takes priority)
            if (Branch_detected && Num_to_flush > 0) begin
                // Invalidate the next Num_to_flush entries from tail backwards
                for (i = 0; i < 8; i = i + 1) begin
                    if (i < Num_to_flush) begin
                        Valid[(Tail - i - 1 + IQ_size) % IQ_size] <= 1'b0;
                    end
                end
                // Update tail and count
                Tail <= (Tail - Num_to_flush + IQ_size) % IQ_size;
                Count <= (Count > Num_to_flush) ? (Count - Num_to_flush) : 0;
            end 
            // Normal operation: handle reads and writes (when no branch flush)
            else begin
                // Dequeue instructions (advance head)
                if (Actual_read_count > 0) begin
                    for (i = 0; i < 4; i = i + 1) begin
                        if (i < Actual_read_count) begin
                            Valid[(Head + i) % IQ_size] <= 1'b0;
                        end
                    end
                    Head <= (Head + Actual_read_count) % IQ_size;
                end
                
                // Enqueue new instructions
                if (Actual_write_count > 0) begin
                    if (Actual_write_count >= 1) begin
                        Instr[Tail] <= Instr_in0;
                        PC[Tail] <= PC_in0;
                        Valid[Tail] <= 1'b1;
                    end
                    
                    if (Actual_write_count >= 2) begin
                        Instr[(Tail + 1) % IQ_size] <= Instr_in1;
                        PC[(Tail + 1) % IQ_size] <= PC_in1;
                        Valid[(Tail + 1) % IQ_size] <= 1'b1;
                    end
                    
                    if (Actual_write_count >= 3) begin
                        Instr[(Tail + 2) % IQ_size] <= Instr_in2;
                        PC[(Tail + 2) % IQ_size] <= PC_in2;
                        Valid[(Tail + 2) % IQ_size] <= 1'b1;
                    end
                    
                    if (Actual_write_count >= 4) begin
                        Instr[(Tail + 3) % IQ_size] <= Instr_in3;
                        PC[(Tail + 3) % IQ_size] <= PC_in3;
                        Valid[(Tail + 3) % IQ_size] <= 1'b1;
                    end
                    
                    Tail <= (Tail + Actual_write_count) % IQ_size;
                end
                
                // Update count
                Count <= Count - Actual_read_count + Actual_write_count;
            end
        end
    end

endmodule