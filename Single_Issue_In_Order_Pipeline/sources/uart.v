`timescale 1ns / 1ps

module single_issue_uart #(
    parameter integer baud_rate = 9600,
    parameter integer sys_clk_freq = 100000000
)(
    input  wire clk,
    input  wire rst,
    input  wire rx,
    output wire tx,
    input  wire transmit,
    input  wire [7:0] tx_byte,
    output wire received,
    output wire [7:0] rx_byte,
    output wire is_receiving,
    output wire is_transmitting,
    output wire recv_error,
    output reg  [3:0] rx_samples,
    output reg  [3:0] rx_sample_countdown
);

    localparam integer CLKS_PER_BIT = sys_clk_freq / baud_rate;

    localparam TX_IDLE  = 2'd0;
    localparam TX_START = 2'd1;
    localparam TX_DATA  = 2'd2;
    localparam TX_STOP  = 2'd3;

    reg [1:0]  tx_state = TX_IDLE;
    reg [31:0] tx_count = 32'd0;
    reg [2:0]  tx_bit_index = 3'd0;
    reg [7:0]  tx_shift = 8'h00;
    reg        tx_reg = 1'b1;

    assign tx = tx_reg;
    assign is_transmitting = (tx_state != TX_IDLE);

    always @(posedge clk) begin
        if (rst) begin
            tx_state <= TX_IDLE;
            tx_count <= 32'd0;
            tx_bit_index <= 3'd0;
            tx_shift <= 8'h00;
            tx_reg <= 1'b1;
        end else begin
            case (tx_state)
                TX_IDLE: begin
                    tx_reg <= 1'b1;
                    tx_count <= 32'd0;
                    tx_bit_index <= 3'd0;

                    if (transmit) begin
                        tx_shift <= tx_byte;
                        tx_reg <= 1'b0;
                        tx_state <= TX_START;
                    end
                end

                TX_START: begin
                    if (tx_count == CLKS_PER_BIT - 1) begin
                        tx_count <= 32'd0;
                        tx_reg <= tx_shift[0];
                        tx_state <= TX_DATA;
                    end else begin
                        tx_count <= tx_count + 1'b1;
                    end
                end

                TX_DATA: begin
                    if (tx_count == CLKS_PER_BIT - 1) begin
                        tx_count <= 32'd0;

                        if (tx_bit_index == 3'd7) begin
                            tx_bit_index <= 3'd0;
                            tx_reg <= 1'b1;
                            tx_state <= TX_STOP;
                        end else begin
                            tx_bit_index <= tx_bit_index + 1'b1;
                            tx_reg <= tx_shift[tx_bit_index + 3'd1];
                        end
                    end else begin
                        tx_count <= tx_count + 1'b1;
                    end
                end

                TX_STOP: begin
                    tx_reg <= 1'b1;
                    if (tx_count == CLKS_PER_BIT - 1) begin
                        tx_count <= 32'd0;
                        tx_state <= TX_IDLE;
                    end else begin
                        tx_count <= tx_count + 1'b1;
                    end
                end

                default: begin
                    tx_state <= TX_IDLE;
                    tx_reg <= 1'b1;
                end
            endcase
        end
    end

    localparam RX_IDLE  = 2'd0;
    localparam RX_START = 2'd1;
    localparam RX_DATA  = 2'd2;
    localparam RX_STOP  = 2'd3;

    reg [1:0]  rx_state = RX_IDLE;
    reg [31:0] rx_count = 32'd0;
    reg [2:0]  rx_bit_index = 3'd0;
    reg [7:0]  rx_shift = 8'h00;
    reg [7:0]  rx_byte_reg = 8'h00;
    reg        received_reg = 1'b0;
    reg        recv_error_reg = 1'b0;
    reg        rx_meta = 1'b1;
    reg        rx_sync = 1'b1;

    assign rx_byte = rx_byte_reg;
    assign received = received_reg;
    assign recv_error = recv_error_reg;
    assign is_receiving = (rx_state != RX_IDLE);

    always @(posedge clk) begin
        if (rst) begin
            rx_state <= RX_IDLE;
            rx_count <= 32'd0;
            rx_bit_index <= 3'd0;
            rx_shift <= 8'h00;
            rx_byte_reg <= 8'h00;
            received_reg <= 1'b0;
            recv_error_reg <= 1'b0;
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
            rx_samples <= 4'd0;
            rx_sample_countdown <= 4'd0;
        end else begin
            rx_meta <= rx;
            rx_sync <= rx_meta;
            received_reg <= 1'b0;
            recv_error_reg <= 1'b0;

            case (rx_state)
                RX_IDLE: begin
                    rx_count <= 32'd0;
                    rx_bit_index <= 3'd0;
                    rx_sample_countdown <= 4'd0;

                    if (!rx_sync) begin
                        rx_count <= (CLKS_PER_BIT / 2);
                        rx_state <= RX_START;
                    end
                end

                RX_START: begin
                    if (rx_count == 0) begin
                        if (!rx_sync) begin
                            rx_count <= CLKS_PER_BIT - 1;
                            rx_bit_index <= 3'd0;
                            rx_shift <= 8'h00;
                            rx_state <= RX_DATA;
                        end else begin
                            rx_state <= RX_IDLE;
                        end
                    end else begin
                        rx_count <= rx_count - 1'b1;
                    end
                end

                RX_DATA: begin
                    if (rx_count == 0) begin
                        rx_shift <= {rx_sync, rx_shift[7:1]};
                        rx_samples <= {3'b000, rx_sync};
                        rx_sample_countdown <= 4'd0;
                        rx_count <= CLKS_PER_BIT - 1;

                        if (rx_bit_index == 3'd7) begin
                            rx_bit_index <= 3'd0;
                            rx_state <= RX_STOP;
                        end else begin
                            rx_bit_index <= rx_bit_index + 1'b1;
                        end
                    end else begin
                        rx_count <= rx_count - 1'b1;
                    end
                end

                RX_STOP: begin
                    if (rx_count == 0) begin
                        if (rx_sync) begin
                            rx_byte_reg <= rx_shift;
                            received_reg <= 1'b1;
                        end else begin
                            recv_error_reg <= 1'b1;
                        end
                        rx_state <= RX_IDLE;
                    end else begin
                        rx_count <= rx_count - 1'b1;
                    end
                end

                default: begin
                    rx_state <= RX_IDLE;
                end
            endcase
        end
    end

endmodule
