.data
prompt: .asciz "Nhap chuoi ki tu : "
# ASCII into hexa
hex: .byte '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'
disk1: .space 500
disk2: .space 500
disk3: .space 500
array: .space 1024				# Store parities (results for data XOR)
string: .space 5000					# Input string
newline: .asciz "\n"  					# Ký tự xuống dòng
error_message: .asciz "Do dai chuoi khong hop le! Chieu dai cua chuoi phai chia het cho 8. Hay nhap lai.\n"
disk: .asciz "     Disk 1                Disk 2                Disk 3\n"
msg1: .asciz " --------------        --------------        --------------\n"
msg2: .asciz "|     "
msg3: .asciz "     |      "
msg4: .asciz "[[ "
msg5: .asciz "]]      "
comma: .asciz ","
message: .asciz "Try another string?"

.text
main: # Bắt đầu của chương trình chính
	la	s1, disk1			# s1 = address of disk 1
	la	s2, disk2			# s2 = address of disk 2
	la	s3, disk3			# s3 = address of disk 3
	la	a2, array			# Address of parities
	
	j	input
	nop
	
input: # Bắt đầu phần nhập liệu
	li	a7, 4				# Print " Nhap chuoi ky tu"
	la	a0, prompt
	ecall
	
	li	a7, 8				# Get string (Syscall num 8)
	la	a0, string
	li	a1, 1000			# maximum number of characters to read
	ecall
						
	mv	s0, a0				# s0 = address of input string
	

# -------------------- Check whether input string's length is multiple of 8 --------------------
length: # Kiểm tra độ dài chuỗi
	addi	t3, zero, 0 			# t3 = length
	addi	t0, zero, 0 			# t0 = index

check_char:
# Check \n?
	add	t1, s0, t0 			# t1 = address of string[i]
	lb	t2, 0(t1) 			# t2 = string[i]
	li	s4, 10				# '\n' = 10 ASCII
	beq	t2, s4, test_length 		# if string[i] = '\n', then jump test_length
	nop
	
	addi	t3, t3, 1 			# length++
	addi	t0, t0, 1			# index++
	j	check_char
	nop
	
test_length: # Kiểm tra tính hợp lệ của độ dài chuỗi
	mv	t5, t3				# t5 = string length
	beq	t0, zero, error 		# If only '\n' -> error
	
	andi	t1, t3, 0x0000000f		# t1 = (t3 & 0xF) last byte
	bne	t1, zero, test1			# if (t3 & 0xF) != 0, then jump 'test1'
	j	input_prompt			# else jump 'block1'
	nop
test1:
	li	s11, 8				# s11 = 8
	beq	t1, s11, input_prompt		# if (t3 & 0xF) == 8, then jump 'block1'
	j	error				# else jump 'error'
	nop
	
error: # Xử lý lỗi độ dài không hợp lệ
	li	a7, 4				# Print error_message
	la	a0, error_message		
	ecall					
	
	j	input
	nop
	
input_prompt:
	li	a7, 4
	la	a0, disk
	ecall

	li	a7, 4
	la	a0, msg1
	ecall
	j	block1

HEX: # Nhãn: Thủ tục chuyển đổi một byte sang 2 ký tự hexa ASCII
# -------------------- Get parities --------------------
# Đầu vào s8 chứa byte parity, chuyển từ số sang hexa (ASCII)
	li	t4, 7				# Khởi tạo biến đếm t4 = 7 (cho 8 nibble, nhưng chỉ in 2 cuối)
	
loopH:
	blt	t4, zero, endloopH		# t4 < 0  -> endloop
	slli	s6, t4, 2			# s6 = t4*4
	srl	a0, s8, s6			# a0 = s8 >> s6
	andi	a0, a0, 0x0000000f 		# Get the last byte of a0
	la	s7, hex 			# s7 = adrress of hex
	add	s7, s7, a0
	li	a4, 1
	bgt	t4, a4, nextc			# if t4 > 1 , jump to nextC
	lb	a0, 0(s7) 			# Print hex[a0]
	li	a7, 11
	ecall

nextc:
	addi	t4, t4, -1			# t4 --
	j	loopH
	nop

