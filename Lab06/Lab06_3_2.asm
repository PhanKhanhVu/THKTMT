.data 
A: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
.text
main:
	la  	a0, A		# Lấy địa chỉ của mảng A	
	li 	s2 40 		# Lấy số byte của mảng A
	li 	s0 0		# Khởi tạo biến đếm Loop1 
Loop1:
	bge 	s0, s2, endLoop1# Kiểm tra điều kiện dừng của Loop1 
	addi   	s1, s0, 4	# Biến đếm loop 2 			
	Loop2:
		bge 	s1, s2, endLoop2
		# Kiểm tra điều kiện dừng Loop2
		add 	s4, a0, s0	# Lấy địa chỉ của A[i] 
		lw  	a2, 0(s4)	# Lấy giá trị của A[i]
		add 	s5, a0, s1	# Lấy địa chỉ của A[j]
		lw 	a3, 0(s5)	# Lấy gía trị của A[j]
		blt 	a2, a3, swap 	# So sánh để tìm phần tử lớn 
		j 	continue
		swap:
		# Đổi chỗ A[i] và A[j]
		sw	a3, 0(s4)	
		sw 	a2, 0(s5)
		continue:
		addi 	s1, s1, 4 	# Tăng biến đếm Loop2 
		j 	Loop2	
	endLoop2:
	addi 	s0, s0, 4 	# Tăng biến đếm Loop1 
	j 	Loop1
endLoop1:
 	li	a7 10
 	ecall
endMain:
