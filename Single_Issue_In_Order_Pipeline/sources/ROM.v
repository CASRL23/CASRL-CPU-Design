module ROM(
    output reg [31:0] Instruction,
    input  wire [31:0] Pc
);

    // 32k words (128 KB)
    reg [31:0] mem [0:32767];

    initial begin
        $readmemh("simple_add.mem", mem);
    end
    
    // Synchronous read (good for block RAM inference)
    always @(Pc) begin
        Instruction <= mem[Pc >> 2];  // word aligned
    end

endmodule
