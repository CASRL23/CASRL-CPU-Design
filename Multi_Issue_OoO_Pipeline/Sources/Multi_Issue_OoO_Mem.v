//module for multi issue out of order memory stage. holds lsq, dcache, and ram
module Multi_Issue_OoO_Mem(
    input wire Clk, Reset, Valid_mem,
    input wire [2:0] Mem_type,
    input wire [6:0] Dest_tag_in,
    input wire [31:0] Data_in, Addr_in,
    
    output wire [31:0] Data_out,
    output reg [6:0] Dest_tag_out,
    output reg Mem_busy, Valid_CDB_write 
);

//registers for connecting to RAM
reg Byte, Half, Word, Store, Unsigned;

//instantiate RAM
RAM MIOOORAM(.Clk(Clk), .Store(Store), .Data_in(Data_in), .Address(Addr_in), 
    .Data_out(Data_out), .Byte(Byte), .Half(Half), .Word(Word), .Unsigned(Unsigned));

//assigning values for each of the wires
always @(Valid_mem, Mem_type, Dest_tag_in, Data_in, Addr_in) begin
    //mem busy is 0 until i get LSQ and/or cache implemented
    Mem_busy <= 1'b0;
    
    Dest_tag_out <= Dest_tag_in;
    Valid_CDB_write <= (Mem_type < 4'd5 && Valid_mem);
    
    //decode signals
    case(Mem_type)
        //0 is a load byte, byte is 1, everything else is 0
        3'd0: begin
            Store <= 1'b0;
            Unsigned <= 1'b0;
            Byte <= 1'b1;
            Half <= 1'b0;
            Word <= 1'b0;
        end
        //1  is load half, only half is high
        3'd1: begin
            Store <= 1'b0;
            Unsigned <= 1'b0;
            Byte <= 1'b0;
            Half <= 1'b1;
            Word <= 1'b0;            
        end
        //2 is load word, only word is high
        3'd2: begin
            Store <= 1'b0;
            Unsigned <= 1'b0;
            Byte <= 1'b0;
            Half <= 1'b0;
            Word <= 1'b1;
        end
        //3 is load byte unsigned
        3'd3: begin
            Store <= 1'b0;
            Unsigned <= 1'b1;
            Byte <= 1'b1;
            Half <= 1'b0;
            Word <= 1'b0;
        end        
        //4 is load half unsigned
        3'd4: begin
            Store <= 1'b0;
            Unsigned <= 1'b1;
            Byte <= 1'b0;
            Half <= 1'b1;
            Word <= 1'b0;
        end        
        //5 is store byte
        3'd5: begin
            Store <= 1'b1;
            Unsigned <= 1'b0;
            Byte <= 1'b0;
            Half <= 1'b0;
            Word <= 1'b0;
        end        
        //6 is store half
        3'd6: begin
            Store <= 1'b1;
            Unsigned <= 1'b0;
            Byte <= 1'b0;
            Half <= 1'b1;
            Word <= 1'b0;
        end        
        //7 is store word
        3'd7: begin
            Store <= 1'b1;
            Unsigned <= 1'b0;
            Byte <= 1'b0;
            Half <= 1'b0;
            Word <= 1'b1;
        end              
        //default- everything is invalid
        default: begin
            Store <= 1'b0;
            Unsigned <= 1'b0;
            Byte <= 1'b0;
            Half <= 1'b0;
            Word <= 1'b0;
        end          
    endcase
end
endmodule