endloopH:
	jr	ra
	nop
	
#------------------------------ RAID5 SIMULATION------------------------------------
RAID5: # Đánh dấu bắt đầu phần mô phỏng RAID5 (không được nhảy trực tiếp đến)
# Block 1 : byte parity is stored in disk 3
# Block 2 : byte parity is stored in disk 2
# Block 3 : byte parity is stored in disk 1
block1:
# Function block1: First 2 4-byte blocks are stored in disk1, disk2; parity is stored in disk3
	addi	t0, zero, 0
	addi	s9, zero, 0
	addi	s8, zero, 0
	la	s1, disk1
	la	s2, disk2
	la	a2, array
	
print11: # In phần mở đầu cho Disk 1
	li	a7, 4
	la 	a0, msg2
	ecall
	
b11: # Vòng lặp xử lý byte cho block1
# Store into disk1					
	lb	t1, 0(s0)			# t1 = first value of input string
	addi	t3, t3, -1			# t3 = length - 1
	sb	t1, (s1)			# store t1 into disk1
b12: # Xử lý byte thứ hai cho cặp
# Store ịnto disk2
	addi	s5, s0, 4			# s5 = s0 + 4
	lb	t2, 0(s5)			# t2 = string[5]
	addi	t3, t3, -1			# t3 = t3  - 1
	sb	t2, 0(s2)			# store t2 into disk2
b13: # Tính và lưu parity
# Store XOR result into disk3
	xor	a3, t1, t2			# a3 = t1 xor t2
	sw	a3, 0(a2)			# Store a3 into a2
	addi	a2, a2, 4			# Parity string
	addi	t0, t0, 1			# Next char
	addi	s0, s0, 1			# Eliminate considered char, eg : "D"
	addi	s1, s1, 1			# Address of disk 1 + 1
	addi	s2, s2, 1			# Address of disk 2 + 1
	li	a6, 3				# a6 = 3
	bgt	t0, a6, reset			# 4 byte are considered --> reset disk
	j	b11
	nop
reset: # Reset con trỏ buffer disk để chuẩn bị in
	la 	s1, disk1
	la	s2, disk2
	
print12: # Vòng lặp in nội dung buffer disk1
	lb	a0, 0(s1)			# Print each char in disk1
	li	a7, 11				# syscall 11 (print char)
	ecall
	addi	s9, s9, 1			# Tăng biến đếm s9 (số ký tự đã in của disk1)
	addi	s1, s1, 1			# Tăng con trỏ buffer disk1
	bgt	s9, a6, next11			# Print 4 times --> end priting disk1
	j	print12
	nop
	
next11:	# Chuẩn bị in disk2		
	li	a7, 4
	la	a0, msg3
	ecall
	li	a7, 4
	la	a0, msg2
	ecall
	
print13: # Vòng lặp in nội dung buffer disk2
	lb	a0, 0(s2)			# Nạp byte từ buffer disk2 (s2) vào a0
	li	a7, 11				# syscall 11 (print char)
	ecall
	addi	s8, s8, 1			# Tăng biến đếm s8 (số ký tự đã in của disk2)
	addi	s2, s2, 1			# Tăng con trỏ buffer disk2 (s2)
	bgt	s8, a6, next12			# Print 4 times --> end printing disk2
	j	print13
	nop
	
next12:	# Chuẩn bị in parity (disk3)
	li	a7, 4
	la	a0, msg3
	ecall
	li	a7, 4
	la	a0, msg4
	ecall
	la	a2, array			# a2 = address of parity string[i]
	addi	s9, zero, 0			# Reset biến đếm s9 = 0 (cho việc in parity)
	
print14: # Convert parity string --> ASCII and print
	lb	s8, 0(a2)			# s8 = adress of parity string[i]
	jal	HEX
	nop
	li	a7, 4
	la	a0, comma
	ecall
	
	addi	s9, s9, 1			# Parity string's index + 1
	addi	a2, a2, 4			# Tăng con trỏ mảng parity (a2) lên 4 byte
	li	a5, 2				# Nạp giá trị 2 vào a5 (để in 3 dấu phẩy cho 4 parity)
	bgt	s9, a5, endisk1			# Print first 3 parities with ','
	j	print14
