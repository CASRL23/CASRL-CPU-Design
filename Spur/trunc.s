

 .text

  addi sp, x0, 0xf0 # Initialize sp

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
  
  j done
  
clear_screen:
  addi sp, sp, -4
  sw ra, 0(sp)
  
  add s11, ra, x0 
  
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
  
  put_char: #Assumes printing char is in a0
  sw a0, 4(x0)
  ori t0, x0, 1
  sw t0, 8(x0)
  sw x0, 8(x0)

  ret 
  
  done:
