.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
# Receive row and column of the key pressed, 0 if not key pressed
# Eg. equal 0x11, means that key button 0 pressed.
# Eg. equal 0x28, means that key button D pressed.
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv newline 0xa
.eqv RED 0xFF0000
.eqv BLACK 0x0
.eqv MONITOR_SCREEN_ADDR 0x10000000 #global data

.data
k11:	.word RED BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK
k21:	.word BLACK RED BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK
k41:	.word BLACK BLACK RED BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK
k81:	.word BLACK BLACK BLACK RED BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK
k12:	.word BLACK BLACK BLACK BLACK RED BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK
k22:	.word BLACK BLACK BLACK BLACK BLACK RED BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK
k42:	.word BLACK BLACK BLACK BLACK BLACK BLACK RED BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK
k82:	.word BLACK BLACK BLACK BLACK BLACK BLACK BLACK RED BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK
k14:	.word BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK RED BLACK BLACK BLACK BLACK BLACK BLACK BLACK
k24:	.word BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK RED BLACK BLACK BLACK BLACK BLACK BLACK
k44:	.word BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK RED BLACK BLACK BLACK BLACK BLACK
k84:	.word BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK RED BLACK BLACK BLACK BLACK
k18:	.word BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK RED BLACK BLACK BLACK
k28:	.word BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK RED BLACK BLACK
k48:	.word BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK RED BLACK
k88:	.word BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK BLACK RED

.text

main:
	li t1, IN_ADDRESS_HEXA_KEYBOARD
	li t2, OUT_ADDRESS_HEXA_KEYBOARD

polling:
	li t3, 0x01 # start with row 1
row_loop:
	sb t3, 0(t1) # must reassign expected row
	lb a0, 0(t2) # read scan code of key button
	beqz a0, next_row # if no key pressed, continue to next row
print:
	li a7, 34 # print integer (hexa)
	ecall	
	
	j convert
	
	
	
		 
sleep:
	li a0, 100 # sleep 100ms
	li a7, 32
	ecall
next_row:
	slli t3, t3, 1 # move to next row (shift left 1 bit)
	li t4, 0x10 # maximum row mask
	blt t3, t4, row_loop # if not finished all rows, continue row_loop
	j polling # continue polling
	
	
