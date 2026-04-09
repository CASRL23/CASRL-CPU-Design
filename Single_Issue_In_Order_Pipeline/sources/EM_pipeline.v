module EM_pipeline (
    output reg [179:0] dout,
    input wire Clk, Reset, en,
    input wire [179:0] din
);

    always @(posedge Clk or posedge Reset) begin
        if (Reset)
            dout <= 180'b0;
        else if (en)
            dout <= din;
    end
endmodule
