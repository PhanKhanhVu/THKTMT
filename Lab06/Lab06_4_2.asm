.data 
A: .word 1, 3, 5, 7, 9, 10, 2, 4, 6, 8
.text
main:
	la   a0, A      # Lấy địa chỉ của mảng A    
	li   s2, 40     # Lấy số byte của mảng A
	li   s0, 4      # Bắt đầu từ phần tử thứ hai (index 1)

Loop1:
	bge  s0, s2, endLoop1  # Kiểm tra điều kiện dừng của Loop1 
	add  s1, a0, s0  # Lấy địa chỉ của A[i]
	lw   a1, 0(s1)   # Lấy giá trị của A[i] (key)
	addi s3, s0, -4  # j = i - 1

Loop2:
	blt  s3, zero, endLoop2  # Nếu j < 0 thì dừng
	add  s4, a0, s3   # Lấy địa chỉ của A[j]
	lw   a2, 0(s4)    # Lấy giá trị của A[j]
	bge  a1, a2, shift_right  # Nếu A[j] > key thì dời A[j]
	j    endLoop2

shift_right:
	addi s5, s3, 4    # Lấy địa chỉ của A[j+1]
	add  s6, a0, s5   # Tính địa chỉ trong mảng
	sw   a2, 0(s6)    # A[j+1] = A[j]
	addi s3, s3, -4   # j--
	j    Loop2

endLoop2:
	addi s5, s3, 4    # Lấy địa chỉ của A[j+1]
	add  s6, a0, s5   # Tính địa chỉ trong mảng
	sw   a1, 0(s6)    # A[j+1] = key
	addi s0, s0, 4    # i++
	j    Loop1

endLoop1:
	# Kết thúc chương trình
	li   a7, 10       # syscall 10 (exit)	
          ecall
