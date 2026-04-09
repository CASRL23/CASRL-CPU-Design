module Seg_Decoder (
    output wire [7:0] Segment,  
    output wire [7:0] Anode,    
    input wire [31:0] Data_in,   
    input wire Clk              
);

// Internal Registers
reg [7:0] Segment_reg = 8'b11111111;
reg [7:0] Anode_reg = 8'b11111110;

reg [3:0] Digit_value;
reg [3:0] Ones;
reg [3:0] Tens;
reg [3:0] Hundreds;
reg [3:0] Thousands;
reg [3:0] TenThousands;
reg [3:0] HundredThousands;
reg [3:0] Millions;
reg [3:0] TenMillions;

reg [15:0] Refresh_counter = 0;
reg [2:0] Digit_index = 0;

// Extract ones and tens from Data_in
always @(Data_in) begin
    Ones = Data_in % 10;
    Tens = (Data_in / 10) % 10;
    Hundreds = (Data_in / 100) % 10;
    Thousands = (Data_in / 1000) % 10;
    TenThousands = (Data_in / 10000) % 10;
    HundredThousands = (Data_in / 100000) % 10;
    Millions = (Data_in / 1000000) % 10;
    TenMillions = Data_in / 10000000;
end

// Refresh counter to slow down multiplexing (~1kHz)
always @(posedge Clk) begin
    Refresh_counter <= Refresh_counter + 1;

    if (Refresh_counter == 0) begin
        Digit_index <= Digit_index + 1;
    end
end

// Digit select and data output
always @(posedge Clk) begin
    case (Digit_index)
        3'd0: begin
            Anode_reg <= 8'b11111110;  
            Digit_value <= Ones;
        end
        3'd1: begin
            Anode_reg <= 8'b11111101;  
            Digit_value <= Tens;
        end
        3'd10: begin
            Anode_reg <= 8'b11111011; 
            Digit_value <= Hundreds;
        end
        3'd11: begin
            Anode_reg <= 8'b11110111; 
            Digit_value <= Thousands;
        end
        3'd100: begin
            Anode_reg <= 8'b11101111; 
            Digit_value <= TenThousands;
        end
        3'd101: begin
            Anode_reg <= 8'b11011111; 
            Digit_value <= HundredThousands;
        end
        3'd110: begin
            Anode_reg <= 8'b10111111; 
            Digit_value <= Millions;
        end
        3'd111: begin
            Anode_reg <= 8'b01111111; 
            Digit_value <= TenMillions;
        end
        default: begin
            Anode_reg <= 8'b11111111;  // All off
            Digit_value <= 4'd0;
        end
    endcase

    case (Digit_value)
        4'd0: Segment_reg <= 8'b11000000;
        4'd1: Segment_reg <= 8'b11111001;
        4'd2: Segment_reg <= 8'b10100100;
        4'd3: Segment_reg <= 8'b10110000;
        4'd4: Segment_reg <= 8'b10011001;
        4'd5: Segment_reg <= 8'b10010010;
        4'd6: Segment_reg <= 8'b10000010;
        4'd7: Segment_reg <= 8'b11111000;
        4'd8: Segment_reg <= 8'b10000000;
        4'd9: Segment_reg <= 8'b10010000;
        default: Segment_reg <= 8'b11111111; // All segments off
    endcase
end

// Output assignments
assign Segment = Segment_reg;
assign Anode = Anode_reg;

endmodule