 
  lui sp, 0x4 # Initialize sp

  sw x0, 4(x0)   #initialize IO
  sw x0, 8(x0)
  addi s1, x0, 4 #Bitmask
  addi t1, x0, 1

  addi t2, x0, 0x200
  sw t2, 0x100(x0) #Init input buffer pointer

welcome:
  
  call clear_screen

  addi a0, x0, ' '
  j put_char 
# call put_char
  
  addi a0, x0, 'S'
  j put_char
# call put_char
  
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

  addi a0, x0, 0x0D #carriage return
  call put_char

  addi a0, x0, 0x0A #line feed
  call put_char

  addi a0, x0, 0x0A #another one
  call put_char

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

  addi t3, x0, 0x0D
  beq t0, t3, parse_command  

parse_command_return:  
  addi t1, x0, 1 # t1 gets mangled in parse_command

  sb t0, 0(s2)     #save input
  addi s2, s2, 1   #increment pointer
  sw s2, 0x100(x0) #store pointer
  
      
 
  sw t0, 4(x0) #mov rx to tx
  sw t1, 8(x0) #transmit high
  sw x0, 8(x0) #transmit low
  j polling_loop

parse_command:
  addi a0, x0, 0x0A #line feed
  call put_char
  

  #begin case statement
  lw s3, 0x200(x0) # grab command
  
  # clr
  addi t0, x0, 'c'
  slli t0, t0, 8
  addi t0, t0, 'l'
  slli t0, t0, 8
  addi t0, t0, 'r'
  slli t0, t0, 8
  addi t0, t0, 's'
  
  beq s3, t0, clear

  j default

  clear:

  default:
    addi a0, x0, 'I' #line feed
    call put_char
    
    addi a0, x0, 'n' #line feed
    call put_char

    addi a0, x0, 'v' #line feed
    call put_char

    addi a0, x0, 'a' #line feed
    call put_char
    
    addi a0, x0, 'l' #line feed
    call put_char

    addi a0, x0, 'i' #line feed
    call put_char

    addi a0, x0, 'd' #line feed
    call put_char

    addi a0, x0, 0x0D #line feed
    call put_char

    addi a0, x0, 0x0A #line feed
    call put_char





   

  end_case:
    j parse_command_return

put_char: #Assumes printing char is in a0
  sw a0, 4(x0)
  ori t0, x0, 1
  sw t0, 8(x0)
  sw x0, 8(x0)

# testing no delay 
  #delay a bunch
  addi t0, x0, 0xFF
  slli t0, t0, 8
  addi t0, t0, 0xFF  
  
  subtract_loop:
    addi t0, t0, -1
    bne t0, x0, subtract_loop

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