endisk1: # In byte parity cuối cùng (không có dấu phẩy sau)
	lb	s8, 0(a2)			# Nạp byte parity cuối cùng vào s8
	jal	HEX
	nop
	li	a7, 4
	la	a0, msg5
	ecall
	
	li	a7, 4
	la	a0, newline
	ecall
	beq	t3, zero, exit1			# If string length = 0 --> exit
	j	block2				# else --> block2
	nop
	
#----------------------------------------
block2:	# Funtion block2: Next 2 4-byte blocks are stored in disk1, disk3; parity is stored in disk2
	la	a2, array			# Nạp địa chỉ mảng parity 'array' vào a2 (parity cho Disk2)
	la	s1, disk1			# Nạp địa chỉ buffer disk1 vào s1
	la	s3, disk3			# Nạp địa chỉ buffer disk3 vào s3
	addi	s0, s0, 4			# Tăng con trỏ chuỗi đầu vào (s0) lên 4 (bỏ qua 4 byte đã xử lý ở block1 cho disk1/disk2)
	addi	t0, zero, 0			# Reset biến đếm vòng lặp t0 = 0
		
print21: # print "|     "
	li	a7, 4
	la	a0, msg2
	ecall

b21: # Store 4 bytes into disk1
	lb	t1, 0(s0)			# Nạp byte từ chuỗi đầu vào (s0) vào t1 (cho Disk1)
	addi	t3, t3, -1			# string_length -- 
	sb	t1, 0(s1)			# Lưu byte t1 vào buffer disk1
b23: # Store next 4 bytes into disk3
	addi	s5, s0, 4			# string addr + 4
	lb	t2, 0(s5)
	addi	t3, t3, -1			# length -- 
	sb	t2, 0(s3)
	
b22: # Store XOR result into disk2
	xor	a3, t1, t2			# Tính XOR của t1 và t2 -> a3 (parity)
	sw	a3, 0(a2)			# Lưu byte parity a3 (như word) vào mảng 'array' (cho Disk2)
	addi	a2, a2, 4			# Tăng con trỏ mảng parity (a2)
	addi	t0, t0, 1			# Tăng biến đếm vòng lặp t0
	addi	s0, s0, 1			# Tăng con trỏ chuỗi đầu vào (s0)
	addi	s1, s1, 1			# Tăng con trỏ buffer disk1 (s1)
	addi	s3, s3, 1			# Tăng con trỏ buffer disk3 (s3)
	bgt	t0, a6, reset2  		# Nếu t0 > 3, nhảy đến 'reset2'
	j	b21
	nop
reset2: # Reset disks
	la	s1, disk1			# Nạp lại địa chỉ buffer disk1 vào s1
	la	s3, disk3			# Nạp lại địa chỉ buffer disk3 vào s3
	addi	s9, zero, 0			# Reset biến đếm s9 = 0 (cho việc in)
	
print22: # In nội dung buffer disk1
	lb	a0, 0(s1)			# Nạp byte từ buffer disk1 (s1) vào a0
	li	a7, 11				# syscall 11 (print char)
	ecall
	addi	s9, s9, 1			# Tăng biến đếm s9
	addi	s1, s1, 1			# Tăng con trỏ buffer disk1 (s1)
	bgt	s9, a6, next21 			# Nếu s9 > 3, nhảy đến 'next21'
	j	print22
	nop
	
next21:	# Chuẩn bị in parity (Disk2)
	li	a7, 4
	la	a0, msg3
	ecall
	la	a2, array			# Nạp lại địa chỉ mảng parity 'array' vào a2
	addi	s9, zero, 0			# Reset biến đếm s9 = 0
	li	a7, 4
	la	a0, msg4
	ecall
	
print23: # Vòng lặp in các byte parity (Disk2)
	lb	s8, 0(a2)			# Nạp byte parity từ mảng (a2) vào s8
	jal	HEX
	nop
	li	a7, 4
	la	a0, comma
	ecall
	addi	s9, s9, 1			# Tăng biến đếm s9
	addi	a2, a2, 4			# Tăng con trỏ mảng parity (a2)
	bgt	s9, a5, next22			# Nếu s9 > 2, nhảy đến 'next22'
	j	print23
	nop
		
