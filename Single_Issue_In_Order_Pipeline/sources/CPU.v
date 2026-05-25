`timescale 10ns / 1ps
module CPU_1(
    output wire Done,
//    input wire CLK_125_P,
//    input wire CLK_125_N, //for zcu board
    input wire clk,
    input wire Reset,
    input wire UART_TXD_IN,
    output wire UART_RXD_OUT
);
    
//    wire clk_100mhz;
//    wire clk_500mhz;
//    wire clk_25mhz;
//    wire locked;

//   clk_wiz_0 inst(
         // Clock out ports  
//        .clk_out_100(clk_100mhz),
//        .clk_out_25(clk_25mhz),
//        .clk_out_500(clk_500mhz),
         // Status and control signals               
//        .reset(Reset),
//        .locked(locked),
         // Clock in ports
//         .clk_in1(clk)
//        .clk_in1_p(CLK_125_P),
//        .clk_in1_n(CLK_125_N)
//      );

    Pipeline_CPU PCPU(
        .Done(Done),
        .Clk(clk),              
        .Reset(Reset)
    );    
    
    //  To instantiate this module copy this section to your main code...

    uart #(
        .baud_rate(baud_rate),            // default is 9600
        .sys_clk_freq(sys_clk_freq)       // default is 100000000
     )
    instance_name(
        .clk(clk),                        // The master clock for this module
        .rst(rst),                        // Synchronous reset
        .rx(rx),                          // Incoming serial line
        .tx(tx),                          // Outgoing serial line
        .transmit(transmit),              // Signal to transmit
        .tx_byte(tx_byte),                // Byte to transmit       
        .received(received),              // Indicated that a byte has been received
        .rx_byte(rx_byte),                // Byte received
        .is_receiving(is_receiving),      // Low when receive line is idle
        .is_transmitting(is_transmitting),// Low when transmit line is idle
        .recv_error(recv_error)           // Indicates error in receiving packet.
      //.recv_state(recv_state),          // for test bench
      //.tx_state(tx_state)               // for test bench
    );
endmodule
