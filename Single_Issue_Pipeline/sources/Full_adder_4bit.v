//4 bit carrylookahead adder. takes in 2 4-bit values Op1 and Op2 as well as a single bit carryin
//outputs a 4 bit value Result and a single bit value cC_out for carrryout

module CLA_adder_4bit(
                    output wire [3:0] Result,
                    output wire C_out,
                    input wire [3:0] Op1, Op2, 
                    input wire C_in
);
                    
//wires for propogate and carry generate
wire g0, p0, g1, p1, g2, p2, g3, p3;
assign g0 = Op1[0] & Op2[0];
assign p0 = Op1[0] ^ Op2[0];
assign g1 = Op1[1] & Op2[1];
assign p1 = Op1[1] ^ Op2[1];
assign g2 = Op1[2] & Op2[2];
assign p2 = Op1[2] ^ Op2[2];
assign g3 = Op1[3] & Op2[3];
assign p3 = Op1[3] ^ Op2[3];

//assignments for carryout
wire c1, c2, c3;
assign c1 = (C_in & p0) | g0;
assign c2 = (C_in & p1 & p0) | (g0 & p1) | g1;
assign c3 = (C_in & p2 & p1 & p0) | (g0 & p2 & p1) | (g1 & p2) | g2;


//assignments for outputs sum and carryout
assign C_out = (C_in & p3 & p2 & p1 & p0) | (g0 & p3 & p2 & p1) | (p3 & p2 & g1) | (g2 & p3) | g3;
assign Result[0] = p0 ^ C_in;
assign Result[1] = p1 ^ c1;
assign Result[2] = p2 ^ c2;
assign Result[3] = p3 ^ c3;

endmodule