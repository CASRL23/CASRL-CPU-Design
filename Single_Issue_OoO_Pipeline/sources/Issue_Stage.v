//module for issuing stage. 
//takes instructions from Iq or decode stage, and issues them to RS

module Issue_Stage#(
    parameter DATA_SIZE = 32,
    parameter TAG_SIZE = 7
)(
    input wire Clk, Reset, 
    input wire [DATA_SIZE-1:0] Vj_in, Vk_in,
    
    
    output reg [127:0] Ready_array
);


endmodule