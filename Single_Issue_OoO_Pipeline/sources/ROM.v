module ROM(
    output reg [31:0] Instruction,
    input  wire [31:0] Pc
);

    // 32k words (128 KB)
    reg [31:0] mem [0:32767];

    // Initialize from external hex file
//    `ifdef SIMULATION
    initial begin
        $readmemh("program.mem", mem);
    end
//    `endif
    
    // Synchronous read (good for block RAM inference)
    always @(Pc) begin
        Instruction <= mem[Pc >> 2];  // word aligned
    end

//    always @(*) begin
//        case (Pc >> 2)   // word-aligned addressing
//            32'd0: Instruction = 32'h00500093; // addi x1, x0, 5
//            32'd1: Instruction = 32'h00500113; // addi x2, x0, 5
//            32'd2: Instruction = 32'h00000193; // addi x3, x0, 0
//            32'd3: Instruction = 32'h00210463; // beq  x2, x0, done
//            32'd4: Instruction = 32'h001181b3; // add  x3, x3, x1
//            32'd5: Instruction = 32'hfff10113; // addi x2, x2, -1
//            32'd6: Instruction = 32'hff5ff06f; // jal  x0, loop
//             add more instructions here if needed
//            default: Instruction = 32'h00000000; // NOP
//        endcase
//    end


endmodule



////This module holds the Rom. Takes in the program counter and outputs the instruction
//module ROM(
//    output reg [31:0] Instruction,
//    input wire [31:0] Pc
//);
    
////memory addresses, 2^15 32 bit values
//reg [31:0] ROM [0:32767];

//initial begin
//    // Add Numbers to Registers
//    ROM[0]  = 32'h00500093; // addi x1, x0, 5
//    ROM[1]  = 32'h00a00113; // addi x2, x0, 10
//    ROM[2]  = 32'h00f00193; // addi x3, x0, 15
//    ROM[3]  = 32'h02000213; // addi x4, x0, 32 (base addr in memory)

//    // Store into Memory
//    ROM[4]  = 32'h00122023; // sw x1, 0(x4)   ; MEM[32]  = 5
//    ROM[5]  = 32'h00222223; // sw x2, 4(x4)   ; MEM[36]  = 10
//    ROM[6]  = 32'h00322423; // sw x3, 8(x4)   ; MEM[40]  = 15

//    // Load Values from Memory
//    ROM[7]  = 32'h00022683; // lw x13, 0(x4)  ; x13 = 5
//    ROM[8]  = 32'h00422703; // lw x14, 4(x4)  ; x14 = 10
//    ROM[9]  = 32'h00822783; // lw x15, 8(x4)  ; x15 = 15

//    // Load Values
//    ROM[10] = 32'h00e687b3; // add x15, x13, x14 ; 5 + 10 = 15
//    ROM[11] = 32'h00f78733; // add x14, x15, x15 ; 15 + 15 = 30

//    // Load-Use hazard
//    ROM[12] = 32'h00022783; // lw x15, 0(x4)     ; load again = 5
//    ROM[13] = 32'h00e78733; // add x14, x15, x14 ; uses loaded x15 immediately

//    // Begin Branch Testing
//    ROM[14] = 32'h00100893; // addi x17, x0, 1
//    ROM[15] = 32'h00100913; // addi x18, x0, 1
//    ROM[16] = 32'h01288863; // beq x17, x18, +16 ; jump to ROM[20]

//    ROM[17] = 32'h06400993; // addi x19, x0, 100 ; skipped if branch taken
//    ROM[18] = 32'h06400a13; // addi x20, x0, 100 ; skipped if branch taken

//    ROM[19] = 32'h00200893; // addi x17, x0, 2 ; landed here

//    // --- Branch if not equal (BNE) ---
//    ROM[20] = 32'h00100a93; // addi x21, x0, 1
//    ROM[21] = 32'h00300b13; // addi x22, x0, 3
//    ROM[22] = 32'h016a9663; // bne  x21, x22, +12 ; jump to ROM[25]

//    ROM[23] = 32'h06400b93; // addi x23, x0, 100 ; skipped if taken

//    ROM[24] = 32'h00400a93; // addi x21, x0, 4  

//    // --- Branch less than (BLT) ---
//    ROM[25] = 32'h00500c13; // addi x24, x0, 5
//    ROM[26] = 32'h00a00c93; // addi x25, x0, 10
//    ROM[27] = 32'h019c4663; // blt  x24, x25, +12 ; should take branch

//    ROM[28] = 32'h06400d13; // addi x26, x0, 100 ; skipped

//    ROM[29] = 32'h00f00c13; // addi x24, x0, 15

//    // --- Branch greater/equal (BGE) ---
//    ROM[30] = 32'h00a00d93; // addi x27, x0, 10
//    ROM[31] = 32'h00500e13; // addi x28, x0, 5
//    ROM[32] = 32'h01cdd863; // bge x27, x28, +16 ; taken, skip next 3 instrs

//    ROM[33] = 32'h06400e93; // addi x29, x0, 100 ; skipped
//    ROM[34] = 32'h06400f13; // addi x30, x0, 100 ; skipped

//    ROM[35] = 32'h00b00e93; // addi x29, x0, 11

//    // --- Jump and link (JAL) ---
//    ROM[37] = 32'h008000ef; // jal x1, +8 ; x1=PC+4, jump to ROM[39]
//    ROM[38] = 32'h06400f13; // addi x30, x0, 100 ; skipped
//    ROM[39] = 32'h00100193; // addi x3, x0, 1

//    // --- Jump and link register (JALR) ---
//    ROM[40] = 32'h02800293; // addi x5, x0, 40
//    ROM[41] = 32'h000280e7; // jalr x1, 0(x5) ; x1=PC+4, jump to ROM[40] (loop)
//end

//always @(Pc) begin
//    Instruction = ROM[Pc>>2];
//end
//endmodule