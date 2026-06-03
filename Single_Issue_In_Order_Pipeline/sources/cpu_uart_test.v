`timescale 1ns / 1ps

module CPU(
    output wire Done,
    input  wire clk,           // Nexys A7 100 MHz clock
    input  wire Reset,         // Active-high pushbutton reset
    input  wire UART_TXD_IN,   // PC -> FPGA
    output wire UART_RXD_OUT   // FPGA -> PC terminal
);

    localparam BAUD_RATE    = 9600;
    localparam SYS_CLK_FREQ = 100000000;
    localparam RESET_CYCLES = 20'd1_000_000; // 10 ms at 100 MHz

    wire cpu_done;
    wire [31:0] display_out;
    assign Done = cpu_done;

    reg [2:0] reset_sync = 3'b111;
    always @(posedge clk) begin
        reset_sync <= {reset_sync[1:0], Reset};
    end

    wire reset_clean = reset_sync[2];

    reg [19:0] reset_delay = RESET_CYCLES;
    always @(posedge clk) begin
        if (reset_clean)
            reset_delay <= RESET_CYCLES;
        else if (reset_delay != 0)
            reset_delay <= reset_delay - 1'b1;
    end

    wire system_reset = reset_clean || (reset_delay != 0);

    reg uart_rx_meta = 1'b1;
    reg uart_rx_sync = 1'b1;
    always @(posedge clk) begin
        uart_rx_meta <= UART_TXD_IN;
        uart_rx_sync <= uart_rx_meta;
    end

    wire        cpu_uart_transmit_signal;
    wire [7:0]  cpu_uart_tx_byte;
    wire [7:0]  cpu_uart_rx_byte;
    wire [31:0] cpu_uart_status;

    wire received;
    wire [7:0] rx_byte;
    wire is_receiving;
    wire is_transmitting;
    wire recv_error;
    wire [3:0] rx_samples;
    wire [3:0] rx_sample_countdown;

    reg        uart_transmit = 1'b0;
    reg [7:0]  uart_tx_byte  = 8'h00;

    reg [2:0] print_state = 3'd0;
    reg       cpu_tx_pending = 1'b0;
    reg       boot_printed = 1'b0;
    reg       done_printed = 1'b0;

    wire cpu_reset = system_reset || !boot_printed;

    wire uart_ready_for_cpu = !system_reset &&
                              boot_printed &&
                              !is_transmitting &&
                              !uart_transmit &&
                              !cpu_tx_pending &&
                              (print_state == 3'd0);

    assign cpu_uart_rx_byte = rx_byte;
    assign cpu_uart_status  = {29'd0, recv_error, received, uart_ready_for_cpu};

    Pipeline_CPU PCPU(
        .Done(cpu_done),
        .Display_out(display_out),
        .Clk(clk),
        .Reset(cpu_reset),
        .UART_rx_byte(cpu_uart_rx_byte),
        .UART_tx_byte(cpu_uart_tx_byte),
        .UART_transmit_signal(cpu_uart_transmit_signal),
        .UART_status(cpu_uart_status)
    );

    uart #(
        .baud_rate(BAUD_RATE),
        .sys_clk_freq(SYS_CLK_FREQ)
    ) u_uart (
        .clk(clk),
        .rst(system_reset),
        .rx(uart_rx_sync),
        .tx(UART_RXD_OUT),
        .transmit(uart_transmit),
        .tx_byte(uart_tx_byte),
        .received(received),
        .rx_byte(rx_byte),
        .is_receiving(is_receiving),
        .is_transmitting(is_transmitting),
        .recv_error(recv_error),
        .rx_samples(rx_samples),
        .rx_sample_countdown(rx_sample_countdown)
    );

    reg [31:0] cycle_count = 32'd0;
    reg [31:0] cycle_latched = 32'd0;
    reg        done_d = 1'b0;
    reg        done_latched = 1'b0;

    always @(posedge clk) begin
        if (cpu_reset) begin
            cycle_count   <= 32'd0;
            cycle_latched <= 32'd0;
            done_d        <= 1'b0;
            done_latched  <= 1'b0;
        end else begin
            done_d <= cpu_done;

            if (!cpu_done)
                cycle_count <= cycle_count + 1'b1;

            if (cpu_done && !done_d) begin
                cycle_latched <= cycle_count;
                done_latched  <= 1'b1;
            end
        end
    end

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
                default: hex_char = "F";
            endcase
        end
    endfunction

    function [7:0] boot_char;
        input [7:0] index;
        begin
            case (index)
                8'd0:  boot_char = 8'h0D;
                8'd1:  boot_char = 8'h0A;
                8'd2:  boot_char = "C";
                8'd3:  boot_char = "P";
                8'd4:  boot_char = "U";
                8'd5:  boot_char = " ";
                8'd6:  boot_char = "U";
                8'd7:  boot_char = "A";
                8'd8:  boot_char = "R";
                8'd9:  boot_char = "T";
                8'd10: boot_char = " ";
                8'd11: boot_char = "B";
                8'd12: boot_char = "O";
                8'd13: boot_char = "O";
                8'd14: boot_char = "T";
                8'd15: boot_char = 8'h0D;
                8'd16: boot_char = 8'h0A;
                default: boot_char = 8'h00;
            endcase
        end
    endfunction

    function [7:0] done_char;
        input [7:0] index;
        begin
            case (index)
                8'd0:  done_char = "C";
                8'd1:  done_char = "P";
                8'd2:  done_char = "U";
                8'd3:  done_char = " ";
                8'd4:  done_char = "D";
                8'd5:  done_char = "O";
                8'd6:  done_char = "N";
                8'd7:  done_char = "E";
                8'd8:  done_char = " ";
                8'd9:  done_char = "c";
                8'd10: done_char = "y";
                8'd11: done_char = "c";
                8'd12: done_char = "l";
                8'd13: done_char = "e";
                8'd14: done_char = "s";
                8'd15: done_char = "=";
                8'd16: done_char = "0";
                8'd17: done_char = "x";
                8'd18: done_char = hex_char(cycle_latched[31:28]);
                8'd19: done_char = hex_char(cycle_latched[27:24]);
                8'd20: done_char = hex_char(cycle_latched[23:20]);
                8'd21: done_char = hex_char(cycle_latched[19:16]);
                8'd22: done_char = hex_char(cycle_latched[15:12]);
                8'd23: done_char = hex_char(cycle_latched[11:8]);
                8'd24: done_char = hex_char(cycle_latched[7:4]);
                8'd25: done_char = hex_char(cycle_latched[3:0]);
                8'd26: done_char = 8'h0D;
                8'd27: done_char = 8'h0A;
                default: done_char = 8'h00;
            endcase
        end
    endfunction

    localparam S_IDLE      = 3'd0;
    localparam S_LOAD_BOOT = 3'd1;
    localparam S_LOAD_DONE = 3'd2;
    localparam S_PULSE     = 3'd3;
    localparam S_WAIT_BUSY = 3'd4;
    localparam S_WAIT_DONE = 3'd5;

    reg [7:0] msg_index = 8'd0;
    reg       cpu_uart_transmit_d = 1'b0;
    reg [7:0] cpu_tx_pending_byte = 8'h00;

    always @(posedge clk) begin
        if (system_reset) begin
            uart_transmit       <= 1'b0;
            uart_tx_byte        <= 8'h00;
            print_state         <= S_IDLE;
            msg_index           <= 8'd0;
            boot_printed        <= 1'b0;
            done_printed        <= 1'b0;
            cpu_uart_transmit_d <= 1'b0;
            cpu_tx_pending      <= 1'b0;
            cpu_tx_pending_byte <= 8'h00;
        end else begin
            uart_transmit <= 1'b0;
            cpu_uart_transmit_d <= cpu_uart_transmit_signal;

            if (boot_printed && cpu_uart_transmit_signal && !cpu_uart_transmit_d && !cpu_tx_pending) begin
                cpu_tx_pending      <= 1'b1;
                cpu_tx_pending_byte <= cpu_uart_tx_byte;
            end

            case (print_state)
                S_IDLE: begin
                    if (cpu_tx_pending && !is_transmitting) begin
                        uart_tx_byte   <= cpu_tx_pending_byte;
                        cpu_tx_pending <= 1'b0;
                        print_state    <= S_PULSE;
                    end else if (!boot_printed) begin
                        msg_index   <= 8'd0;
                        print_state <= S_LOAD_BOOT;
                    end else if (done_latched && !done_printed) begin
                        msg_index   <= 8'd0;
                        print_state <= S_LOAD_DONE;
                    end
                end

                S_LOAD_BOOT: begin
                    if (!is_transmitting) begin
                        if (boot_char(msg_index) != 8'h00) begin
                            uart_tx_byte <= boot_char(msg_index);
                            msg_index    <= msg_index + 1'b1;
                            print_state  <= S_PULSE;
                        end else begin
                            boot_printed <= 1'b1;
                            print_state  <= S_IDLE;
                        end
                    end
                end

                S_LOAD_DONE: begin
                    if (!is_transmitting) begin
                        if (done_char(msg_index) != 8'h00) begin
                            uart_tx_byte <= done_char(msg_index);
                            msg_index    <= msg_index + 1'b1;
                            print_state  <= S_PULSE;
                        end else begin
                            done_printed <= 1'b1;
                            print_state  <= S_IDLE;
                        end
                    end
                end

                S_PULSE: begin
                    uart_transmit <= 1'b1;
                    print_state   <= S_WAIT_BUSY;
                end

                S_WAIT_BUSY: begin
                    if (is_transmitting)
                        print_state <= S_WAIT_DONE;
                end

                S_WAIT_DONE: begin
                    if (!is_transmitting)
                        print_state <= S_IDLE;
                end

                default: begin
                    print_state <= S_IDLE;
                end
            endcase
        end
    end

endmodule
