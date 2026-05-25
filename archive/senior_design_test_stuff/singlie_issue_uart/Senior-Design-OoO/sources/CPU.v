`timescale 10ns / 1ps
module CPU(
    output wire Done,
    input wire CLK_125_P,
    input wire CLK_125_N,
    input wire Reset,
    
    // UART ports
    output wire UART_tx,
    input wire UART_rx
);
    
    wire clk_100mhz;
    wire clk_500mhz;
    wire clk_25mhz;
    wire locked;
    
    // UART signals
    wire [7:0] UART_tx_byte;
    wire [7:0] UART_rx_byte;
    wire transmit;
    wire received;
    wire is_receiving;
    wire is_transmitting;
    wire recv_error;
    
    // Display output (not used but required by Pipeline_CPU)
    wire [31:0] Display_out;
    
    clk_wiz_0 inst(
        // Clock out ports  
        .clk_out_100(clk_100mhz),
        .clk_out_25(clk_25mhz),
        // Status and control signals               
        .reset(Reset),
        .locked(locked),
        // Clock in ports
        .clk_in1_p(CLK_125_P),
        .clk_in1_n(CLK_125_N)
    );
    
    // UART Controller
    uart #(
        .baud_rate(9600),
        .sys_clk_freq(100000000)
    ) uart_controller (
        .clk(clk_100mhz),              // UART runs on 100MHz
        .rst(Reset),
        .rx(UART_rx),
        .tx(UART_tx),
        .transmit(transmit),
        .tx_byte(UART_tx_byte),
        .received(received),
        .rx_byte(UART_rx_byte),
        .is_receiving(is_receiving),
        .is_transmitting(is_transmitting),
        .recv_error(recv_error)
    );
    
    // UART Status register
    wire [31:0] UART_Status;
    assign UART_Status = {29'd0, is_receiving, is_transmitting, recv_error};
    
    Pipeline_CPU PCPU(
        .Done(Done),
        .Display_out(Display_out),     // Connect the Display_out port
        .Clk(clk_25mhz),              
        .Reset(Reset),
        
        // UART connections
        .UART_rx_byte(UART_rx_byte),
        .UART_tx_byte(UART_tx_byte),
        .UART_transmit_signal(transmit),
        .UART_status(UART_Status)
    );    
endmodule