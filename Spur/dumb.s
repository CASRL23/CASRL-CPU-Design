
welcome:

    call new_line

put_char: #Assumes printing char is in a0
  sw a0, 4(x0)
  ori t0, x0, 1
  sw t0, 8(x0)
  sw x0, 8(x0)

  ret 


new_line:
  addi a0, x0, 0x0D #carriage return
  addi sp, sp, -4
  sw ra, 0(sp)
  call put_char

  addi a0, x0, 0x0A #line feed
  call put_char
  lw ra, 0(sp)
  addi sp, sp, 4
  ret
  
  empty_func:
  	addi x0, x0, 0
  	addi x0, x0, 0
  	addi x0, x0, 0
  	addi x0, x0, 0
