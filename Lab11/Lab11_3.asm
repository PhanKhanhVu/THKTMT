.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014

.data
message: .asciz "\nKey scan code: "
newline: .asciz "\n"

# -----------------------------------------------------------------
# MAIN Procedure
# -----------------------------------------------------------------
.text
main:
# Load the interrupt service routine address to the UTVEC register
	la t0, handler
	csrrs zero, utvec, t0
# Set the UEIE (User External Interrupt Enable) bit in UIE register
	li t1, 0x100
	csrrs zero, uie, t1 # uie - ueie bit (bit 8)
# Set the UIE (User Interrupt Enable) bit in USTATUS register
	csrrsi zero, ustatus, 1 # ustatus - enable uie (bit 0)
# Enable the interrupt of keypad of Digital Lab Sim
	li t1, IN_ADDRESS_HEXA_KEYBOARD
	li t3, 0x80 # bit 7 = 1 to enable interrupt
	sb t3, 0(t1)

# ---------------------------------------------------------
# Loop to print a sequence numbers
# ---------------------------------------------------------
	xor s0, s0, s0 # count = s0 = 0
loop:
	addi s0, s0, 1 # count = count + 1
prn_seq:
	addi a7, zero, 1
	add a0, s0, zero # Print auto sequence number
	ecall
# Print EOL
	addi a7, zero, 4
	la a0, newline
	ecall
sleep:
	addi a7, zero, 32
	li a0, 300 # Sleep 300 ms
	ecall
	j loop
end_main:

# -----------------------------------------------------------------
# Interrupt service routine
# -----------------------------------------------------------------
handler:
# Saves the context
	addi sp, sp, -16
	sw a0, 0(sp)
	sw a7, 4(sp)
	sw t1, 8(sp)
	sw t2, 12(sp)

# Handles the interrupt
prn_msg:
	addi a7, zero, 4
	la a0, message
	ecall

get_key_code:	
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
	li a0, 0xa
	li a7, 11
	ecall

next_row:
	slli t3, t3, 1 # move to next row (shift left 1 bit)
	li t4, 0x10 # maximum row mask
	blt t3, t4, row_loop # if not finished all rows, continue row_loop

# After polling, must re-enable keypad interrupt
re_enable_interrupt:
	li t1, IN_ADDRESS_HEXA_KEYBOARD
	li t3, 0x80 # bit 7 = 1 to enable interrupt again
	sb t3, 0(t1)

	j restore

restore:
# Restores the context
	lw t2, 12(sp)
	lw t1, 8(sp)
	lw a7, 4(sp)
	lw a0, 0(sp)
	addi sp, sp, 16
# Back to the main procedure
	uret