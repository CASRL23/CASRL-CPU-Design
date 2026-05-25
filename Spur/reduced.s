# Spur Lite v0.0.1
# Author - Noah Braasch

main:

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

addi a0, z0, 0x0A
call put_char

addi a0, x0, 'P'
call put_char


addi a0, x0, 'l'
call put_char


addi a0, x0, 'e'
call put_char


addi a0, x0, 'a'
call put_char


addi a0, x0, 's'
call put_char


addi a0, x0, 'e'
call put_char


addi a0, x0, ' '
call put_char


addi a0, x0, 's'
call put_char


addi a0, x0, 'e'
call put_char


addi a0, x0, 'l'
call put_char


addi a0, x0, 'e'
call put_char


addi a0, x0, 'c'
call put_char


addi a0, x0, 't'
call put_char


addi a0, x0, ' '
call put_char


addi a0, x0, 'a'
call put_char


addi a0, x0, ' '
call put_char


addi a0, x0, 'p'
call put_char


addi a0, x0, 'r'
call put_char


addi a0, x0, 'o'
call put_char


addi a0, x0, 'g'
call put_char


addi a0, x0, 'a'
call put_char


addi a0, x0, 'm'
call put_char


addi a0, x0, ':'
call put_char

addi a0, x0, 0x0D
call put_char

addi a0, x0, 0x0A
call put_char

polling_loop:
	lw t2, 12(x0)
	andi t2, t2, 4
	bne t2, s1, polling_loop

wait_loop:
	lw t2, 12(x0)
	andi t2, t2, 4
	beq t2, s1, wait_loop

	lb t0, 0(x0) #grab rx

	addi t1, x0, '1'
	beq t1, t0, one
	
	j done

one: 	
	addi a0, x0, 'o'
	call put_char


	addi a0, x0, 'n'
	call put_char


	addi a0, x0, 'e'
	call put_char

j done

put_char: #Printing char is in a0
	sw a0, 4(x0)
	ori t0, x0, 1
	sw t0, 8(x0)
	sw x0, 8(x0)

	#delay
	addi t0, x0, 0xFF
	slii t0, t0, 8
	addi t0, t0, 0xFF

	subtract_loop:
		addi t0, t0, -1
		bne t0, x0, subtract_loop
		ret

clear_screen:
	addi a0, x0, 0x1B
	call put_char
	
	addi a0, x0, 'c'
	call put_char

	ret

done:

