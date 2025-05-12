.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv newline 0xa
.text
main:
	li t1, IN_ADDRESS_HEXA_KEYBOARD
	li t2, OUT_ADDRESS_HEXA_KEYBOARD

polling:
	li t3, 0x01 # start with row 1
row_loop:
	sb t3, 0(t1) # must reassign expected row
	lbu a0, 0(t2) # read scan code of key buttonư
	beq a0, zero, next_row # if no key pressed, continue to next row
print:
	li a7, 34 # print integer (hexa)
	ecall	
	li a0, newline
	li a7, 11
	ecall	 
sleep:
	li a0, 100 # sleep 100ms
	li a7, 32
	ecall
	li a0, 100 # sleep 100ms
	li a7, 32
	ecall
	li a0, 100 # sleep 100ms
	li a7, 32
	ecall
next_row:
	slli t3, t3, 1 # move to next row (shift left 1 bit)
	li t4, 0x10 # maximum row mask
	blt t3, t4, row_loop # if not finished all rows, continue row_loop
	j polling # continue polling
