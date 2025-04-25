.data 
	msg1: .asciz "Nhap so nguyen duong N: "         # Thông báo nhập số
	msg2: .asciz "Tong cac chu so nhi phan cua N la: " # Thông báo kết quả
	msg3: .asciz "So N khong hop le!"              # Thông báo lỗi
	msg4: .asciz "\n"                              # Xuống dòng

.text
main:
	# In ra lời nhắc nhập số nguyên dương N
	li a7, 4              # syscall code 4: print string
	la a0, msg1           # địa chỉ chuỗi msg1
	ecall                 # gọi syscall để in lời nhắc

	# Đọc số nguyên từ bàn phím
	li a7, 5              # syscall code 5: read integer
	ecall                 # gọi syscall để nhập số
	mv s0, a0             # lưu giá trị nhập vào thanh ghi s0

# Kiểm tra tính hợp lệ của N (phải là số > 0)
check:
 	bge zero, s0, print_error  # nếu s0 <= 0 thì nhảy tới in lỗi
end_check:

	# Khởi tạo các biến để tính tổng
	li t0, 0              # t0 sẽ lưu tổng các chữ số nhị phân (số bit 1)
	li t1, 2              # t1 = 2, dùng để chia số N

# Bắt đầu vòng lặp tính tổng chữ số nhị phân
while:
	beq s0, zero, end_while   # nếu s0 == 0 thì kết thúc vòng lặp

	rem t2, s0, t1            # t2 = s0 % 2 -> lấy bit cuối (0 hoặc 1)
	add t0, t0, t2            # cộng bit vừa lấy vào tổng

	div s0, s0, t1            # s0 = s0 / 2 (dịch phải 1 bit)
	j while                  # quay lại đầu vòng lặp

end_while:
# In kết quả ra màn hình
print:
	li a7, 4              # syscall code 4: print string
	la a0, msg2           # địa chỉ chuỗi thông báo kết quả
	ecall

	li a7, 1              # syscall code 1: print integer
	mv a0, t0             # đưa tổng chữ số nhị phân vào a0
	ecall

	# In dòng mới sau kết quả
	li a7, 4
	la a0, msg4
	ecall

	j end_main           # nhảy tới kết thúc chương trình

# In thông báo lỗi nếu N không hợp lệ
print_error:
	li a7, 4
	la a0, msg3
	ecall

	# In dòng mới sau thông báo lỗi
	li a7, 4
	la a0, msg4
	ecall

# Kết thúc chương trình
end_main:
	li a7, 10             # syscall code 10: exit
	ecall
