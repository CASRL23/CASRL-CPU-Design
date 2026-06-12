`timescale 1ns / 1ps

module UART_BAUD_SWEEP_TOP(
    output wire Done,
    input  wire clk,
    input  wire Reset,
    input  wire UART_TXD_IN,
    output wire UART_RXD_OUT
);

    reg [25:0] heartbeat = 26'd0;
    always @(posedge clk) begin
        heartbeat <= heartbeat + 1'b1;
    end
    assign Done = heartbeat[25];

    wire unused_inputs = Reset ^ UART_TXD_IN;

    localparam ST_LOAD  = 3'd0;
    localparam ST_START = 3'd1;
    localparam ST_DATA  = 3'd2;
    localparam ST_STOP  = 3'd3;
    localparam ST_NEXT  = 3'd4;
    localparam ST_GAP   = 3'd5;

    reg [2:0]  state = ST_LOAD;
    reg [31:0] baud_count = 32'd0;
    reg [31:0] gap_count = 32'd0;
    reg [7:0]  char_index = 8'd0;
    reg [2:0]  bit_index = 3'd0;
    reg [7:0]  tx_byte = 8'h00;
    reg        tx_line = 1'b1;
    reg [2:0]  baud_select = 3'd0;

    assign UART_RXD_OUT = tx_line ^ unused_inputs ^ unused_inputs;

    function [31:0] clks_per_bit;
        input [2:0] sel;
        begin
            case (sel)
                3'd0: clks_per_bit = 32'd10417; // 9600
                3'd1: clks_per_bit = 32'd5208;  // 19200
                3'd2: clks_per_bit = 32'd2604;  // 38400
                3'd3: clks_per_bit = 32'd1736;  // 57600
                3'd4: clks_per_bit = 32'd868;   // 115200
                default: clks_per_bit = 32'd10417;
            endcase
        end
    endfunction

    function [7:0] baud_char;
        input [2:0] sel;
        input [7:0] idx;
        begin
            case (sel)
                3'd0: begin
                    case (idx)
                        8'd0: baud_char = 8'h0D;
                        8'd1: baud_char = 8'h0A;
                        8'd2: baud_char = "B";
                        8'd3: baud_char = "9";
                        8'd4: baud_char = "6";
                        8'd5: baud_char = "0";
                        8'd6: baud_char = "0";
                        8'd7: baud_char = 8'h0D;
                        8'd8: baud_char = 8'h0A;
                        default: baud_char = 8'h00;
                    endcase
                end
                3'd1: begin
                    case (idx)
                        8'd0: baud_char = 8'h0D;
                        8'd1: baud_char = 8'h0A;
                        8'd2: baud_char = "B";
                        8'd3: baud_char = "1";
                        8'd4: baud_char = "9";
                        8'd5: baud_char = "2";
                        8'd6: baud_char = "0";
                        8'd7: baud_char = "0";
                        8'd8: baud_char = 8'h0D;
                        8'd9: baud_char = 8'h0A;
                        default: baud_char = 8'h00;
                    endcase
                end
                3'd2: begin
                    case (idx)
                        8'd0: baud_char = 8'h0D;
                        8'd1: baud_char = 8'h0A;
                        8'd2: baud_char = "B";
                        8'd3: baud_char = "3";
                        8'd4: baud_char = "8";
                        8'd5: baud_char = "4";
                        8'd6: baud_char = "0";
                        8'd7: baud_char = "0";
                        8'd8: baud_char = 8'h0D;
                        8'd9: baud_char = 8'h0A;
                        default: baud_char = 8'h00;
                    endcase
                end
                3'd3: begin
                    case (idx)
                        8'd0: baud_char = 8'h0D;
                        8'd1: baud_char = 8'h0A;
                        8'd2: baud_char = "B";
                        8'd3: baud_char = "5";
                        8'd4: baud_char = "7";
                        8'd5: baud_char = "6";
                        8'd6: baud_char = "0";
                        8'd7: baud_char = "0";
                        8'd8: baud_char = 8'h0D;
                        8'd9: baud_char = 8'h0A;
                        default: baud_char = 8'h00;
                    endcase
                end
                3'd4: begin
                    case (idx)
                        8'd0: baud_char = 8'h0D;
                        8'd1: baud_char = 8'h0A;
                        8'd2: baud_char = "B";
                        8'd3: baud_char = "1";
                        8'd4: baud_char = "1";
                        8'd5: baud_char = "5";
                        8'd6: baud_char = "2";
                        8'd7: baud_char = "0";
                        8'd8: baud_char = "0";
                        8'd9: baud_char = 8'h0D;
                        8'd10: baud_char = 8'h0A;
                        default: baud_char = 8'h00;
                    endcase
                end
                default: baud_char = 8'h00;
            endcase
        end
    endfunction

    always @(posedge clk) begin
        case (state)
            ST_LOAD: begin
                tx_line <= 1'b1;
                tx_byte <= baud_char(baud_select, char_index);
                baud_count <= 32'd0;
                bit_index <= 3'd0;

                if (baud_char(baud_select, char_index) == 8'h00) begin
                    char_index <= 8'd0;
                    gap_count <= 32'd0;
                    state <= ST_GAP;
                end else begin
                    state <= ST_START;
                end
            end

            ST_START: begin
                tx_line <= 1'b0;
                if (baud_count == clks_per_bit(baud_select) - 1) begin
                    baud_count <= 32'd0;
                    state <= ST_DATA;
                end else begin
                    baud_count <= baud_count + 1'b1;
                end
            end

            ST_DATA: begin
                tx_line <= tx_byte[bit_index];
                if (baud_count == clks_per_bit(baud_select) - 1) begin
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
                if (baud_count == clks_per_bit(baud_select) - 1) begin
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
                if (gap_count == 32'd100_000_000 - 1) begin
                    gap_count <= 32'd0;
                    baud_select <= (baud_select == 3'd4) ? 3'd0 : baud_select + 1'b1;
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