convert:
	li t5, 0x11
	beq a0, t5, key11
	
	li t5, 0x21
	beq a0, t5, key21
	
	li t5, 0x41
	beq a0, t5, key41
	
	li t5, 0xFFFFFF81
	beq a0, t5, key81
	
	li t5, 0x12
	beq a0, t5, key12
	
	li t5, 0x22
	beq a0, t5, key22
	
	li t5, 0x42
	beq a0, t5, key42
	
	li t5, 0xFFFFFF82
	beq a0, t5, key82
	
	li t5, 0x14
	beq a0, t5, key14
	
	li t5, 0x24
	beq a0, t5, key24
	
	li t5, 0x44
	beq a0, t5, key44
	
	li t5, 0xFFFFFF84
	beq a0, t5, key84
	
	li t5, 0x18
	beq a0, t5, key18
	
	li t5, 0x28
	beq a0, t5, key28
	
	li t5, 0x48
	beq a0, t5, key48
	
	li t5, 0xFFFFFF88
	beq a0, t5, key88

	key11:
		la s0, k11
		li s1, MONITOR_SCREEN_ADDR
		li s2, 16
	copy_loop11:
		lw s3, 0(s0)
		sw s3, 0(s1)
		addi s0, s0, 4
		addi s1, s1, 4
		addi s2, s2, -1
		bnez s2, copy_loop11
		j polling
	
	key21:
		la s0, k21
		li s1, MONITOR_SCREEN_ADDR
		li s2, 16
	copy_loop21:
		lw s3, 0(s0)
		sw s3, 0(s1)
		addi s0, s0, 4
		addi s1, s1, 4
		addi s2, s2, -1
		bnez s2, copy_loop21
		j polling
	
	key41:
		la s0, k41
		li s1, MONITOR_SCREEN_ADDR
		li s2, 16
	copy_loop41:
		lw s3, 0(s0)
		sw s3, 0(s1)
		addi s0, s0, 4
		addi s1, s1, 4
		addi s2, s2, -1
		bnez s2, copy_loop41
		j polling
	
	key81:
		la s0, k81
		li s1, MONITOR_SCREEN_ADDR
		li s2, 16
	copy_loop81:
		lw s3, 0(s0)
		sw s3, 0(s1)
		addi s0, s0, 4
		addi s1, s1, 4
		addi s2, s2, -1
		bnez s2, copy_loop81
		j polling
	
	key12:
		la s0, k12
		li s1, MONITOR_SCREEN_ADDR
		li s2, 16
	copy_loop12:
		lw s3, 0(s0)
		sw s3, 0(s1)
		addi s0, s0, 4
		addi s1, s1, 4
		addi s2, s2, -1
		bnez s2, copy_loop12
		j polling
	
	key22:
		la s0, k22
		li s1, MONITOR_SCREEN_ADDR
		li s2, 16
	copy_loop22:
		lw s3, 0(s0)
		sw s3, 0(s1)
		addi s0, s0, 4
		addi s1, s1, 4
		addi s2, s2, -1
		bnez s2, copy_loop22
		j polling
	
	key42:
		la s0, k42
		li s1, MONITOR_SCREEN_ADDR
		li s2, 16
	copy_loop42:
		lw s3, 0(s0)
		sw s3, 0(s1)
		addi s0, s0, 4
		addi s1, s1, 4
		addi s2, s2, -1
		bnez s2, copy_loop42
		j polling
	
	key82:
		la s0, k82
		li s1, MONITOR_SCREEN_ADDR
		li s2, 16
	copy_loop82:
		lw s3, 0(s0)
		sw s3, 0(s1)
		addi s0, s0, 4
		addi s1, s1, 4
		addi s2, s2, -1
		bnez s2, copy_loop82
		j polling
	
	key14:
		la s0, k14
		li s1, MONITOR_SCREEN_ADDR
		li s2, 16
	copy_loop14:
		lw s3, 0(s0)
		sw s3, 0(s1)
		addi s0, s0, 4
		addi s1, s1, 4
		addi s2, s2, -1
		bnez s2, copy_loop14
		j polling
	
	key24:
		la s0, k24
		li s1, MONITOR_SCREEN_ADDR
		li s2, 16
	copy_loop24:
		lw s3, 0(s0)
		sw s3, 0(s1)
		addi s0, s0, 4
		addi s1, s1, 4
		addi s2, s2, -1
		bnez s2, copy_loop24
		j polling
	
	key44:
		la s0, k44
		li s1, MONITOR_SCREEN_ADDR
		li s2, 16
	copy_loop44:
		lw s3, 0(s0)
		sw s3, 0(s1)
		addi s0, s0, 4
		addi s1, s1, 4
		addi s2, s2, -1
		bnez s2, copy_loop44
		j polling
	
	key84:
		la s0, k84
		li s1, MONITOR_SCREEN_ADDR
		li s2, 16
	copy_loop84:
		lw s3, 0(s0)
		sw s3, 0(s1)
		addi s0, s0, 4
		addi s1, s1, 4
		addi s2, s2, -1
		bnez s2, copy_loop84
		j polling
	
	key18:
		la s0, k18
		li s1, MONITOR_SCREEN_ADDR
		li s2, 16
	copy_loop18:
		lw s3, 0(s0)
		sw s3, 0(s1)
		addi s0, s0, 4
		addi s1, s1, 4
		addi s2, s2, -1
		bnez s2, copy_loop18
		j polling
	
	key28:
		la s0, k28
		li s1, MONITOR_SCREEN_ADDR
		li s2, 16
	copy_loop28:
		lw s3, 0(s0)
		sw s3, 0(s1)
		addi s0, s0, 4
		addi s1, s1, 4
		addi s2, s2, -1
		bnez s2, copy_loop28
		j polling
	
	key48:
		la s0, k48
		li s1, MONITOR_SCREEN_ADDR
		li s2, 16
	copy_loop48:
		lw s3, 0(s0)
		sw s3, 0(s1)
		addi s0, s0, 4
		addi s1, s1, 4
		addi s2, s2, -1
		bnez s2, copy_loop48
		j polling
	
	key88:
		la s0, k88
		li s1, MONITOR_SCREEN_ADDR
		li s2, 16
	copy_loop88:
		lw s3, 0(s0)
		sw s3, 0(s1)
		addi s0, s0, 4
		addi s1, s1, 4
		addi s2, s2, -1
		bnez s2, copy_loop88
		j polling
