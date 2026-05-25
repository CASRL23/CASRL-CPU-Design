 # Spur V 0.0.1
 # Author - Noah Braasch



 .text

  lui sp, 0x4 # Initialize sp

  sw x0, 4(x0)   #initialize IO
  sw x0, 8(x0)
  addi s1, x0, 4 #Bitmask
  addi t1, x0, 1

  addi t2, x0, 0x200
  sw t2, 0x100(x0) #Init input buffer pointer

init_ascii_map:
  lui t0, 0x1
  addi t3, x0, 0x30 #'0'
  sb t3, 0(t0)
  addi t3, x0, 0x31 #'1'
  sb t3, 1(t0)
  addi t3, x0, 0x32 #'2'
  sb t3, 2(t0)
  addi t3, x0, 0x33 #'3'
  sb t3, 3(t0)
  addi t3, x0, 0x34
  sb t3, 4(t0)
  addi t3, x0, 0x35
  sb t3, 5(t0)
  addi t3, x0, 0x36
  sb t3, 6(t0)
  addi t3, x0, 0x37
  sb t3, 7(t0)
  addi t3, x0, 0x38
  sb t3, 8(t0)
  addi t3, x0, 0x39
  sb t3, 9(t0)
  addi t3, x0, 0x41 #'A'
  sb t3, 10(t0)
  addi t3, x0, 0x42
  sb t3, 11(t0)
  addi t3, x0, 0x43
  sb t3, 12(t0)
  addi t3, x0, 0x44
  sb t3, 13(t0)
  addi t3, x0, 0x45
  sb t3, 14(t0)
  addi t3, x0, 0x46
  sb t3, 15(t0)

welcome:
  
  call new_line
  call clear_screen

  addi a0, x0, ' '
  call put_char

  addi a0, x0, 'S'
  call put_char

  addi a0, x0, 'p'
  call put_char

  addi a0, x0, 'u'
  call put_char

  addi a0, x0, 'r'
  call put_char

  addi a0, x0, ' ' 
  call put_char

  addi a0, x0, 'v'
  call put_char

  addi a0, x0, '0'
  call put_char

  addi a0, x0, '.'
  call put_char

  addi a0, x0, '0'
  call put_char

  addi a0, x0, '.'
  call put_char  

  addi a0, x0, '1'
  call put_char

  call new_line
  call new_line

  addi a0, x0, ' '
  call put_char

  addi a0, x0, '>'
  call put_char

  addi a0, x0, ' '
  call put_char
   
  
polling_loop:
  lw t2, 12(x0) #if is_recv()
  andi t2, t2, 4
  bne t2, s1, polling_loop

wait_loop:
  lw t2, 12(x0) #if is_not_recv()
  andi t2, t2, 4
  beq t2, s1, wait_loop
  
  lb t0, 0(x0) #grab_rx
  lw s2, 0x100(x0) #Grab input buffer pointer

  addi t3, x0, 0x0D #when enter is pressed, parse command
  beq t0, t3, parse_command  

  addi t3, x0, 0x08     # when backspace is pressed, delete terminal chartacters and update buffer
  beq t0, t3, backspace



parse_command_return:  
  addi t1, x0, 1 # t1 gets mangled in parse_command

  sb t0, 0(s2)     #save input
  addi s2, s2, 1   #increment pointer
  sw s2, 0x100(x0) #store pointer
  
      
 
  sw t0, 4(x0) #mov rx to tx
  sw t1, 8(x0) #transmit high
  sw x0, 8(x0) #transmit low
  j polling_loop

backspace:

  addi a0, x0, 0x08
  call put_char
  addi a0, x0, ' '
  call put_char
  addi a0, x0, 0x08

  addi s2, s2, -1 #decrement pointer
  sb x0, 0(s2) # clear input buffer entry
  sw s2, 0x100(x0) #store pointer

  j polling_loop

parse_command:
  addi a0, x0, 0x0A #line feed
  call put_char
  

  #begin case statement
  lw s3, 0x200(x0) # grab command
  
  # clr
  addi t0, x0, 's'
  slli t0, t0, 8
  addi t0, t0, 'r'
  slli t0, t0, 8
  addi t0, t0, 'l'
  slli t0, t0, 8
  addi t0, t0, 'c'
  
  beq s3, t0, clear

  addi t0, x0, 'm'
  slli t0, t0, 8
  addi t0, t0, 'g'
  slli t0, t0, 8
  addi t0, t0, 'e'
  slli t0, t0, 8
  addi t0, t0, 'r'

  beq s3, t0, reg_monitor

  addi t0, x0, 'b'
  slli t0, t0, 8
  addi t0, t0, 'i'
  slli t0, t0, 8
  addi t0, t0, 'f'

  beq s3, t0, fib

  j default

  clear:
    call clear_screen
    j end_case

  fib:
  # Save registers
    addi sp, sp, -4
    sw a0, 0(sp)
    addi sp, sp, -4
    sw t0, 0(sp)
    addi sp, sp, -4
    sw t1, 0(sp)
    addi sp, sp, -4
    sw t2, 0(sp)
    addi sp, sp, -4
    sw t3, 0(sp)

    addi t0, x0, 0
    addi t1, x0, 1
    addi t3, x0, 20  # Number of fib numbers

    fib_loop:
      add t2, t1, t0
      add a0, t2, x0

      call put_char
      call new_line

      add t0, t1, x0
      add t1, t2, x0
      addi t3, t3, -1
      bne t3, x0, fib_loop


    lw t3, 0(sp)     # Restore registers
    addi sp, sp, 4
    lw t2, 0(sp)
    addi sp, sp, 4
    lw t1, 0(sp)
    addi sp, sp, 4
    lw t0, 0(sp)
    addi sp, sp, 4
    lw a0, 0(sp)
    addi sp, sp, 4

    j end_case 

  reg_monitor:
   
    addi a0, x0, ' '
    call put_char
    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char    
    addi a0, x0, '0'
    call put_char    
    addi a0, x0, '0'
    call put_char    
    addi a0, x0, '0'
    call put_char    
    addi a0, x0, '0'

    addi a0, x0, ' '
    call put_char

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '1'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char   
    
    add t0, x0, x1
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x1
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x1
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char
    
    add t0, x0, x1
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char
   
    call new_line
    call new_line

    addi a0, x0, ' '
    call put_char
    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '2'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char   
    
    add t0, x0, x2
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x2
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x2
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char
    
    add t0, x0, x2
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char
 
    addi a0, x0, ' '
    call put_char   

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '3'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char   
    
    add t0, x0, x3
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x3
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x3
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char
    
    add t0, x0, x3
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char
   
    call new_line
    call new_line

    addi a0, x0, ' '
    call put_char
    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '4'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char   
    
    add t0, x0, x4
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x4
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x4
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char
    
    add t0, x0, x4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char
 
    addi a0, x0, ' '
    call put_char   

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '5'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char   
    
    add t0, x0, x5
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x5
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x5
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char
    
    add t0, x0, x5
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char
   
    call new_line
    call new_line

    addi a0, x0, ' '
    call put_char
    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '6'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x6
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x6
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x6
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x6
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    addi a0, x0, ' '
    call put_char

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '7'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x7
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x7
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x7
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x7
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    call new_line
    call new_line

    addi a0, x0, ' '
    call put_char
    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '8'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x8
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x8
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x8
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    addi a0, x0, ' '
    call put_char

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '9'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x9
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x9
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x9
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x9
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    call new_line
    call new_line

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '1'
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x10
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x10
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x10
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x10
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    addi a0, x0, ' '
    call put_char

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '1'
    call put_char
    addi a0, x0, '1'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x11
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x11
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x11
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x11
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    call new_line
    call new_line

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '1'
    call put_char
    addi a0, x0, '2'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x12
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x12
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x12
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x12
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    addi a0, x0, ' '
    call put_char

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '1'
    call put_char
    addi a0, x0, '3'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x13
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x13
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x13
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x13
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    call new_line
    call new_line

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '1'
    call put_char
    addi a0, x0, '4'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x14
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x14
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x14
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x14
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    addi a0, x0, ' '
    call put_char

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '1'
    call put_char
    addi a0, x0, '5'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x15
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x15
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x15
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x15
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    call new_line
    call new_line

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '1'
    call put_char
    addi a0, x0, '6'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x16
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x16
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x16
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x16
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    addi a0, x0, ' '
    call put_char

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '1'
    call put_char
    addi a0, x0, '7'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x17
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x17
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x17
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x17
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    call new_line
    call new_line

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '1'
    call put_char
    addi a0, x0, '8'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x18
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x18
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x18
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x18
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    addi a0, x0, ' '
    call put_char

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '1'
    call put_char
    addi a0, x0, '9'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x19
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x19
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x19
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x19
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    call new_line
    call new_line

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '2'
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x20
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x20
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x20
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x20
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    addi a0, x0, ' '
    call put_char

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '2'
    call put_char
    addi a0, x0, '1'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x21
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x21
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x21
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x21
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    call new_line
    call new_line

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '2'
    call put_char
    addi a0, x0, '2'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x22
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x22
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x22
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x22
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    addi a0, x0, ' '
    call put_char

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '2'
    call put_char
    addi a0, x0, '3'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x23
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x23
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x23
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x23
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    call new_line
    call new_line

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '2'
    call put_char
    addi a0, x0, '4'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x24
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x24
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x24
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x24
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    addi a0, x0, ' '
    call put_char

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '2'
    call put_char
    addi a0, x0, '5'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x25
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x25
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x25
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x25
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    call new_line
    call new_line

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '2'
    call put_char
    addi a0, x0, '6'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x26
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x26
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x26
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x26
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    addi a0, x0, ' '
    call put_char

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '2'
    call put_char
    addi a0, x0, '7'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x27
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x27
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x27
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x27
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    call new_line
    call new_line

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '2'
    call put_char
    addi a0, x0, '8'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x28
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x28
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x28
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x28
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    addi a0, x0, ' '
    call put_char

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '2'
    call put_char
    addi a0, x0, '9'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x29
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x29
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x29
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x29
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    call new_line
    call new_line

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '3'
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x30
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x30
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x30
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x30
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    addi a0, x0, ' '
    call put_char

    addi a0, x0, 'x'
    call put_char
    addi a0, x0, '3'
    call put_char
    addi a0, x0, '1'
    call put_char
    addi a0, x0, ':'
    call put_char
    addi a0, x0, ' '
    call put_char
    addi a0, x0, '0'
    call put_char
    addi a0, x0, 'x'
    call put_char

    add t0, x0, x31
    srli t0, t0, 12
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x31
    srli t0, t0, 8
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x31
    srli t0, t0, 4
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    add t0, x0, x31
    andi t0, t0, 0xFF
    lui a0, 0x1
    add a0, a0, t0
    lw a0, 0(a0)
    call put_char

    call new_line
    call new_line

    j end_case

  default:
    addi a0, x0, 'I' 
    call put_char
    
    addi a0, x0, 'n' 
    call put_char

    addi a0, x0, 'v' 
    call put_char

    addi a0, x0, 'a' 
    call put_char
    
    addi a0, x0, 'l' 
    call put_char

    addi a0, x0, 'i' 
    call put_char

    addi a0, x0, 'd' 
    call put_char

    addi a0, x0, 0x0D 
    call put_char

    addi a0, x0, 0x0A 
    call put_char
   

  end_case:
    j parse_command_return


put_char: #Assumes printing char is in a0
	sw a0, 4(x0)
    add x0, x0, x0
    add x0, x0, x0
    add x0, x0, x0
    add x0, x0, x0
    add x0, x0, x0
	ori t0, x0, 1
	sw t0, 8(x0)
    add x0, x0, x0
    add x0, x0, x0
    add x0, x0, x0
    add x0, x0, x0
    add x0, x0, x0
	sw x0, 8(x0)

  #delay a bunch
  addi t0, x0, 0xFF
  slli t0, t0, 8
  addi t0, t0, 0xFF  
  
  subtract_loop:
    addi t0, t0, -1
    bne t0, x0, subtract_loop
  ret 

clear_screen:
  addi sp, sp, -4
  sw ra, 0(sp)
  
  addi a0, x0, 0x1B #Escape
  call put_char
 
  addi a0, x0, 'c' #Reset terminal DOES HAVE SIDE EFFECTS FIX LATER
  call put_char
  
  lw ra, 0(sp)
  addi sp, sp, 4
  
  ret

new_line:
  addi sp, sp, -4
  sw ra, 0(sp)

  addi a0, x0, 0x0D #carriage return
  call put_char

  addi a0, x0, 0x0A #line feed
  call put_char

  lw ra, 0(sp)
  addi sp, sp, 4

  ret