next22:	# In byte parity cuối cùng (Disk2)
	lb	s8, (a2)			# Nạp byte parity cuối cùng vào s8
	jal	HEX
	nop
	
	li	a7, 4
	la	a0, msg5
	ecall
	
	li	a7, 4
	la	a0, msg2
	ecall
	addi	s8, zero, 0			# Reset biến đếm s8 = 0 (cho việc in Disk3)
	
print24: # Vòng lặp in nội dung buffer disk3
	lb	a0, 0(s3)			# Nạp byte từ buffer disk3 (s3) vào a0
	li	a7, 11
	ecall
	addi	s8, s8, 1			# Tăng biến đếm s8
	addi	s3, s3, 1			# Tăng con trỏ buffer disk3 (s3)
	bgt	s8, a6, endisk2 		# Nếu s8 > 3, nhảy đến 'endisk2'
	j	print24
	nop

endisk2: # Kết thúc in block2
	li	a7, 4
	la	a0, msg3
	ecall
	li	a7, 4
	la	a0, newline
	ecall
	beq	t3, zero, exit1
	j	block3
	nop
	
#--------------------------------
block3:	# Funtion block3: Next 2 4-byte blocks are stored in disk2, disk3; parity is stored in disk1
	la	a2, array
	la	s2, disk2
	la	s3, disk3
	addi	s0, s0, 4			# Tăng con trỏ chuỗi đầu vào (s0) lên 4
	addi	t0, zero, 0			# Reset biến đếm vòng lặp t0 = 0
print31: # Print '[['
	li	a7, 4
	la	a0, msg4
	ecall
b32: # Byte stored in Disk 2				
	lb	t1, 0(s0)			# Nạp byte từ chuỗi đầu vào (s0) vào t1 (cho Disk2)
	addi	t3, t3, -1			# string_length --
	sb	t1, 0(s2)			# Lưu byte t1 vào buffer disk2
b33: # Store in Disk 3 
	addi	s5, s0, 4			# Tính địa chỉ byte tương ứng (s0+4)
	lb	t2, 0(s5)			# Nạp byte từ (s0+4) vào t2 (cho Disk3)
	addi	t3, t3, -1			# Giảm độ dài còn lại t3
	sb	t2, 0(s3)			# Lưu byte t2 vào buffer disk3
	
b31: # Store XOR result into disk1
	xor	a3, t1, t2			# Tính XOR của t1 và t2 -> a3 (parity)
	sw	a3, 0(a2)			# Lưu byte parity a3 (như word) vào mảng 'array' (cho Disk1)
	addi	a2, a2, 4			# Tăng con trỏ mảng parity (a2)
	addi	t0, t0, 1			# Tăng biến đếm vòng lặp t0
	addi	s0, s0, 1			# Tăng con trỏ chuỗi đầu vào (s0)
	addi	s2, s2, 1			# Tăng con trỏ buffer disk2 (s2)
	addi	s3, s3, 1			# Tăng con trỏ buffer disk3 (s3)
	bgt	t0, a6, reset3			# Nếu t0 > 3, nhảy đến 'reset3'
	j	b32
	nop
reset3: # Reset con trỏ buffer disk để chuẩn bị in
	la	s2, disk2
	la	s3, disk3
	la	a2, array
	addi	s9, zero, 0			# Index - Reset biến đếm s9 = 0 (cho việc in)
	
print32: # Vòng lặp in các byte parity (Disk1)
	lb	s8, 0(a2)			# Nạp byte parity từ mảng (a2) vào s8
	jal	HEX
	nop
	li	a7, 4
	la	a0, comma
	ecall
	
	addi	s9, s9, 1			# Tăng biến đếm s9
	addi	a2, a2, 4			# Tăng con trỏ mảng parity (a2)
	bgt	s9, a5, next31			# Nếu s9 > 2, nhảy đến 'next31'
	j	print32
	nop
	
