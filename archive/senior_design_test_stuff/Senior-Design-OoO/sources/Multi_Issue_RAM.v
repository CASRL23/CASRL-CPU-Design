module Multi_Issue_RAM(
    output reg [31:0] Data_out0, Data_out1, Data_out2, Data_out3,
    input  wire [31:0] Data_in0, Data_in1, Data_in2, Data_in3, 
    input  wire [31:0] Address0, Address1, Address2, Address3,
    input  wire Store0, Store1, Store2, Store3, 
    input  wire Load0, Load1, Load2, Load3, 
    input  wire Clk,
    input  wire Byte0, Byte1, Byte2, Byte3, 
    input  wire Half0, Half1, Half2, Half3, 
    input  wire Word0, Word1, Word2, Word3, 
    input  wire Unsigned0, Unsigned1, Unsigned2, Unsigned3,
    
    output wire [7:0] UART_TX_Byte,
    output wire UART_transmit_signal,
    input wire [31:0] UART_RX_Byte,
    input wire [31:0] UART_status
    
);

    localparam UART_RX_ADDRESS = 8'h00;
    localparam UART_TX_ADDRESS = 8'h01;
    localparam UART_TRANSMIT_SIGNAL_ADDRESS = 8'h02;
    localparam UART_STATUS_ADDRESS = 8'h03;

    // 32K words = 128 KB RAM
    reg [31:0] RAM [0:16383];
    
    // Select which address to look at
    wire [31:0] active_address = (Store3 || Load3) ? Address3 : (Store2 || Load2) ? Address2 : (Store1 || Load1) ? Address1 : (Store0 || Load0) ? Address0 : 32'b0;
                               
    wire [31:0] active_data_in = Store3 ? Data_in3 : Store2 ? Data_in2 : Store1 ? Data_in1 : Data_in0;
    
    wire active_store = Store0 || Store1 || Store2 || Store3;
    wire active_load = Load0 || Load1 || Load2 || Load3;
    
    wire active_byte = (Store3 || Load3) ? Byte3 : (Store2 || Load2) ? Byte2 : (Store1 || Load1) ? Byte1 : (Store0 || Load0) ? Byte0 : 1'b0;
    wire active_half = (Store3 || Load3) ? Half3 : (Store2 || Load2) ? Half2 : (Store1 || Load1) ? Half1 : (Store0 || Load0) ? Half0 : 1'b0;
    wire active_word = (Store3 || Load3) ? Word3 : (Store2 || Load2) ? Word2 : (Store1 || Load1) ? Word1 : (Store0 || Load0) ? Word0 : 1'b0;
    wire active_unsigned = Load3 ? Unsigned3 : Load2 ? Unsigned2 : Load1 ? Unsigned1 : Unsigned0;
    
    // Synchronous write
    reg [31:0] temp;
    always @(posedge Clk) begin
        if (active_store) begin
            temp = RAM[active_address[16:2]];  // grab old word
            if (active_word) begin
                temp = active_data_in;
            end 
            else if (active_half) begin
                if (active_address[1])
                    temp[31:16] = active_data_in[15:0];
                else
                    temp[15:0] = active_data_in[15:0];
            end 
            else if (active_byte) begin
                case (active_address[1:0])
                    2'b00: temp[7:0]   = active_data_in[7:0];
                    2'b01: temp[15:8]  = active_data_in[7:0];
                    2'b10: temp[23:16] = active_data_in[7:0];
                    2'b11: temp[31:24] = active_data_in[7:0];
                endcase
            end
            RAM[active_address[16:2]] <= temp;
        end
        else begin
            RAM[UART_RX_ADDRESS] <= UART_RX_Byte;
            RAM[UART_STATUS_ADDRESS] <= UART_status;
        end
    end
    
    // Asynchronous read
    reg [31:0] word;
    reg [31:0] read_result;
    
    always @(active_load, active_address, active_word, active_half, active_byte, active_unsigned,
             Load0, Load1, Load2, Load3) begin
        // Compute read result
        if (active_load) begin
            word = RAM[active_address[16:2]];
            if (active_word) begin
                read_result = word;
            end 
            else if (active_half) begin
                if (active_address[1]) begin
                    if (active_unsigned)
                        read_result = {16'b0, word[31:16]};
                    else
                        read_result = {{16{word[31]}}, word[31:16]};
                end else begin
                    if (active_unsigned)
                        read_result = {16'b0, word[15:0]};
                    else
                        read_result = {{16{word[15]}}, word[15:0]};
                end
            end 
            else if (active_byte) begin
                case (active_address[1:0])
                    2'b00: read_result = active_unsigned ? {24'b0, word[7:0]}   : {{24{word[7]}},   word[7:0]};
                    2'b01: read_result = active_unsigned ? {24'b0, word[15:8]}  : {{24{word[15]}},  word[15:8]};
                    2'b10: read_result = active_unsigned ? {24'b0, word[23:16]} : {{24{word[23]}},  word[23:16]};
                    2'b11: read_result = active_unsigned ? {24'b0, word[31:24]} : {{24{word[31]}},  word[31:24]};
                endcase
            end 
            else begin
                read_result = 32'b0;
            end
        end else begin
            read_result = 32'b0;
        end
        
        // Route to correct output
        Data_out0 = Load0 ? read_result : 32'b0;
        Data_out1 = Load1 ? read_result : 32'b0;
        Data_out2 = Load2 ? read_result : 32'b0;
        Data_out3 = Load3 ? read_result : 32'b0;
    end

    assign UART_TX_Byte = RAM[UART_TX_ADDRESS];
    assign UART_transmit_signal = RAM[UART_TRANSMIT_SIGNAL_ADDRESS];

endmodule