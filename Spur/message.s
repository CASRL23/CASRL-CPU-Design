

addi a0, x0, 0x1B
call put_char


addi a0, x0, 'c'
call put_char


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

addi a0, x0, 'L'
call put_char


addi a0, x0, 'i'
call put_char


addi a0, x0, 't'
call put_char


addi a0, x0, 'e'
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


addi a0, x0, 0x0D
call put_char


addi a0, x0, 0x0A
call put_char


addi a0, x0, 0x0A
call put_char


addi a0, x0, 'H'
call put_char


addi a0, x0, 'e'
call put_char


addi a0, x0, 'l'
call put_char


addi a0, x0, 'l'
call put_char


addi a0, x0, 'o'
call put_char


addi a0, x0, ' '
call put_char


addi a0, x0, 'f'
call put_char


addi a0, x0, 'r'
call put_char


addi a0, x0, 'o'
call put_char


addi a0, x0, 'm'
call put_char


addi a0, x0, ' '
call put_char


addi a0, x0, 't'
call put_char


addi a0, x0, 'h'
call put_char


addi a0, x0, 'e'
call put_char


addi a0, x0, ' '
call put_char


addi a0, x0, 'W'
call put_char


addi a0, x0, 'M'
call put_char


addi a0, x0, 'U'
call put_char


addi a0, x0, ' '
call put_char


addi a0, x0, 'C'
call put_char


addi a0, x0, 'o'
call put_char


addi a0, x0, 'm'
call put_char


addi a0, x0, 'p'
call put_char


addi a0, x0, 'u'
call put_char


addi a0, x0, 't'
call put_char


addi a0, x0, 'e'
call put_char


addi a0, x0, 'r'
call put_char


addi a0, x0, ' '
call put_char


addi a0, x0, 'A'
call put_char


addi a0, x0, 'r'
call put_char


addi a0, x0, 'c'
call put_char


addi a0, x0, 'h'
call put_char


addi a0, x0, 'i'
call put_char


addi a0, x0, 't'
call put_char


addi a0, x0, 'e'
call put_char


addi a0, x0, 'c'
call put_char


addi a0, x0, 't'
call put_char


addi a0, x0, 'u'
call put_char


addi a0, x0, 'r'
call put_char


addi a0, x0, 'e'
call put_char


addi a0, x0, ' '
call put_char


addi a0, x0, 'l'
call put_char

addi a0, x0, 'a'
call put_char


addi a0, x0, 'b'
call put_char


addi a0, x0, '!'
call put_char

addi a0, x0, 0x0D
call put_char


addi a0, x0, 0x0A
call put_char


addi a0, x0, 0x0A
call put_char


addi a0, x0, 'S'
call put_char

addi a0, x0, 'p'
call put_char


addi a0, x0, 'e'
call put_char


addi a0, x0, 'c'
call put_char


addi a0, x0, 'i'
call put_char


addi a0, x0, 'a'
call put_char


addi a0, x0, 'l'
call put_char


addi a0, x0, ' '
call put_char


addi a0, x0, 't'
call put_char


addi a0, x0, 'h'
call put_char


addi a0, x0, 'a'
call put_char


addi a0, x0, 'n'
call put_char


addi a0, x0, 'k'
call put_char


addi a0, x0, 'S'
call put_char


addi a0, x0, ' '
call put_char


addi a0, x0, 't'
call put_char


addi a0, x0, 'o'
call put_char


addi a0, x0, ' '
call put_char


addi a0, x0, 'D'
call put_char


addi a0, x0, 'r'
call put_char


addi a0, x0, '.'
call put_char


addi a0, x0, ' '
call put_char


addi a0, x0, 'L'
call put_char


addi a0, x0, 'i'
call put_char


addi a0, x0, 'n'
call put_char


addi a0, x0, 'a'
call put_char


addi a0, x0, ' '
call put_char


addi a0, x0, 'S'
call put_char


addi a0, x0, 'a'
call put_char


addi a0, x0, 'w'
call put_char


addi a0, x0, 'a'
call put_char


addi a0, x0, 'l'
call put_char


addi a0, x0, 'h'
call put_char


addi a0, x0, 'a'
call put_char


addi a0, x0, '!'
call put_char

addi a0, x0, 0x0D
call put_char


addi a0, x0, 0x0A
call put_char



j done

put_char:
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
    
    addi t0, x0, 0xFF
    slli t0, t0, 8
    addi t0, t0, 0xFF
    
    subtract_loop:
    	addi t0, t0, -1
        bne t0, x0, subtract_loop
        ret
        
 done:
 
