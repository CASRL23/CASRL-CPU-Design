//module for multi issue rom for out of order tomasulos
module Multi_Issue_ROM(
    input wire [31:0] PC0, PC1, PC2, PC3,
    output reg [31:0] Instr0, Instr1, Instr2, Instr3
);

    // 32k words (128 KB)
    reg [31:0] mem [0:32767];

    // Initialize from external hex file
    initial begin
          $readmemh("program_86.mem", mem);
    end

    // Synchronous read (good for BRAM inference)
    always @(PC0, PC1, PC2, PC3) begin
        Instr0 <= mem[PC0 >> 2];   // word-aligned fetch
        Instr1 <= mem[PC1 >> 2];
        Instr2 <= mem[PC2 >> 2];
        Instr3 <= mem[PC3 >> 2];
    end
endmodule