`timescale 10ns / 1ps
module CPU(
    output wire Done,
    input wire CLK_125_P,
    input wire CLK_125_N,
    input wire Reset,
    
    output wire UART_tx,
    input wire UART_rx
    
);
    

    wire clk_100mhz;
    wire clk_25mhz;
    wire clk_200mhz;
    wire locked;

    wire [7:0] UART_tx_byte; // Will need to become a wire that is fed into a queue for the controller
    wire [7:0] UART_rx_byte;
    
    wire transmit;
    wire transmit_pulse;
    wire received;
    wire is_receiving;
    wire is_transmitting;
    wire recv_error;

  clk_wiz_0 inst
  (
  // Clock out ports  
  .clk_100mhz(clk_100mhz),
  .clk_25mhz(clk_25mhz),
  .clk_200mhz(clk_200mhz),
  // Status and control signals               
  .reset(Reset), 
  .locked(locked),
 // Clock in ports
  .clk_in1_p(CLK_125_P),
  .clk_in1_n(CLK_125_N)
  );

//    ila_0 analyzer(
     //   .clk(clk_100mhz),
//        .probe0(MICPU.Memory_Stage.multi_ram.UART_RX_Byte),
//        .probe1(MICPU.Memory_Stage.multi_ram.UART_TX_Byte),
//        .probe2(MICPU.Memory_Stage.multi_ram.UART_status),
//        .probe3(MICPU.Fetch_Stage.MIFU.PC0),
//        .probe4(MICPU.Decode_Stage.MIRF.x2_out),
//        .probe5(MICPU.Decode_Stage.MIRF.x1_out),
//        .probe6(MICPU.Decode_Stage.MIRF.x10_out),
//        .probe7(Done),
//        .probe8(Reset | locked)        
//    );
    
    
    //     UART Controller
    uart #(
        .baud_rate(9600),
        .sys_clk_freq(100000000)
    ) uart_controller (
        .clk(clk_100mhz),
        .rst(Reset),
        .rx(UART_rx),
        .tx(UART_tx),
        .transmit(transmit),      // Now controlled by FIFO
        .tx_byte(UART_tx_byte),        // Data from FIFO
        .received(received),
        .rx_byte(UART_rx_byte),
        .is_receiving(is_receiving),
        .is_transmitting(is_transmitting),
        .recv_error(recv_error)
    );
    
    wire [31:0] UART_Status; assign UART_Status = {29'd0, is_receiving, is_transmitting, recv_error};
    
    Multi_Issue_CPU MICPU(
        .Done(Done),
//        .Display_out(Display_out), 
        .Clk(clk_25mhz),              
        .Reset(Reset),
        
        .UART_rx_byte(UART_rx_byte),
        .UART_tx_byte(UART_tx_byte),
        .UART_transmit_signal(transmit),
        .UART_status(UART_Status)   
    );   
endmodule
