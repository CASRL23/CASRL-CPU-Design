// Simple single-issue CPU UART transmit test.
//
// UART memory map used by RAM.v:
//   0x00 = RX byte
//   0x04 = TX byte
//   0x08 = TX strobe
//   0x0C = status, bit 0 = TX ready
//
// This sends "CPU UART TEST\r\n", then executes the CPU done instruction.

.text

.macro SEND_CHAR value
wait_\@:
    lw   t2, 12(x0)
    addi x0, x0, 0
    addi x0, x0, 0
    andi t2, t2, 1
    addi x0, x0, 0
    addi x0, x0, 0
    beq  t2, x0, wait_\@

    addi a0, x0, \value
    addi x0, x0, 0
    addi x0, x0, 0
    sw   a0, 4(x0)
    addi x0, x0, 0
    addi x0, x0, 0
    addi t0, x0, 1
    addi x0, x0, 0
    addi x0, x0, 0
    sw   t0, 8(x0)
    addi x0, x0, 0
    addi x0, x0, 0
    sw   x0, 8(x0)
.endm

    SEND_CHAR 0x43  // C
    SEND_CHAR 0x50  // P
    SEND_CHAR 0x55  // U
    SEND_CHAR 0x20  // space
    SEND_CHAR 0x55  // U
    SEND_CHAR 0x41  // A
    SEND_CHAR 0x52  // R
    SEND_CHAR 0x54  // T
    SEND_CHAR 0x20  // space
    SEND_CHAR 0x54  // T
    SEND_CHAR 0x45  // E
    SEND_CHAR 0x53  // S
    SEND_CHAR 0x54  // T
    SEND_CHAR 0x0D  // carriage return
    SEND_CHAR 0x0A  // line feed

    // Custom done instruction decoded by Control_unit.v.
    .word 0xffffffff
