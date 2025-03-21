.data
	x: .space 32 # Chuỗi đích x, khởi tạo là buffer rỗng
y: .asciz "Khanh Vu" # Chuỗi nguồn y
.text	
strcpy:
	add s0, zero, zero # s0 = i = 0
	la a0, x # load addr x to a0
	la a1, y # y to a0
L1:
	add t1, s0, a1
	lb t2, 0(t1) 
	add t3, s0, a0 
	sb t2, 0(t3) 
	beq t2, zero, end_of_strcpy
	addi s0, s0, 1
	j L1 
end_of_strcpy:
