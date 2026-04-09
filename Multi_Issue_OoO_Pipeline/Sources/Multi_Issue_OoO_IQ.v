`timescale 10ns/1ps
module Pre_Decode_IQ (
    input wire Clk,
    input wire Reset,
    
    // Input - up to 6 instructions per cycle from Fetch
    input wire [6*66-1:0] FIQ_in, 
    
    // Output - queue state         
    output wire [5:0] IQ_free_slots,
    
    // Output - up to 4 instructions per cycle to Decode
    output reg [259:0] Issue_data,    
    input wire [2:0] RS_slots,
    
    input wire Flush
);
    // Circular buffer - holds 32 entries of 65 bits each
    reg [64:0] data [0:31];
    reg [4:0] head;
    reg [4:0] tail;
    reg [5:0] count;
    
    integer i;
    
    // Queue status signals
    assign IQ_free_slots = 6'd32 - count;
    
    // Unpack FIQ_in - extract valid bits and data
    wire [5:0] Enq_valid;
    wire [64:0] FIQ_0, FIQ_1, FIQ_2, FIQ_3, FIQ_4, FIQ_5;
    
    assign Enq_valid[0] = FIQ_in[65];      
    assign FIQ_0        = FIQ_in[64:0];    
    
    assign Enq_valid[1] = FIQ_in[131];     
    assign FIQ_1        = FIQ_in[130:66];  
    
    assign Enq_valid[2] = FIQ_in[197];     
    assign FIQ_2        = FIQ_in[196:132]; 
    
    assign Enq_valid[3] = FIQ_in[263];     
    assign FIQ_3        = FIQ_in[262:198]; 
    
    assign Enq_valid[4] = FIQ_in[329];     
    assign FIQ_4        = FIQ_in[328:264]; 
    
    assign Enq_valid[5] = FIQ_in[395];     
    assign FIQ_5        = FIQ_in[394:330]; 
    
    // Count how many valid instructions to enqueue
    wire [2:0] num_enqueue = Enq_valid[0] + Enq_valid[1] + Enq_valid[2] + 
                             Enq_valid[3] + Enq_valid[4] + Enq_valid[5];
    
    // Calculate how many to dispatch (clamped properly)
    wire [2:0] num_available = (count >= 6'd4) ? 3'd4 : count[2:0];
    wire [2:0] downstream_limit = (RS_slots >= 3'd4) ? 3'd4 : RS_slots;
    wire [2:0] Num_to_issue = (num_available < downstream_limit) ? num_available : downstream_limit;
    
    // Calculate tail offsets for each instruction
    wire [2:0] offset_0 = 3'd0;
    wire [2:0] offset_1 = offset_0 + (Enq_valid[0] ? 3'd1 : 3'd0);
    wire [2:0] offset_2 = offset_1 + (Enq_valid[1] ? 3'd1 : 3'd0);
    wire [2:0] offset_3 = offset_2 + (Enq_valid[2] ? 3'd1 : 3'd0);
    wire [2:0] offset_4 = offset_3 + (Enq_valid[3] ? 3'd1 : 3'd0);
    wire [2:0] offset_5 = offset_4 + (Enq_valid[4] ? 3'd1 : 3'd0);
    
    // Read positions (use current head, before update)
    wire [4:0] read_pos_0 = head;
    wire [4:0] read_pos_1 = (head + 5'd1) & 5'h1F;
    wire [4:0] read_pos_2 = (head + 5'd2) & 5'h1F;
    wire [4:0] read_pos_3 = (head + 5'd3) & 5'h1F;
    
    // Enqueue and Dequeue Logic
    always @(posedge Clk) begin
        if (Reset || Flush) begin
            head <= 5'd0;
            tail <= 5'd0;
            count <= 6'd0;
            Issue_data <= 260'd0;
            for (i = 0; i < 32; i = i + 1) begin
                data[i] <= 65'h0;
            end
        end else begin
            // Enqueue valid instructions
            if (Enq_valid[0]) data[(tail + offset_0) & 5'h1F] <= FIQ_0;
            if (Enq_valid[1]) data[(tail + offset_1) & 5'h1F] <= FIQ_1;
            if (Enq_valid[2]) data[(tail + offset_2) & 5'h1F] <= FIQ_2;
            if (Enq_valid[3]) data[(tail + offset_3) & 5'h1F] <= FIQ_3;
            if (Enq_valid[4]) data[(tail + offset_4) & 5'h1F] <= FIQ_4;
            if (Enq_valid[5]) data[(tail + offset_5) & 5'h1F] <= FIQ_5;
            
            // Update pointers and count
            tail <= (tail + num_enqueue) & 5'h1F;
            head <= (head + Num_to_issue) & 5'h1F;
            count <= count + num_enqueue - Num_to_issue;
            
            // Register the output - read BEFORE updating head
            // This avoids the race condition
            Issue_data <= {
                (Num_to_issue >= 3'd4) ? data[read_pos_3] : 65'h0,
                (Num_to_issue >= 3'd3) ? data[read_pos_2] : 65'h0,
                (Num_to_issue >= 3'd2) ? data[read_pos_1] : 65'h0,
                (Num_to_issue >= 3'd1) ? data[read_pos_0] : 65'h0
            };
        end
    end
endmodule