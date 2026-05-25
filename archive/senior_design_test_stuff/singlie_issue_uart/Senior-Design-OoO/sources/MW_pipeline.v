module MW_pipeline (
    output reg [171:0] dout,
    input wire Clk, Reset, en,
    input wire [171:0] din
);

    always @(posedge Clk or posedge Reset) begin
        if (Reset)
            dout <= 172'b0;
        else if (en)
            dout <= din;
    end
endmodule
