.data 
	String_s1: .space 500           # Vùng nhớ để lưu chuỗi thứ nhất (tối đa 500 ký tự)
	String_s2: .space 500           # Vùng nhớ để lưu chuỗi thứ hai (tối đa 500 ký tự)
	msg1: .asciz "Nhap chuoi thu nhat: "     # Thông báo yêu cầu nhập chuỗi 1
	msg2: .asciz "Nhap chuoi thu hai: "      # Thông báo yêu cầu nhập chuỗi 2
	msg3: .asciz "Hai xau ki tu giong nhau!" # Thông báo nếu hai chuỗi giống nhau
	msg4: .asciz "Hai xau ki tu khac nhau!"  # Thông báo nếu hai chuỗi khác nhau

.text
main:
	# In ra thông báo nhập chuỗi thứ nhất
	li a7, 4
	la a0, msg1
	ecall

	# Nhập chuỗi thứ nhất từ bàn phím
	li a7, 8         # syscall 8: đọc chuỗi
	li a1, 500       # độ dài tối đa
	la a0, String_s1
	ecall

	# In ra thông báo nhập chuỗi thứ hai
	li a7, 4
	la a0, msg2
	ecall

	# Nhập chuỗi thứ hai từ bàn phím
	li a7, 8
	li a1, 500
	la a0, String_s2
	ecall

	# Tính độ dài thực tế của chuỗi 1 (bỏ qua ký tự newline '\n')
	li s1, 0              # s1: độ dài chuỗi 1
	la t1, String_s1      # t1: con trỏ duyệt chuỗi 1
	li t4, '\n'           # t4: ký tự xuống dòng để kiểm tra kết thúc nhập

while1:
	lb t3, 0(t1)          # t3 = *t1: lấy 1 byte từ chuỗi
	beqz t3, end_white1   # nếu t3 == 0 (null terminator), kết thúc đếm
	beq t3, t4, end_white1 # nếu t3 == '\n', kết thúc đếm
	addi s1, s1, 1        # tăng độ dài chuỗi
	addi t1, t1, 1        # sang ký tự tiếp theo
	j while1

end_white1:

	# Tính độ dài thực tế của chuỗi 2
	li s2, 0
	la t2, String_s2
while2:
	lb t3, 0(t2)
	beqz t3, end_white2
	beq t3, t4, end_white2
	addi s2, s2, 1
	addi t2, t2, 1
	j while2

end_white2:

# So sánh 2 chuỗi:
check:
	bne s1, s2, false_print     # Nếu độ dài khác → chắc chắn không giống

	# Duyệt từng ký tự của 2 chuỗi để so sánh
	li t0, 0        # t0: index
	la t1, String_s1
	la t2, String_s2

compare_loop:
	beq t0, s1, true_print      # Nếu đã duyệt hết và không sai khác → giống nhau

	lb t3, 0(t1)    # Lấy ký tự tại vị trí t0 từ chuỗi 1
	lb t4, 0(t2)    # Lấy ký tự tại vị trí t0 từ chuỗi 2

	# Chuyển t3 sang chữ thường nếu là chữ hoa ('A' <= t3 <= 'Z')
	li t5, 'A'
	li t6, 'Z'
	blt t3, t5, skip_lower1     # Nếu t3 < 'A' → không cần chuyển
	bgt t3, t6, skip_lower1     # Nếu t3 > 'Z' → không cần chuyển
	addi t3, t3, 32             # Chuyển sang thường: 'A' + 32 = 'a'

skip_lower1:

	# Chuyển t4 sang chữ thường nếu là chữ hoa
	li t5, 'A'
	li t6, 'Z'
	blt t4, t5, skip_lower2
	bgt t4, t6, skip_lower2
	addi t4, t4, 32

skip_lower2:

	bne t3, t4, false_print     # Nếu ký tự sau chuyển khác nhau → không giống

	# Tiếp tục vòng lặp: tăng index và con trỏ
	addi t0, t0, 1
	addi t1, t1, 1
	addi t2, t2, 1
	j compare_loop

# In ra kết quả nếu chuỗi giống nhau
true_print:
	li a7, 4
	la a0, msg3
	ecall
	j end_main

# In ra kết quả nếu chuỗi khác nhau
false_print:
	li a7, 4
	la a0, msg4
	ecall

# Kết thúc chương trình
end_main:
	li a7, 10
	ecall

