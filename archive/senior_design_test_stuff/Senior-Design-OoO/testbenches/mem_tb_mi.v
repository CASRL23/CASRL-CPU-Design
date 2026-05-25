`timescale 1ns / 1ps

module tb_Multi_Issue_RAM;
    // Inputs
    reg Clk;
    reg [31:0] Data_in0, Data_in1, Data_in2, Data_in3;
    reg [31:0] Address0, Address1, Address2, Address3;
    reg Store0, Store1, Store2, Store3;
    reg Byte0, Byte1, Byte2, Byte3;
    reg Half0, Half1, Half2, Half3;
    reg Word0, Word1, Word2, Word3;
    reg Unsigned0, Unsigned1, Unsigned2, Unsigned3;
    
    // Outputs
    wire [31:0] Data_out0, Data_out1, Data_out2, Data_out3;
    
    // Instantiate the RAM
    Multi_Issue_RAM uut (
        .Clk(Clk),
        .Data_out0(Data_out0), .Data_out1(Data_out1), .Data_out2(Data_out2), .Data_out3(Data_out3),
        .Data_in0(Data_in0), .Data_in1(Data_in1), .Data_in2(Data_in2), .Data_in3(Data_in3),
        .Address0(Address0), .Address1(Address1), .Address2(Address2), .Address3(Address3),
        .Store0(Store0), .Store1(Store1), .Store2(Store2), .Store3(Store3),
        .Byte0(Byte0), .Byte1(Byte1), .Byte2(Byte2), .Byte3(Byte3),
        .Half0(Half0), .Half1(Half1), .Half2(Half2), .Half3(Half3),
        .Word0(Word0), .Word1(Word1), .Word2(Word2), .Word3(Word3),
        .Unsigned0(Unsigned0), .Unsigned1(Unsigned1), .Unsigned2(Unsigned2), .Unsigned3(Unsigned3)
    );
    
    // Clock generation
    initial Clk = 0;
    always #5 Clk = ~Clk;  // 10ns period (100MHz)
    
    initial begin
        // Initialize inputs
        Store0 = 0; Store1 = 0; Store2 = 0; Store3 = 0;
        Byte0 = 0; Byte1 = 0; Byte2 = 0; Byte3 = 0;
        Half0 = 0; Half1 = 0; Half2 = 0; Half3 = 0;
        Word0 = 0; Word1 = 0; Word2 = 0; Word3 = 0;
        Unsigned0 = 0; Unsigned1 = 0; Unsigned2 = 0; Unsigned3 = 0;
        Address0 = 0; Address1 = 0; Address2 = 0; Address3 = 0;
        Data_in0 = 0; Data_in1 = 0; Data_in2 = 0; Data_in3 = 0;
        
        #10;  // Wait for initial settling
        
        // Test 1: Write a full word to address 0x10 on port 0
        $display("=== Test 1: Write 0xDEADBEEF to address 0x10 ===");
        Address0 = 32'h0000_0010;
        Data_in0 = 32'hDEADBEEF;
        Word0 = 1; 
        Store0 = 1;
        #10; // Wait for clock edge to write
        Store0 = 0;  // Disable store
        #10; // Wait one more cycle
        
        // Test 2: Read back from same address on port 0
        $display("=== Test 2: Read from address 0x10 on port 0 ===");
        Address0 = 32'h0000_0010;
        Word0 = 1;  // IMPORTANT: Need to keep Word0=1 to read a word!
        #10;
        $display("Data_out0 = 0x%h (expected 0xDEADBEEF)", Data_out0);
        
        // Test 3: Read from same address on all other ports simultaneously
        $display("=== Test 3: Read from address 0x10 on all ports ===");
        Address1 = 32'h0000_0010; Word1 = 1;
        Address2 = 32'h0000_0010; Word2 = 1;
        Address3 = 32'h0000_0010; Word3 = 1;
        #10;
        $display("Data_out0 = 0x%h", Data_out0);
        $display("Data_out1 = 0x%h", Data_out1);
        $display("Data_out2 = 0x%h", Data_out2);
        $display("Data_out3 = 0x%h", Data_out3);
        
        // Test 4: Write different values to different addresses
        $display("=== Test 4: Write to multiple addresses ===");
        Address0 = 32'h0000_0020; Data_in0 = 32'hCAFEBABE; Word0 = 1; Store0 = 1;
        #10;
        Store0 = 0;
        #10;
        
        // Test 5: Read from multiple addresses simultaneously
        $display("=== Test 5: Read from different addresses on each port ===");
        Address0 = 32'h0000_0010; Word0 = 1;  // Should read DEADBEEF
        Address1 = 32'h0000_0020; Word1 = 1;  // Should read CAFEBABE
        Address2 = 32'h0000_0000; Word2 = 1;  // Should read 0 (uninitialized)
        Address3 = 32'h0000_0010; Word3 = 1;  // Should read DEADBEEF
        #10;
        $display("Data_out0 = 0x%h (expected 0xDEADBEEF)", Data_out0);
        $display("Data_out1 = 0x%h (expected 0xCAFEBABE)", Data_out1);
        $display("Data_out2 = 0x%h (expected 0x00000000)", Data_out2);
        $display("Data_out3 = 0x%h (expected 0xDEADBEEF)", Data_out3);
        
        // Test 6: Test byte operations
        $display("=== Test 6: Write byte to address 0x30 ===");
        Address0 = 32'h0000_0030; Data_in0 = 32'h000000AB; Byte0 = 1; Word0 = 0; Store0 = 1;
        #10;
        Store0 = 0;
        #10;
        
        Address0 = 32'h0000_0030; Byte0 = 1; Unsigned0 = 1;
        #10;
        $display("Data_out0 = 0x%h (expected 0x000000AB)", Data_out0);
        
        // Test 7: Test half-word operations
        $display("=== Test 7: Write half-word to address 0x40 ===");
        Address0 = 32'h0000_0040; Data_in0 = 32'h0000ABCD; Half0 = 1; Byte0 = 0; Store0 = 1;
        #10;
        Store0 = 0;
        #10;
        
        Address0 = 32'h0000_0040; Half0 = 1; Unsigned0 = 1;
        #10;
        $display("Data_out0 = 0x%h (expected 0x0000ABCD)", Data_out0);
        
        #20;
        $display("=== All tests complete ===");
        $finish;
    end
endmodule