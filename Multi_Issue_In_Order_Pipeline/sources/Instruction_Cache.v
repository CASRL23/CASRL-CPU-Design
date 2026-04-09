`define TAG 31:11      // 21 bits for tag 
`define INDEX 10:2     // 9 bits for index 

module Instruction_Cache
#(
  // Cache parameters
  parameter SIZE = 32*512*2,       // 4 KB
  parameter NWAYS = 2,
  parameter NSETS = 512,           
  parameter BLOCK_SIZE = 32,
  parameter WIDTH = 32,
  parameter MWIDTH = 32,		
  parameter INDEX_WIDTH = 9,
  parameter TAG_WIDTH = 21
)
(
  input  wire                      clock,
  input  wire                      reset,
  input  wire                      Stall,
  input  wire [WIDTH-1:0]          address,    // address from CPU
  output wire                      hit_miss,   // 1 if hit, 0 while handling miss
  output wire [WIDTH-1:0]          q,          // data from cache to CPU
  output wire [WIDTH-1:0]          q_address,  // PC corresponding to q output
  output wire [WIDTH-1:0]          mrdaddress, // memory read address
  output wire                      mrden,      // read enable, 1 if reading from memory
  input  wire [MWIDTH-1:0]         mq          // data coming from memory
);

// WAY 1 cache data
reg					valid1 [0:NSETS-1];
reg					lru1   [0:NSETS-1];
reg [TAG_WIDTH-1:0]	tag1   [0:NSETS-1];
(* ram_style = "block" *) reg [MWIDTH-1:0] mem1 [0:NSETS-1];
// WAY 2 cache data
reg					valid2 [0:NSETS-1];
reg					lru2   [0:NSETS-1];
reg [TAG_WIDTH-1:0]	tag2   [0:NSETS-1];
(* ram_style = "block" *) reg [MWIDTH-1:0] mem2 [0:NSETS-1];

integer k;

// internal registers
reg					_hit_miss = 1'b0;
reg					_mrden = 1'b0;
reg [WIDTH-1:0]		_q = {WIDTH{1'b0}};
reg [WIDTH-1:0]		_q_address = {WIDTH{1'b0}};

// output assignments
assign hit_miss = _hit_miss;
assign mrden = !((valid1[address[`INDEX]] && (tag1[address[`INDEX]] == address[`TAG]))
			  || (valid2[address[`INDEX]] && (tag2[address[`INDEX]] == address[`TAG])));
			  
assign mrdaddress = {address[`TAG],address[`INDEX],2'b00};
assign q = _q;
assign q_address = _q_address;

// state parameters
parameter idle = 1'b0;		// receive requests from CPU 
parameter miss = 1'b1;	    // miss state: request memory data

// state register
reg currentState = idle;

always @(posedge clock)
begin
    if (reset) begin
        currentState <= idle;
        _hit_miss <= 0;
        _q <= 0;
        _q_address <= 0;
        for(k = 0; k < NSETS; k = k +1)
        begin
            valid1[k] = 0;
            valid2[k] = 0;
            lru1[k] = 0;
            lru2[k] = 0;
        end
    end
    else begin  
        if (!Stall) begin
            case (currentState)
                idle: begin
                    // Set hit_miss for the current address
                    _hit_miss <= ((valid1[address[`INDEX]] && (tag1[address[`INDEX]] == address[`TAG]))
                              ||  (valid2[address[`INDEX]] && (tag2[address[`INDEX]] == address[`TAG])));
                
                    // check way 1 hit
                    if(valid1[address[`INDEX]] && (tag1[address[`INDEX]] == address[`TAG]))
                    begin
                        _q <= mem1[address[`INDEX]];
                        _q_address <= address;
                        // update LRU data
                        lru1[address[`INDEX]] <= 0;
                        lru2[address[`INDEX]] <= 1;
                        currentState <= idle;
                    end
                    
                    // check way 2 hit
                    else if(valid2[address[`INDEX]] && (tag2[address[`INDEX]] == address[`TAG]))
                    begin
                        _q <= mem2[address[`INDEX]];
                        _q_address <= address;
                        // update LRU data
                        lru1[address[`INDEX]] <= 1;
                        lru2[address[`INDEX]] <= 0;
                        currentState <= idle;
                    end
                    
                    // miss
                    else begin
                        currentState <= miss;
                    end
                end 
            
                miss: begin
                    // Both ways invalid - fill way 1
                    if(~valid1[address[`INDEX]] && ~valid2[address[`INDEX]])
                    begin
                        mem1[address[`INDEX]] <= mq;
                        tag1[address[`INDEX]] <= address[`TAG];
                        valid1[address[`INDEX]] <= 1;
                        lru1[address[`INDEX]] <= 0;
                        lru2[address[`INDEX]] <= 1;
                    end
                    
                    // Only way 1 invalid - fill way 1
                    else if(~valid1[address[`INDEX]])
                    begin
                        mem1[address[`INDEX]] <= mq;
                        tag1[address[`INDEX]] <= address[`TAG];
                        valid1[address[`INDEX]] <= 1;
                        lru1[address[`INDEX]] <= 0;
                        lru2[address[`INDEX]] <= 1;
                    end
                    
                    // Only way 2 invalid - fill way 2
                    else if(~valid2[address[`INDEX]])
                    begin
                        mem2[address[`INDEX]] <= mq;
                        tag2[address[`INDEX]] <= address[`TAG];
                        valid2[address[`INDEX]] <= 1;
                        lru1[address[`INDEX]] <= 1;
                        lru2[address[`INDEX]] <= 0;
                    end
                    
                    // Both valid - replace based on LRU
                    // Replace way 1 (LRU)
                    else if(lru1[address[`INDEX]] == 1)
                    begin
                        mem1[address[`INDEX]] <= mq;
                        tag1[address[`INDEX]] <= address[`TAG];
                        lru1[address[`INDEX]] <= 0;
                        lru2[address[`INDEX]] <= 1;
                    end
                    
                    // Replace way 2 (LRU)
                    else
                    begin
                        mem2[address[`INDEX]] <= mq;
                        tag2[address[`INDEX]] <= address[`TAG];
                        lru1[address[`INDEX]] <= 1;
                        lru2[address[`INDEX]] <= 0;
                    end
                
                    currentState <= idle;
                end 
        
                default: currentState <= idle;
        
            endcase
        end
    end    
end
endmodule