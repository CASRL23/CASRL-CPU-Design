module DE_pipeline (
    output reg [166:0] dout,
    input wire Clk, Reset, en,
    input wire [166:0] din
);

    always @(posedge Clk or posedge Reset) begin
        if (Reset)
            dout <= 167'b0;
        else if (en)
            dout <= din;
    end
endmodule
