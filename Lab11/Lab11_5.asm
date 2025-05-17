.data
	message: .asciz "Exception occurred.\n"
.text
main:
try:
	la t0, catch
	csrrw zero, utvec, t0 # Set utvec to the handler address
	csrrsi zero, ustatus, 1 # Set interrupt enable bit in ustatus
	lw zero, 0 
finally:
	li a7, 10 # Exit the program
	ecall
catch:
	# Show message
	li a7, 4
	la a0, message
	ecall
	# Since uepc contains address of the error instruction
	# Need to load finally address to uepc
	la t0, finally
	csrrw zero, uepc, t0
	uret
