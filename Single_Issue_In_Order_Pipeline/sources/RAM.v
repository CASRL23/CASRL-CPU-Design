module RAM(
    output reg [31:0] Data_out,
    input  wire [31:0] Data_in, Address,
    input  wire Store, Clk,
    input  wire Byte, Half, Word, Unsigned
);

    // 32K words = 128 KB RAM
    reg [31:0] RAM [0:32767];
    reg [31:0] temp;

    // sync write
    always @(posedge Clk) begin
        if (Store) begin
            temp = RAM[Address >> 2];  // grab old word

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

            RAM[Address >> 2] <= temp;
        end
    end
    
    reg [31:0] word;
    // asynchronous read
    always @(Address or Word or Half or Byte or Unsigned) begin
        word = RAM[Address >> 2];

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

endmodule
