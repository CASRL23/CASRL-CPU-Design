`timescale 1ns / 1ps

module CPU(
    output wire Done,
    input  wire clk,           // Nexys A7 100 MHz clock
    input  wire Reset,
    input  wire UART_TXD_IN,   // PC -> FPGA, unused for now
    output wire UART_RXD_OUT   // FPGA -> PC terminal
);

    localparam BAUD_RATE    = 9600;
    localparam SYS_CLK_FREQ = 100000000;  // change to 125000000 if using 125 MHz

    wire cpu_done;

    assign Done = cpu_done;

    Pipeline_CPU PCPU(
        .Done(cpu_done),
        .Clk(clk),
        .Reset(Reset),
        .UART_rx_byte(UART_rx_byte),
        .UART_tx_byte(UART_tx_byte),
        .UART_transmit_signal(transmit),
        .UART_status(UART_Status)
    );

    // ------------------------------------------------------------
    // Cycle counter for CPU runtime
    // ------------------------------------------------------------
    reg [31:0] cycle_count;
    reg [31:0] cycle_latched;
    reg        done_d;
    reg        done_latched;

    always @(posedge clk) begin
        if (Reset) begin
            cycle_count  <= 32'd0;
            cycle_latched <= 32'd0;
            done_d       <= 1'b0;
            done_latched <= 1'b0;
        end else begin
            done_d <= cpu_done;

            if (!cpu_done)
                cycle_count <= cycle_count + 1'b1;

            // Rising edge of Done
            if (cpu_done && !done_d) begin
                cycle_latched <= cycle_count;
                done_latched  <= 1'b1;
            end
        end
    end

    // ------------------------------------------------------------
    // UART signals
    // ------------------------------------------------------------
    wire received;
    wire [7:0] rx_byte;
    wire is_receiving;
    wire is_transmitting;
    wire recv_error;

    wire [3:0] rx_samples;
    wire [3:0] rx_sample_countdown;

    reg transmit;
    reg [7:0] tx_byte;

    uart #(
        .baud_rate(BAUD_RATE),
        .sys_clk_freq(SYS_CLK_FREQ)
    ) u_uart (
        .clk(clk),
        .rst(Reset),

        .rx(UART_TXD_IN),
        .tx(UART_RXD_OUT),

        .transmit(transmit),
        .tx_byte(tx_byte),

        .received(received),
        .rx_byte(rx_byte),

        .is_receiving(is_receiving),
        .is_transmitting(is_transmitting),
        .recv_error(recv_error),

        .rx_samples(rx_samples),
        .rx_sample_countdown(rx_sample_countdown)
    );

    // ------------------------------------------------------------
    // Hex character function
    // ------------------------------------------------------------
    function [7:0] hex_char;
        input [3:0] nibble;
        begin
            case (nibble)
                4'h0: hex_char = "0";
                4'h1: hex_char = "1";
                4'h2: hex_char = "2";
                4'h3: hex_char = "3";
                4'h4: hex_char = "4";
                4'h5: hex_char = "5";
                4'h6: hex_char = "6";
                4'h7: hex_char = "7";
                4'h8: hex_char = "8";
                4'h9: hex_char = "9";
                4'hA: hex_char = "A";
                4'hB: hex_char = "B";
                4'hC: hex_char = "C";
                4'hD: hex_char = "D";
                4'hE: hex_char = "E";
                4'hF: hex_char = "F";
            endcase
        end
    endfunction

    // ------------------------------------------------------------
    // Message character ROM
    // Message: "CPU DONE cycles=0x????????\r\n"
    // ------------------------------------------------------------
    function [7:0] message_char;
        input [7:0] index;
        begin
            case (index)
                8'd0:  message_char = "C";
                8'd1:  message_char = "P";
                8'd2:  message_char = "U";
                8'd3:  message_char = " ";
                8'd4:  message_char = "D";
                8'd5:  message_char = "O";
                8'd6:  message_char = "N";
                8'd7:  message_char = "E";
                8'd8:  message_char = " ";
                8'd9:  message_char = "c";
                8'd10: message_char = "y";
                8'd11: message_char = "c";
                8'd12: message_char = "l";
                8'd13: message_char = "e";
                8'd14: message_char = "s";
                8'd15: message_char = "=";
                8'd16: message_char = "0";
                8'd17: message_char = "x";

                8'd18: message_char = hex_char(cycle_latched[31:28]);
                8'd19: message_char = hex_char(cycle_latched[27:24]);
                8'd20: message_char = hex_char(cycle_latched[23:20]);
                8'd21: message_char = hex_char(cycle_latched[19:16]);
                8'd22: message_char = hex_char(cycle_latched[15:12]);
                8'd23: message_char = hex_char(cycle_latched[11:8]);
                8'd24: message_char = hex_char(cycle_latched[7:4]);
                8'd25: message_char = hex_char(cycle_latched[3:0]);

                8'd26: message_char = 8'h0D; // carriage return
                8'd27: message_char = 8'h0A; // newline

                default: message_char = 8'h00;
            endcase
        end
    endfunction

    // ------------------------------------------------------------
    // UART print FSM
    // ------------------------------------------------------------
    localparam S_IDLE      = 2'd0;
    localparam S_SEND      = 2'd1;
    localparam S_WAIT_BUSY = 2'd2;
    localparam S_WAIT_DONE = 2'd3;

    reg [1:0] print_state;
    reg [7:0] msg_index;
    reg       printed;

    always @(posedge clk) begin
        if (Reset) begin
            transmit    <= 1'b0;
            tx_byte     <= 8'h00;
            print_state <= S_IDLE;
            msg_index   <= 8'd0;
            printed     <= 1'b0;
        end else begin
            transmit <= 1'b0; // one-clock pulse only

            case (print_state)
                S_IDLE: begin
                    if (done_latched && !printed) begin
                        msg_index   <= 8'd0;
                        print_state <= S_SEND;
                    end
                end

                S_SEND: begin
                    if (!is_transmitting) begin
                        if (message_char(msg_index) != 8'h00) begin
                            tx_byte     <= message_char(msg_index);
                            transmit   <= 1'b1;
                            msg_index  <= msg_index + 1'b1;
                            print_state <= S_WAIT_BUSY;
                        end else begin
                            printed     <= 1'b1;
                            print_state <= S_IDLE;
                        end
                    end
                end

                S_WAIT_BUSY: begin
                    if (is_transmitting)
                        print_state <= S_WAIT_DONE;
                end

                S_WAIT_DONE: begin
                    if (!is_transmitting)
                        print_state <= S_SEND;
                end

                default: begin
                    print_state <= S_IDLE;
                end
            endcase
        end
    end

endmodule