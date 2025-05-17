.data
	overflow_msg: .asciz "overflow detected. Program terminated.\n"
	overflow_header: .asciz "User input is out of range\n"
	sum_msg: .asciz "Sum of the 2 numbers:\n"
.text
main:
	# init
	li a7, 5
	ecall
	mv s1, a0
	
	li a7, 5
	ecall
	mv s2, a0
	
	li t0, 0            # no overflow initially

	# Setup interrupt handler
	la t1, handler
	csrrw zero, utvec, t1
	csrrsi zero, ustatus, 1   # enable global interrupt
	csrrsi zero, uie, 0x1     # enable software interrupt

	# Add two numbers
	add s3, s1, s2

	# Check overflow
	xor t1, s1, s2
	blt t1, zero, print        # different signs ? no overflow
	blt s1, zero, neg
	bge s3, s1, print           # normal addition ? no overflow

	j overflow

neg:
	bge s1, s3, print           # normal subtraction ? no overflow

overflow:
	li t0, 1                   # overflow detected

	# trigger interrupt
	csrr t1, uip
	ori t1, t1, 0x1            # set USIP (bit 0)
	csrrw zero, uip, t1

print:
	mv a1, s3
	la a0, sum_msg
	li a7, 56
	ecall
	li a7, 10                  # print program
	ecall

# ---------------------------------------------------------
# Interrupt service routine
# ---------------------------------------------------------
handler:
	addi sp, sp, -8
	sw ra, 0(sp)
	sw a0, 4(sp)


	la a0, overflow_header
	la a1, overflow_msg
	li a7, 59
	ecall

	li a7, 10
	ecall

	lw a0, 4(sp)
	lw ra, 0(sp)
	addi sp, sp, 8

	uret
