`timescale 1ns / 1ps

module CPU_1(
    output wire Done,
    input  wire clk,
    input  wire Reset,
    input  wire UART_TXD_IN,
    output wire UART_RXD_OUT
);

    localparam integer CLK_HZ       = 100_000_000;
    localparam integer BAUD         = 9600;
    localparam integer CLKS_PER_BIT = CLK_HZ / BAUD;
    localparam integer GAP_CLKS     = CLK_HZ / 2;

    reg [25:0] heartbeat = 26'd0;
    always @(posedge clk) begin
        heartbeat <= heartbeat + 1'b1;
    end
    assign Done = heartbeat[25];

    // Keep these referenced so Vivado cannot warn/trim them in confusing ways.
    wire unused_inputs = Reset ^ UART_TXD_IN;

    function [7:0] msg_char;
        input [4:0] idx;
        begin
            case (idx)
                5'd0:  msg_char = "U";
                5'd1:  msg_char = "A";
                5'd2:  msg_char = "R";
                5'd3:  msg_char = "T";
                5'd4:  msg_char = " ";
                5'd5:  msg_char = "O";
                5'd6:  msg_char = "K";
                5'd7:  msg_char = " ";
                5'd8:  msg_char = "9";
                5'd9:  msg_char = "6";
                5'd10: msg_char = "0";
                5'd11: msg_char = "0";
                5'd12: msg_char = 8'h0D;
                5'd13: msg_char = 8'h0A;
                default: msg_char = 8'h00;
            endcase
        end
    endfunction

    localparam ST_LOAD  = 3'd0;
    localparam ST_START = 3'd1;
    localparam ST_DATA  = 3'd2;
    localparam ST_STOP  = 3'd3;
    localparam ST_NEXT  = 3'd4;
    localparam ST_GAP   = 3'd5;

    reg [2:0]  state = ST_LOAD;
    reg [31:0] baud_count = 32'd0;
    reg [31:0] gap_count = 32'd0;
    reg [4:0]  char_index = 5'd0;
    reg [2:0]  bit_index = 3'd0;
    reg [7:0]  tx_byte = 8'h00;
    reg        tx_line = 1'b1;

    assign UART_RXD_OUT = tx_line ^ unused_inputs ^ unused_inputs;

    always @(posedge clk) begin
        case (state)
            ST_LOAD: begin
                tx_line <= 1'b1;
                tx_byte <= msg_char(char_index);
                baud_count <= 32'd0;
                bit_index <= 3'd0;

                if (msg_char(char_index) == 8'h00) begin
                    char_index <= 5'd0;
                    gap_count <= 32'd0;
                    state <= ST_GAP;
                end else begin
                    state <= ST_START;
                end
            end

            ST_START: begin
                tx_line <= 1'b0;
                if (baud_count == CLKS_PER_BIT - 1) begin
                    baud_count <= 32'd0;
                    state <= ST_DATA;
                end else begin
                    baud_count <= baud_count + 1'b1;
                end
            end

            ST_DATA: begin
                tx_line <= tx_byte[bit_index];
                if (baud_count == CLKS_PER_BIT - 1) begin
                    baud_count <= 32'd0;
                    if (bit_index == 3'd7) begin
                        bit_index <= 3'd0;
                        state <= ST_STOP;
                    end else begin
                        bit_index <= bit_index + 1'b1;
                    end
                end else begin
                    baud_count <= baud_count + 1'b1;
                end
            end

            ST_STOP: begin
                tx_line <= 1'b1;
                if (baud_count == CLKS_PER_BIT - 1) begin
                    baud_count <= 32'd0;
                    state <= ST_NEXT;
                end else begin
                    baud_count <= baud_count + 1'b1;
                end
            end

            ST_NEXT: begin
                char_index <= char_index + 1'b1;
                state <= ST_LOAD;
            end

            ST_GAP: begin
                tx_line <= 1'b1;
                if (gap_count == GAP_CLKS - 1) begin
                    gap_count <= 32'd0;
                    state <= ST_LOAD;
                end else begin
                    gap_count <= gap_count + 1'b1;
                end
            end

            default: begin
                state <= ST_LOAD;
            end
        endcase
    end

endmodule
