module RAM(
    output reg [31:0] Data_out,
    input  wire [31:0] Data_in, Address,
    input  wire Store, Clk,
    input  wire Byte, Half, Word, Unsigned,
    
    // UART interface
    output wire [7:0] UART_TX_Byte,
    output wire UART_transmit_signal,
    input wire [7:0] UART_RX_Byte,
    input wire [31:0] UART_status
);
    // UART memory-mapped word indexes. CPU byte addresses are index << 2.
    // RX=0x00, TX=0x04, TX strobe=0x08, status=0x0C.
    localparam UART_RX_ADDRESS = 8'h00;
    localparam UART_TX_ADDRESS = 8'h01;
    localparam UART_TRANSMIT_SIGNAL_ADDRESS = 8'h02;
    localparam UART_STATUS_ADDRESS = 8'h03;

    // 32K words = 128 KB RAM
    reg [31:0] RAM [0:32767];
    
    // UART registers (separate from RAM)
    reg [31:0] UART_RX_reg;
    reg [31:0] UART_TX_reg;
    reg [31:0] UART_TRANSMIT_SIGNAL_reg;
    reg [31:0] UART_STATUS_reg;
    
    reg [31:0] temp;

    initial begin
        UART_RX_reg = 32'h00000000;
        UART_TX_reg = 32'h00000000;
        UART_TRANSMIT_SIGNAL_reg = 32'h00000000;
        UART_STATUS_reg = 32'h00000000;
        temp = 32'h00000000;
    end
    
    // Synchronous write
    always @(posedge Clk) begin
        // Update UART input registers every cycle
        UART_RX_reg <= {24'h0, UART_RX_Byte};
        UART_STATUS_reg <= UART_status;
        UART_TRANSMIT_SIGNAL_reg <= 32'h00000000;
        
        if (Store) begin
            // Check if writing to UART addresses
            if (Address[16:2] == UART_TX_ADDRESS) begin
                UART_TX_reg <= Data_in;
            end
            else if (Address[16:2] == UART_TRANSMIT_SIGNAL_ADDRESS) begin
                UART_TRANSMIT_SIGNAL_reg <= Data_in;
            end
            else begin
                // Regular RAM write
                temp = RAM[Address[16:2]];  // Use [16:2] like multi-issue
                if (Word) begin
                    temp = Data_in;
                end 
                else if (Half) begin
                    if (Address[1])
                        temp[31:16] = Data_in[15:0];
                    else
                        temp[15:0]  = Data_in[15:0];
                end 
                else if (Byte) begin
                    case (Address[1:0])
                        2'b00: temp[7:0]   = Data_in[7:0];
                        2'b01: temp[15:8]  = Data_in[7:0];
                        2'b10: temp[23:16] = Data_in[7:0];
                        2'b11: temp[31:24] = Data_in[7:0];
                    endcase
                end
                RAM[Address[16:2]] <= temp;
            end
        end
    end
    
    // Asynchronous read
    reg [31:0] word;
    always @(*) begin
        // Check if reading from UART addresses
        if (Address[16:2] == UART_RX_ADDRESS) begin
            word = UART_RX_reg;
        end
        else if (Address[16:2] == UART_STATUS_ADDRESS) begin
            word = UART_STATUS_reg;
        end
        else if (Address[16:2] == UART_TX_ADDRESS) begin
            word = UART_TX_reg;
        end
        else if (Address[16:2] == UART_TRANSMIT_SIGNAL_ADDRESS) begin
            word = UART_TRANSMIT_SIGNAL_reg;
        end
        else begin
            word = RAM[Address[16:2]]; 
        end
        
        // Format output based on access type
        if (Word) begin
            Data_out = word;
        end 
        else if (Half) begin
            if (Address[1]) begin
                if (Unsigned)
                    Data_out = {16'b0, word[31:16]};
                else
                    Data_out = {{16{word[31]}}, word[31:16]};
            end else begin
                if (Unsigned)
                    Data_out = {16'b0, word[15:0]};
                else
                    Data_out = {{16{word[15]}}, word[15:0]};
            end
        end 
        else if (Byte) begin
            case (Address[1:0])
                2'b00: Data_out = Unsigned ? {24'b0, word[7:0]}   : {{24{word[7]}},   word[7:0]};
                2'b01: Data_out = Unsigned ? {24'b0, word[15:8]}  : {{24{word[15]}},  word[15:8]};
                2'b10: Data_out = Unsigned ? {24'b0, word[23:16]} : {{24{word[23]}},  word[23:16]};
                2'b11: Data_out = Unsigned ? {24'b0, word[31:24]} : {{24{word[31]}},  word[31:24]};
            endcase
        end 
        else begin
            Data_out = 32'b0;
        end
    end
    
    // Connect UART outputs
    assign UART_TX_Byte = UART_TX_reg[7:0];
    assign UART_transmit_signal = UART_TRANSMIT_SIGNAL_reg[0];

endmodule
