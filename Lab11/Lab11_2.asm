.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
.data
message: .asciz "Someone's presed a button.\n"
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
# No-end loop, main program, to demo the effective of interrupt
# ---------------------------------------------------------
loop:
	nop
	nop
	nop
	j loop
end_main:
# -----------------------------------------------------------------
# Interrupt service routine
# -----------------------------------------------------------------
handler:
	# ebreak # Can pause the execution to observe registers
	# Saves the context
	addi sp, sp, -8
	sw a0, 0(sp)
	sw a7, 4(sp)
	# Handles the interrupt
	# Shows message in Run I/O
	li a7, 4
	la a0, message
	ecall
	# Restores the context
	lw a7, 4(sp)
	lw a0, 0(sp)
	addi sp, sp, 8
	# Back to the main procedure
	uret
