.data 
	msg1: .asciz "Nhap so phan tu cua mang: "     # Thông báo nhập số phần tử
	msg2: .asciz "Nhap phan tu: "                 # Thông báo nhập từng phần tử (chưa dùng trong code)
	msg3: .asciz "Tong cac phan tu am trong mang la: "  # Thông báo in tổng phần tử âm
	msg4: .asciz "Tong cac phan tu duong tron mang la: " # Thông báo in tổng phần tử dương
	msg5: .asciz "\n"                             # Xuống dòng
	msg6: .asciz "Do dai mang khong hop le!"      # Thông báo khi số lượng phần tử không hợp lệ
.text 
main:
	# In thông báo yêu cầu nhập số phần tử
	li a7, 4
	la a0, msg1
	ecall

	# Nhập số lượng phần tử từ bàn phím
	li a7, 5
	ecall
	addi s0, a0, 0	# Lưu số phần tử vào thanh ghi s0

check_n:
	bge zero,s0, print_error	# Nếu s0 <= 0 thì nhảy đến in thông báo lỗi

	# Khởi tạo các biến đếm và biến tổng
	li t0, 0 	# Biến đếm số phần tử đã nhập
	li t1, 0	# Biến tạm để lưu từng phần tử khi nhập
	li s1, 0	# Tổng các phần tử âm
	li s2, 0	# Tổng các phần tử dương

Loop:
	beq t0, s0, end_Loop	# Nếu đã nhập đủ phần tử thì thoát khỏi vòng lặp

	# Nhập từng phần tử của mảng
	li a7, 5
	ecall
	addi t1, a0, 0	# Lưu phần tử vào t1

if:
	blt  t1, zero, else	# Nếu phần tử < 0 thì nhảy đến nhánh else (âm)
then:
	add s2, s2, t1	# Nếu phần tử >= 0 thì cộng vào tổng dương
	j continue
else: 
	add s1, s1, t1	# Nếu phần tử âm thì cộng vào tổng âm

continue:
	addi t0, t0, 1	# Tăng biến đếm lên 1
	j Loop			# Quay lại đầu vòng lặp

end_Loop:
print:
	# In tổng các phần tử âm trong mảng
	li a7, 4
	la a0, msg3
	ecall
	li a7, 1
	mv a0, s1
	ecall

	# In xuống dòng
	li a7, 4
	la a0, msg5
	ecall

	# In tổng các phần tử dương trong mảng
	li a7, 4
	la a0, msg4
	ecall
	li a7, 1
	mv a0, s2
	ecall

	j end_main		# Kết thúc chương trình

print_error:
	# In thông báo lỗi nếu số lượng phần tử không hợp lệ
	li a7, 4
	la a0, msg6
	ecall

end_main:
	li a7, 10		# Exit syscall
	ecall
