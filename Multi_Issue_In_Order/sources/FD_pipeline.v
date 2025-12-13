module FD_pipeline (
    output reg [64:0] dout,
    input wire Clk, Reset, en,
    input wire [64:0] din
);

    always @(posedge Clk or posedge Reset) begin
        if (Reset)
            dout <= 65'b0;
        else if (en)
            dout <= din;
    end
endmodule