next31: # In byte parity cuối cùng (Disk1)
	lb	s8, 0(a2)			# Nạp byte parity cuối cùng vào s8
	jal	HEX
	nop

	li	a7, 4
	la	a0, msg5
	ecall
	li	a7, 4
	la	a0, msg2
	ecall
	addi	s9, zero, 0
	
print33: # Vòng lặp in nội dung buffer disk2
	lb	a0, 0(s2)			# Nạp byte từ buffer disk2 (s2) vào a0
	li	a7, 11				# syscall 11 (print char)
	ecall
	addi	s9, s9, 1			# Tăng biến đếm s9
	addi	s2, s2, 1			# Tăng con trỏ buffer disk2 (s2)
	bgt	s9, a6, next32 			# Nếu s9 > 3, nhảy đến 'next32'
	j	print33
	nop
	
next32: # Chuẩn bị in Disk3
	addi	s9, zero, 0			# Reset biến đếm s9 (không thực sự dùng ngay sau)
	addi	s8, zero, 0			# Reset biến đếm s8 (cho việc in Disk3)
	li	a7, 4
	la	a0, msg3
	ecall
	li	a7, 4
	la	a0, msg2
	ecall
print34: # Vòng lặp in nội dung buffer disk3
	lb	a0, (s3)			# Nạp byte từ buffer disk3 (s3) vào a0
	li	a7, 11				# syscall 11 (print char)
	ecall
	addi	s8, s8, 1			# Tăng biến đếm s8
	addi	s3, s3, 1			# Tăng con trỏ buffer disk3 (s3)
	bgt	s8, a6, endisk3 		# a6 is still 3 - Nếu s8 > 3, nhảy đến 'endisk3'
	j	print34
	nop

endisk3: # Kết thúc in block3
	li	a7, 4
	la	a0, msg3
	ecall
	
	li	a7, 4
	la	a0, newline
	ecall
	beq	t3, zero, exit1			# Nếu độ dài còn lại t3 = 0, nhảy đến 'exit1'
	j	nextloop 			# Nhảy đến 'nextloop' để xử lý cụm 3 block tiếp theo
	nop

#-----------End first 6 4-byte blocks----------------------------- (Thực ra là 3 block 8 byte = 24 byte)
#-----------Next 6 4-byte blocks---------------------------------- (Tương tự, là các cụm 24 byte tiếp theo)

nextloop: # Bắt đầu một chu kỳ mới của 3 block RAID
	addi	s0, s0, 4			# Tăng con trỏ chuỗi đầu vào (s0) lên 4 (để block1 tiếp theo bắt đầu từ đoạn 8 byte mới)
	j	block1
	nop
	
exit1: # Print ------ and end RAID simulation
	li	a7, 4
	la	a0, msg1
	ecall
	j	ask
	nop
	
#--------------------END RAID 5 SIMULATION-------------------------


#--------------------TRY ANOTHER STRING----------------------------
ask: # Hỏi người dùng có muốn thử chuỗi khác không
	li	a7, 50				# syscall 50 (message dialog yes/no/cancel)
	la	a0, message
	ecall
	beq	a0, zero, clear			# a0: 0 = YES; 1 = NO; 2 = CANCEL - Nếu a0 = 0 (Yes), nhảy đến 'clear'
	nop
	j	exit				# Nếu không phải Yes (No hoặc Cancel), nhảy đến 'exit'
	nop
	
# clear function: Return string to original state
clear: # Xóa nội dung chuỗi đầu vào cũ để chuẩn bị nhập mới
	la	s0, string			# Nạp địa chỉ của buffer 'string' vào s0
	add	s3, s0, t5			# Tính địa chỉ cuối của chuỗi cũ (string + length_old_string)
	li	t1, 0				# Set t1 = 0

goAgain: # Return string to empty state to start again
	sb	t1, (s0)			# Ghi byte null (t1) vào địa chỉ s0 trong buffer 'string'
	nop
	addi	s0, s0, 1			# Tăng con trỏ s0 lên byte tiếp theo
	bge	s0, s3, input 			# Nếu s0 >= s3 (đã xóa hết), nhảy đến 'input'
	nop
	j	goAgain
	nop

#-----Exit program----------
exit:
	li	a7, 10
	ecall
