`timescale 1ns / 1ps

// Compatibility top for older Vivado projects that selected CPU_1.
// The actual Nexys A7 board wrapper is module CPU in cpu_uart_test.v.
module CPU_1(
    output wire Done,
    input  wire clk,
    input  wire Reset,
    input  wire UART_TXD_IN,
    output wire UART_RXD_OUT
);

    CPU cpu_top (
        .Done(Done),
        .clk(clk),
        .Reset(Reset),
        .UART_TXD_IN(UART_TXD_IN),
        .UART_RXD_OUT(UART_RXD_OUT)
    );

endmodule
