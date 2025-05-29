.data
prompt: .asciz "Nhap chuoi ki tu : "     # Chuỗi thông báo yêu cầu người dùng nhập ký tự.
# ASCII into hexa
hex: .byte '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' # Mảng các ký tự ASCII cho hệ thập lục phân (0-9, a-f), dùng để chuyển đổi số sang dạng hex.
disk1: .space 4                      # Cấp phát 4 byte không gian cho bộ đệm "Đĩa 1" (tạm thời lưu 4 byte dữ liệu).
disk2: .space 4                      # Cấp phát 4 byte không gian cho bộ đệm "Đĩa 2".
disk3: .space 4                      # Cấp phát 4 byte không gian cho bộ đệm "Đĩa 3".
array: .space 32                     # Cấp phát 32 byte không gian để lưu các giá trị parity (mỗi parity là 4 byte, tổng cộng 8 parity).
string: .space 5000                  # Cấp phát 5000 byte không gian để lưu chuỗi ký tự nhập vào từ người dùng.
newline: .asciz "\n"                  # Ký tự xuống dòng (ASCII 10).
error_message: .asciz "Do dai chuoi khong hop le! Chieu dai cua chuoi phai chia het cho 8. Hay nhap lai.\n" # Thông báo lỗi khi độ dài chuỗi không hợp lệ.
disk: .asciz "       Disk 1              Disk 2              Disk 3\n" # Tiêu đề hiển thị cho các đĩa.
msg1: .asciz " --------------        --------------        --------------\n" # Dòng phân cách hiển thị.
msg2: .asciz "|      "                  # Phần mở đầu của khung hiển thị dữ liệu đĩa.
msg3: .asciz "       |       "          # Phần kết thúc của khung hiển thị dữ liệu đĩa, và phần mở đầu cho đĩa tiếp theo.
msg4: .asciz "[[ "                  # Ký tự mở đầu cho phần hiển thị parity.
msg5: .asciz "]]      "                  # Ký tự kết thúc cho phần hiển thị parity.
comma: .asciz ","                    # Ký tự dấu phẩy, dùng để phân cách các byte parity.
message: .asciz "Try another string?" # Thông báo hỏi người dùng có muốn thử chuỗi khác không.

.text
main: # Bắt đầu của chương trình chính
	la	s1, disk1			# Nạp địa chỉ của 'disk1' vào thanh ghi s1. s1 sẽ là con trỏ đến bộ đệm đĩa 1.
	la	s2, disk2			# Nạp địa chỉ của 'disk2' vào thanh ghi s2.
	la	s3, disk3			# Nạp địa chỉ của 'disk3' vào thanh ghi s3.
	la	a2, array			# Nạp địa chỉ của 'array' (nơi lưu parity) vào thanh ghi a2.
	
	j	input				# Nhảy đến nhãn 'input' để bắt đầu quá trình nhập liệu.
	nop					# Lệnh nop (no operation) để lấp đầy khe lệnh pipeline (có thể không cần thiết trên mọi kiến trúc).
	
input: # Bắt đầu phần nhập liệu
	li	a7, 4				# Đặt mã syscall 4 vào a7 (syscall để in chuỗi).
	la	a0, prompt			# Nạp địa chỉ của chuỗi 'prompt' vào a0 (tham số cho syscall).
	ecall					# Thực hiện syscall để in thông báo "Nhap chuoi ki tu : ".
	
	li	a7, 8				# Đặt mã syscall 8 vào a7 (syscall để đọc chuỗi).
	la	a0, string			# Nạp địa chỉ của bộ đệm 'string' vào a0 (nơi lưu chuỗi nhập).
	li	a1, 1000			# Đặt giới hạn tối đa 1000 ký tự đọc vào a1.
	ecall					# Thực hiện syscall để đọc chuỗi từ bàn phím.
						
	mv	s0, a0				# Di chuyển giá trị từ a0 (địa chỉ chuỗi đã đọc) vào s0. s0 sẽ là con trỏ đến chuỗi đầu vào.
	

# -------------------- Kiểm tra độ dài chuỗi đầu vào có phải là bội số của 8 --------------------
length: # Kiểm tra độ dài chuỗi
	addi	t3, zero, 0 			# Khởi tạo t3 (biến đếm độ dài chuỗi) về 0.
	addi	t0, zero, 0 			# Khởi tạo t0 (biến đếm chỉ số/index) về 0.

check_char: # Vòng lặp kiểm tra từng ký tự để tính độ dài.
	add	t1, s0, t0 			# Tính địa chỉ của ký tự hiện tại: t1 = địa chỉ_chuỗi_gốc + chỉ_số.
	lb	t2, 0(t1) 			# Tải byte (ký tự) từ địa chỉ t1 vào t2.
	li	s4, 10				# Nạp giá trị ASCII của ký tự xuống dòng ('\n' = 10) vào s4.
	beq	t2, s4, test_length 		# Nếu ký tự hiện tại là '\n' (t2 == s4), thì nhảy đến 'test_length' (đã hết chuỗi).
	nop					# Lệnh nop.
	
	addi	t3, t3, 1 			# Tăng biến đếm độ dài chuỗi (t3 = t3 + 1).
	addi	t0, t0, 1			# Tăng chỉ số (t0 = t0 + 1).
	j	check_char			# Nhảy trở lại 'check_char' để kiểm tra ký tự tiếp theo.
	nop					# Lệnh nop.
	
test_length: # Kiểm tra tính hợp lệ của độ dài chuỗi sau khi đã đếm.
	mv	t5, t3				# Di chuyển độ dài chuỗi (t3) vào t5 (lưu lại độ dài ban đầu để dùng sau này).
	beq	t0, zero, error 		# Nếu chỉ số t0 bằng 0 (chỉ nhập ký tự xuống dòng mà không có chuỗi nào), thì nhảy đến 'error'.
	
	andi	t1, t3, 0x0000000f		# Thực hiện phép AND bitwise giữa t3 (độ dài) và 0xF (15). Kết quả t1 sẽ là 4 bit cuối cùng của t3, tương đương với t3 % 16.
	bne	t1, zero, test1			# Nếu (t3 % 16) khác 0, tức là độ dài không phải là bội số của 16, thì nhảy đến 'test1'.
	j	input_prompt			# Nếu (t3 % 16) bằng 0 (là bội của 16), thì nhảy đến 'input_prompt'. (Vì 16 là bội của 8, nên các trường hợp này hợp lệ).
	nop					# Lệnh nop.
test1:
	li	s11, 8				# Nạp giá trị 8 vào s11.
	beq	t1, s11, input_prompt		# Nếu (t3 % 16) bằng 8 (tức là độ dài chia 8 dư 0), thì nhảy đến 'input_prompt'. (Đây là trường hợp độ dài chia hết cho 8 nhưng không chia hết cho 16).
	j	error				# Nếu không phải là bội số của 8, thì nhảy đến 'error'.
	nop					# Lệnh nop.
	
error: # Xử lý lỗi độ dài không hợp lệ
	li	a7, 4				# Đặt mã syscall 4 (in chuỗi).
	la	a0, error_message		# Nạp địa chỉ chuỗi lỗi vào a0.
	ecall					# In thông báo lỗi "Do dai chuoi khong hop le...".
	
	j	input				# Nhảy trở lại 'input' để người dùng nhập lại chuỗi.
	nop					# Lệnh nop.
	
input_prompt: # Chuẩn bị hiển thị đầu ra và bắt đầu mô phỏng RAID.
	li	a7, 4				# Đặt mã syscall 4 (in chuỗi).
	la	a0, disk			# Nạp địa chỉ chuỗi "Disk 1  Disk 2  Disk 3" vào a0.
	ecall					# In tiêu đề các đĩa.

	li	a7, 4				# Đặt mã syscall 4 (in chuỗi).
	la	a0, msg1			# Nạp địa chỉ chuỗi " -------------- " (dòng phân cách) vào a0.
	ecall					# In dòng phân cách.
	j	block1				# Nhảy đến 'block1' để bắt đầu mô phỏng RAID 5.

HEX: # Nhãn: Thủ tục chuyển đổi một byte sang 2 ký tự hexa ASCII
# s8 chứa byte cần chuyển đổi, a0 sẽ chứa ký tự hex ASCII.
	li	t4, 7				# Khởi tạo biến đếm t4 = 7. (Đại diện cho 8 nibble, nhưng ta chỉ in 2 cuối cùng của byte).
	
loopH: # Vòng lặp để trích xuất và in từng nibble (4 bit) của byte.
	blt	t4, zero, endloopH		# Nếu t4 nhỏ hơn 0, nhảy đến 'endloopH' (kết thúc vòng lặp).
	slli	s6, t4, 2			# Dịch trái t4 đi 2 bit (tương đương t4 * 4). s6 = vị trí bit của nibble cần lấy.
	srl	a0, s8, s6			# Dịch phải s8 (byte cần chuyển đổi) đi s6 bit. Điều này đưa nibble mong muốn về 4 bit cuối cùng của a0.
	andi	a0, a0, 0x0000000f 		# Thực hiện phép AND với 0xF để chỉ giữ lại 4 bit cuối cùng (giá trị của nibble).
	la	s7, hex 			# Nạp địa chỉ của mảng 'hex' vào s7.
	add	s7, s7, a0			# Cộng s7 với giá trị nibble trong a0 để có địa chỉ của ký tự hex tương ứng trong mảng 'hex'.
	li	a4, 1				# Nạp giá trị 1 vào a4.
	bgt	t4, a4, nextc			# Nếu t4 lớn hơn 1, nhảy đến 'nextc' (chỉ in 2 ký tự hex cuối cùng, bỏ qua các bit cao hơn).
	lb	a0, 0(s7) 			# Tải byte (ký tự hex) từ địa chỉ s7 vào a0.
	li	a7, 11				# Đặt mã syscall 11 (in ký tự).
	ecall					# Thực hiện syscall để in ký tự hex.

nextc:
	addi	t4, t4, -1			# Giảm t4 đi 1 (chuyển sang nibble tiếp theo).
	j	loopH				# Nhảy trở lại 'loopH'.
	nop					# Lệnh nop.

endloopH: # Kết thúc thủ tục HEX
	jr	ra				# Trả về địa chỉ đã lưu trong ra (trở về nơi gọi thủ tục).
	nop					# Lệnh nop.
	
#------------------------------ MÔ PHỎNG RAID 5 ------------------------------------
RAID5: # Đánh dấu bắt đầu phần mô phỏng RAID5 (không được nhảy trực tiếp đến đây)
# Block 1 : byte parity is stored in disk 3 (Khối 1: Parity được lưu ở đĩa 3)
# Block 2 : byte parity is stored in disk 2 (Khối 2: Parity được lưu ở đĩa 2)
# Block 3 : byte parity is stored in disk 1 (Khối 3: Parity được lưu ở đĩa 1)

block1: # Xử lý khối dữ liệu đầu tiên (8 byte). Dữ liệu 4 byte đầu vào disk1, 4 byte tiếp theo vào disk2, parity vào disk3.
	addi	t0, zero, 0			# Khởi tạo t0 (biến đếm cho 4 byte của mỗi block) về 0.
	addi	s9, zero, 0			# Khởi tạo s9 (biến đếm cho việc in) về 0.
	addi	s8, zero, 0			# Khởi tạo s8 (biến đếm cho việc in) về 0.
	la	s1, disk1			# Nạp lại địa chỉ 'disk1' vào s1 (đảm bảo con trỏ về đầu buffer).
	la	s2, disk2			# Nạp lại địa chỉ 'disk2' vào s2.
	la	a2, array			# Nạp lại địa chỉ 'array' vào a2.
	
print11: # In phần mở đầu cho Disk 1
	li	a7, 4				# Đặt mã syscall 4 (in chuỗi).
	la 	a0, msg2			# Nạp địa chỉ chuỗi "|      " vào a0.
	ecall					# In phần mở đầu.
	
b11: # Vòng lặp xử lý byte cho block1: Lưu 4 byte đầu tiên vào disk1
# Store into disk1					
	lb	t1, 0(s0)			# Tải byte từ địa chỉ s0 (chuỗi đầu vào) vào t1. s0 đang trỏ đến ký tự hiện tại của chuỗi.
	addi	t3, t3, -1			# Giảm độ dài chuỗi còn lại (t3--).
	sb	t1, (s1)			# Lưu byte t1 vào địa chỉ s1 (bộ đệm disk1).
b12: # Xử lý byte thứ hai cho cặp: Lưu 4 byte tiếp theo vào disk2
# Store ịnto disk2
	addi	s5, s0, 4			# Tính địa chỉ của byte thứ 5 trong khối 8 byte hiện tại: s5 = s0 + 4.
	lb	t2, 0(s5)			# Tải byte từ địa chỉ s5 vào t2.
	addi	t3, t3, -1			# Giảm độ dài chuỗi còn lại (t3--).
	sb	t2, 0(s2)			# Lưu byte t2 vào địa chỉ s2 (bộ đệm disk2).
b13: # Tính và lưu parity (XOR)
# Store XOR result into disk3
	xor	a3, t1, t2			# Thực hiện phép XOR giữa t1 và t2, kết quả lưu vào a3. a3 chứa byte parity.
	sw	a3, 0(a2)			# Lưu giá trị parity a3 (dưới dạng word, mặc dù chỉ cần 1 byte, nhưng sw lưu 4 byte) vào địa chỉ a2 (mảng array).
	addi	a2, a2, 4			# Tăng con trỏ a2 lên 4 byte (di chuyển đến vị trí word tiếp theo trong mảng parity).
	addi	t0, t0, 1			# Tăng biến đếm t0 (số byte đã xử lý trong khối 4 byte).
	addi	s0, s0, 1			# Tăng con trỏ s0 (chuỗi đầu vào) lên 1 byte (di chuyển đến ký tự tiếp theo).
	addi	s1, s1, 1			# Tăng con trỏ s1 (disk1) lên 1 byte.
	addi	s2, s2, 1			# Tăng con trỏ s2 (disk2) lên 1 byte.
	li	a6, 3				# Nạp giá trị 3 vào a6.
	bgt	t0, a6, reset			# Nếu t0 lớn hơn 3 (đã xử lý đủ 4 byte cho mỗi đĩa), thì nhảy đến 'reset'.
	j	b11				# Nhảy trở lại 'b11' để xử lý cặp byte tiếp theo trong khối 8 byte.
	nop					# Lệnh nop.
reset: # Reset con trỏ buffer disk để chuẩn bị in
	la 	s1, disk1			# Nạp lại địa chỉ gốc của 'disk1' vào s1.
	la	s2, disk2			# Nạp lại địa chỉ gốc của 'disk2' vào s2.
	
print12: # Vòng lặp in nội dung bộ đệm disk1
	lb	a0, 0(s1)			# Tải byte từ địa chỉ s1 (disk1) vào a0.
	li	a7, 11				# Đặt mã syscall 11 (in ký tự).
	ecall					# In ký tự.
	addi	s9, s9, 1			# Tăng biến đếm s9 (số ký tự đã in của disk1).
	addi	s1, s1, 1			# Tăng con trỏ s1 lên 1 byte.
	bgt	s9, a6, next11			# Nếu s9 lớn hơn a6 (3), tức là đã in đủ 4 ký tự, thì nhảy đến 'next11'.
	j	print12				# Nhảy trở lại 'print12' để in ký tự tiếp theo.
	nop					# Lệnh nop.
	
next11:	# Chuẩn bị in disk2		
	li	a7, 4				# Đặt mã syscall 4 (in chuỗi).
	la	a0, msg3			# Nạp địa chỉ chuỗi "       |       " vào a0.
	ecall					# In phần phân cách.
	li	a7, 4				# Đặt mã syscall 4 (in chuỗi).
	la	a0, msg2			# Nạp địa chỉ chuỗi "|      " vào a0.
	ecall					# In phần mở đầu cho disk2.
	
print13: # Vòng lặp in nội dung bộ đệm disk2
	lb	a0, 0(s2)			# Nạp byte từ bộ đệm disk2 (s2) vào a0.
	li	a7, 11				# Đặt mã syscall 11 (in ký tự).
	ecall					# In ký tự.
	addi	s8, s8, 1			# Tăng biến đếm s8 (số ký tự đã in của disk2).
	addi	s2, s2, 1			# Tăng con trỏ s2 lên 1 byte.
	bgt	s8, a6, next12			# Nếu s8 lớn hơn a6 (3), tức là đã in đủ 4 ký tự, thì nhảy đến 'next12'.
	j	print13				# Nhảy trở lại 'print13'.
	nop					# Lệnh nop.
	
next12:	# Chuẩn bị in parity (disk3)
	li	a7, 4				# Đặt mã syscall 4 (in chuỗi).
	la	a0, msg3			# Nạp địa chỉ chuỗi "       |       " vào a0.
	ecall					# In phần phân cách.
	li	a7, 4				# Đặt mã syscall 4 (in chuỗi).
	la	a0, msg4			# Nạp địa chỉ chuỗi "[[ " vào a0.
	ecall					# In ký tự mở đầu cho parity.
	la	a2, array			# Nạp lại địa chỉ gốc của 'array' vào a2 (đảm bảo con trỏ về đầu mảng parity).
	addi	s9, zero, 0			# Reset biến đếm s9 về 0 (để dùng cho việc in parity).
	
print14: # Chuyển đổi chuỗi parity sang ASCII và in ra màn hình
	lb	s8, 0(a2)			# Tải byte parity từ địa chỉ a2 (mảng array) vào s8.
	jal	HEX				# Gọi thủ tục HEX để chuyển đổi byte trong s8 sang 2 ký tự hex và in ra.
	nop					# Lệnh nop.
	li	a7, 4				# Đặt mã syscall 4 (in chuỗi).
	la	a0, comma			# Nạp địa chỉ ký tự dấu phẩy "," vào a0.
	ecall					# In dấu phẩy.
	
	addi	s9, s9, 1			# Tăng biến đếm s9 (chỉ số của byte parity đã in).
	addi	a2, a2, 4			# Tăng con trỏ a2 lên 4 byte (di chuyển đến vị trí word tiếp theo trong mảng parity).
	li	a5, 2				# Nạp giá trị 2 vào a5 (để in 3 dấu phẩy cho 4 parity: 0,1,2,3).
	bgt	s9, a5, endisk1			# Nếu s9 lớn hơn 2 (đã in parity thứ 3), nhảy đến 'endisk1' (để in parity cuối cùng không có dấu phẩy).
	j	print14				# Nhảy trở lại 'print14' để in parity tiếp theo.
endisk1: # In byte parity cuối cùng (không có dấu phẩy sau)
	lb	s8, 0(a2)			# Nạp byte parity cuối cùng vào s8.
	jal	HEX				# Gọi thủ tục HEX để in.
	nop					# Lệnh nop.
	li	a7, 4				# Đặt mã syscall 4 (in chuỗi).
	la	a0, msg5			# Nạp địa chỉ chuỗi "]]      " vào a0.
	ecall					# In ký tự đóng khung parity.
	
	li	a7, 4				# Đặt mã syscall 4 (in chuỗi).
	la	a0, newline			# Nạp địa chỉ ký tự xuống dòng vào a0.
	ecall					# In ký tự xuống dòng.
	beq	t3, zero, exit1			# Nếu độ dài chuỗi còn lại (t3) bằng 0, nhảy đến 'exit1' (kết thúc chương trình).
	j	block2				# Nếu không, nhảy đến 'block2' để xử lý khối tiếp theo.
	nop					# Lệnh nop.
	
#----------------------------------------
block2:	# Chức năng block2: 4 byte đầu tiên vào disk1, 4 byte tiếp theo vào disk3; parity vào disk2.
	la	a2, array			# Nạp địa chỉ mảng parity 'array' vào a2 (parity cho Disk2).
	la	s1, disk1			# Nạp địa chỉ bộ đệm disk1 vào s1.
	la	s3, disk3			# Nạp địa chỉ bộ đệm disk3 vào s3.
	addi	s0, s0, 4			# Tăng con trỏ chuỗi đầu vào (s0) lên 4 (bỏ qua 4 byte đã xử lý ở block1 cho disk1/disk2, s0 cần trỏ tới đầu khối dữ liệu thứ 2).
	addi	t0, zero, 0			# Reset biến đếm vòng lặp t0 = 0.
		
print21: # print "|      "
	li	a7, 4				# Đặt mã syscall 4.
	la	a0, msg2			# Nạp địa chỉ msg2 vào a0.
	ecall					# In "|      ".

b21: # Lưu 4 byte vào disk1
	lb	t1, 0(s0)			# Nạp byte từ chuỗi đầu vào (s0) vào t1 (cho Disk1).
	addi	t3, t3, -1			# string_length --.
	sb	t1, 0(s1)			# Lưu byte t1 vào bộ đệm disk1.
b23: # Lưu 4 byte tiếp theo vào disk3
	addi	s5, s0, 4			# Tính địa chỉ byte tương ứng (s0 + 4).
	lb	t2, 0(s5)			# Tải byte từ (s0+4) vào t2.
	addi	t3, t3, -1			# length --.
	sb	t2, 0(s3)			# Lưu byte t2 vào bộ đệm disk3.
	
b22: # Lưu kết quả XOR vào disk2
	xor	a3, t1, t2			# Tính XOR của t1 và t2 -> a3 (parity).
	sw	a3, 0(a2)			# Lưu byte parity a3 (như word) vào mảng 'array' (cho Disk2).
	addi	a2, a2, 4			# Tăng con trỏ mảng parity (a2).
	addi	t0, t0, 1			# Tăng biến đếm vòng lặp t0.
	addi	s0, s0, 1			# Tăng con trỏ chuỗi đầu vào (s0).
	addi	s1, s1, 1			# Tăng con trỏ bộ đệm disk1 (s1).
	addi	s3, s3, 1			# Tăng con trỏ bộ đệm disk3 (s3).
	bgt	t0, a6, reset2  		# Nếu t0 lớn hơn 3, nhảy đến 'reset2'.
	j	b21				# Nhảy trở lại 'b21'.
	nop					# Lệnh nop.
reset2: # Reset con trỏ đĩa
	la	s1, disk1			# Nạp lại địa chỉ bộ đệm disk1 vào s1.
	la	s3, disk3			# Nạp lại địa chỉ bộ đệm disk3 vào s3.
	addi	s9, zero, 0			# Reset biến đếm s9 = 0 (cho việc in).
	
print22: # In nội dung bộ đệm disk1
	lb	a0, 0(s1)			# Nạp byte từ bộ đệm disk1 (s1) vào a0.
	li	a7, 11				# syscall 11 (in ký tự).
	ecall					# In ký tự.
	addi	s9, s9, 1			# Tăng biến đếm s9.
	addi	s1, s1, 1			# Tăng con trỏ bộ đệm disk1 (s1).
	bgt	s9, a6, next21 			# Nếu s9 lớn hơn 3, nhảy đến 'next21'.
	j	print22				# Nhảy trở lại 'print22'.
	nop					# Lệnh nop.
	
next21:	# Chuẩn bị in parity (Disk2)
	li	a7, 4				# Đặt mã syscall 4.
	la	a0, msg3			# Nạp địa chỉ msg3 vào a0.
	ecall					# In phân cách.
	la	a2, array			# Nạp lại địa chỉ mảng parity 'array' vào a2.
	addi	s9, zero, 0			# Reset biến đếm s9 = 0.
	li	a7, 4				# Đặt mã syscall 4.
	la	a0, msg4			# Nạp địa chỉ msg4 vào a0.
	ecall					# In "[[ ".
	
print23: # Vòng lặp in các byte parity (Disk2)
	lb	s8, 0(a2)			# Nạp byte parity từ mảng (a2) vào s8.
	jal	HEX				# Gọi thủ tục HEX để in hex.
	nop					# Lệnh nop.
	li	a7, 4				# Đặt mã syscall 4.
	la	a0, comma			# Nạp địa chỉ comma vào a0.
	ecall					# In dấu phẩy.
	addi	s9, s9, 1			# Tăng biến đếm s9.
	addi	a2, a2, 4			# Tăng con trỏ mảng parity (a2).
	bgt	s9, a5, next22			# Nếu s9 lớn hơn 2, nhảy đến 'next22'.
	j	print23				# Nhảy trở lại 'print23'.
	nop					# Lệnh nop.
		
next22:	# In byte parity cuối cùng (Disk2)
	lb	s8, (a2)			# Nạp byte parity cuối cùng vào s8.
	jal	HEX				# Gọi thủ tục HEX để in hex.
	nop					# Lệnh nop.
	
	li	a7, 4				# Đặt mã syscall 4.
	la	a0, msg5			# Nạp địa chỉ msg5 vào a0.
	ecall					# In "]] ".
	
	li	a7, 4				# Đặt mã syscall 4.
	la	a0, msg2			# Nạp địa chỉ msg2 vào a0.
	ecall					# In "|      ".
	addi	s8, zero, 0			# Reset biến đếm s8 = 0 (cho việc in Disk3).
	
print24: # Vòng lặp in nội dung bộ đệm disk3
	lb	a0, 0(s3)			# Nạp byte từ bộ đệm disk3 (s3) vào a0.
	li	a7, 11				# syscall 11.
	ecall					# In ký tự.
	addi	s8, s8, 1			# Tăng biến đếm s8.
	addi	s3, s3, 1			# Tăng con trỏ bộ đệm disk3 (s3).
	bgt	s8, a6, endisk2 		# Nếu s8 lớn hơn 3, nhảy đến 'endisk2'.
	j	print24				# Nhảy trở lại 'print24'.
	nop					# Lệnh nop.

endisk2: # Kết thúc in block2
	li	a7, 4				# Đặt mã syscall 4.
	la	a0, msg3			# Nạp địa chỉ msg3 vào a0.
	ecall					# In phân cách.
	li	a7, 4				# Đặt mã syscall 4.
	la	a0, newline			# Nạp địa chỉ newline vào a0.
	ecall					# In xuống dòng.
	beq	t3, zero, exit1			# Nếu độ dài còn lại t3 = 0, nhảy đến 'exit1'.
	j	block3				# Nếu không, nhảy đến 'block3'.
	nop					# Lệnh nop.
	
#--------------------------------
block3:	# Chức năng block3: 4 byte đầu tiên vào disk2, 4 byte tiếp theo vào disk3; parity vào disk1.
	la	a2, array			# Nạp địa chỉ array vào a2.
	la	s2, disk2			# Nạp địa chỉ disk2 vào s2.
	la	s3, disk3			# Nạp địa chỉ disk3 vào s3.
	addi	s0, s0, 4			# Tăng con trỏ chuỗi đầu vào (s0) lên 4.
	addi	t0, zero, 0			# Reset biến đếm vòng lặp t0 = 0.
print31: # Print '[['
	li	a7, 4				# Đặt mã syscall 4.
	la	a0, msg4			# Nạp địa chỉ msg4 vào a0.
	ecall					# In "[[ ".
b32: # Byte được lưu trong Disk 2				
	lb	t1, 0(s0)			# Nạp byte từ chuỗi đầu vào (s0) vào t1 (cho Disk2).
	addi	t3, t3, -1			# string_length --.
	sb	t1, 0(s2)			# Lưu byte t1 vào bộ đệm disk2.
b33: # Lưu vào Disk 3
	addi	s5, s0, 4			# Tính địa chỉ byte tương ứng (s0+4).
	lb	t2, 0(s5)			# Nạp byte từ (s0+4) vào t2 (cho Disk3).
	addi	t3, t3, -1			# Giảm độ dài còn lại t3.
	sb	t2, 0(s3)			# Lưu byte t2 vào bộ đệm disk3.
	
b31: # Lưu kết quả XOR vào disk1
	xor	a3, t1, t2			# Tính XOR của t1 và t2 -> a3 (parity).
	sw	a3, 0(a2)			# Lưu byte parity a3 (như word) vào mảng 'array' (cho Disk1).
	addi	a2, a2, 4			# Tăng con trỏ mảng parity (a2).
	addi	t0, t0, 1			# Tăng biến đếm vòng lặp t0.
	addi	s0, s0, 1			# Tăng con trỏ chuỗi đầu vào (s0).
	addi	s2, s2, 1			# Tăng con trỏ bộ đệm disk2 (s2).
	addi	s3, s3, 1			# Tăng con trỏ bộ đệm disk3 (s3).
	bgt	t0, a6, reset3			# Nếu t0 lớn hơn 3, nhảy đến 'reset3'.
	j	b32				# Nhảy trở lại 'b32'.
	nop					# Lệnh nop.
reset3: # Reset con trỏ bộ đệm đĩa để chuẩn bị in
	la	s2, disk2			# Nạp lại địa chỉ disk2 vào s2.
	la	s3, disk3			# Nạp lại địa chỉ disk3 vào s3.
	la	a2, array			# Nạp lại địa chỉ array vào a2.
	addi	s9, zero, 0			# Index - Reset biến đếm s9 = 0 (cho việc in).
	
print32: # Vòng lặp in các byte parity (Disk1)
	lb	s8, 0(a2)			# Nạp byte parity từ mảng (a2) vào s8.
	jal	HEX				# Gọi thủ tục HEX để in hex.
	nop					# Lệnh nop.
	li	a7, 4				# Đặt mã syscall 4.
	la	a0, comma			# Nạp địa chỉ comma vào a0.
	ecall					# In dấu phẩy.
	
	addi	s9, s9, 1			# Tăng biến đếm s9.
	addi	a2, a2, 4			# Tăng con trỏ mảng parity (a2).
	bgt	s9, a5, next31			# Nếu s9 lớn hơn 2, nhảy đến 'next31'.
	j	print32				# Nhảy trở lại 'print32'.
	nop					# Lệnh nop.
	
next31: # In byte parity cuối cùng (Disk1)
	lb	s8, 0(a2)			# Nạp byte parity cuối cùng vào s8.
	jal	HEX				# Gọi thủ tục HEX để in hex.
	nop					# Lệnh nop.

	li	a7, 4				# Đặt mã syscall 4.
	la	a0, msg5			# Nạp địa chỉ msg5 vào a0.
	ecall					# In "]] ".
	li	a7, 4				# Đặt mã syscall 4.
	la	a0, msg2			# Nạp địa chỉ msg2 vào a0.
	ecall					# In "|      ".
	addi	s9, zero, 0			# Reset s9 về 0.
	
print33: # Vòng lặp in nội dung bộ đệm disk2
	lb	a0, 0(s2)			# Nạp byte từ bộ đệm disk2 (s2) vào a0.
	li	a7, 11				# syscall 11.
	ecall					# In ký tự.
	addi	s9, s9, 1			# Tăng biến đếm s9.
	addi	s2, s2, 1			# Tăng con trỏ bộ đệm disk2 (s2).
	bgt	s9, a6, next32 			# Nếu s9 lớn hơn 3, nhảy đến 'next32'.
	j	print33				# Nhảy trở lại 'print33'.
	nop					# Lệnh nop.
	
next32: # Chuẩn bị in Disk3
	addi	s9, zero, 0			# Reset biến đếm s9 (không thực sự dùng ngay sau).
	addi	s8, zero, 0			# Reset biến đếm s8 (cho việc in Disk3).
	li	a7, 4				# Đặt mã syscall 4.
	la	a0, msg3			# Nạp địa chỉ msg3 vào a0.
	ecall					# In phân cách.
	li	a7, 4				# Đặt mã syscall 4.
	la	a0, msg2			# Nạp địa chỉ msg2 vào a0.
	ecall					# In "|      ".
print34: # Vòng lặp in nội dung bộ đệm disk3
	lb	a0, (s3)			# Nạp byte từ bộ đệm disk3 (s3) vào a0.
	li	a7, 11				# syscall 11.
	ecall					# In ký tự.
	addi	s8, s8, 1			# Tăng biến đếm s8.
	addi	s3, s3, 1			# Tăng con trỏ bộ đệm disk3 (s3).
	bgt	s8, a6, endisk3 		# a6 vẫn là 3 - Nếu s8 lớn hơn 3, nhảy đến 'endisk3'.
	j	print34				# Nhảy trở lại 'print34'.
	nop					# Lệnh nop.

endisk3: # Kết thúc in block3
	li	a7, 4				# Đặt mã syscall 4.
	la	a0, msg3			# Nạp địa chỉ msg3 vào a0.
	ecall					# In phân cách.
	
	li	a7, 4				# Đặt mã syscall 4.
	la	a0, newline			# Nạp địa chỉ newline vào a0.
	ecall					# In xuống dòng.
	beq	t3, zero, exit1			# Nếu độ dài còn lại t3 = 0, nhảy đến 'exit1'.
	j	nextloop 			# Nhảy đến 'nextloop' để xử lý cụm 3 block tiếp theo.
	nop					# Lệnh nop.

#-----------Kết thúc 3 khối 8 byte đầu tiên (tổng cộng 24 byte)-----------------------------
#-----------Xử lý các khối 8 byte tiếp theo (tương tự, là các cụm 24 byte tiếp theo)----------------------------------

nextloop: # Bắt đầu một chu kỳ mới của 3 block RAID
	addi	s0, s0, 4			# Tăng con trỏ chuỗi đầu vào (s0) lên 4 (để block1 tiếp theo bắt đầu từ đầu khối dữ liệu thứ 2 của cụm 24 byte mới).
	j	block1				# Nhảy trở lại 'block1' để xử lý chu kỳ tiếp theo.
	nop					# Lệnh nop.
	
exit1: # In dòng phân cách cuối cùng và kết thúc mô phỏng RAID
	li	a7, 4				# Đặt mã syscall 4.
	la	a0, msg1			# Nạp địa chỉ msg1 vào a0.
	ecall					# In dòng phân cách cuối cùng.
	j	ask					# Nhảy đến 'ask' để hỏi người dùng có muốn thử chuỗi khác không.
	nop					# Lệnh nop.
	
#--------------------KẾT THÚC MÔ PHỎNG RAID 5-------------------------


#--------------------THỬ CHUỖI KHÁC----------------------------
ask: # Hỏi người dùng có muốn thử chuỗi khác không
	li	a7, 50				# syscall 50 (hộp thoại thông báo yes/no/cancel).
	la	a0, message			# Nạp địa chỉ chuỗi 'message' ("Try another string?") vào a0.
	ecall					# Thực hiện syscall để hiển thị hộp thoại.
	beq	a0, zero, clear			# a0: 0 = YES; 1 = NO; 2 = CANCEL. Nếu a0 = 0 (người dùng chọn "Yes"), nhảy đến 'clear'.
	nop					# Lệnh nop.
	j	exit				# Nếu không phải "Yes" (chọn "No" hoặc "Cancel"), nhảy đến 'exit' để thoát chương trình.
	nop					# Lệnh nop.
	
# clear function: Trả chuỗi về trạng thái ban đầu
clear: # Xóa nội dung chuỗi đầu vào cũ để chuẩn bị nhập mới.
	la	s0, string			# Nạp địa chỉ của bộ đệm 'string' vào s0 (con trỏ về đầu chuỗi).
	add	s3, s0, t5			# Tính địa chỉ cuối của chuỗi cũ: s3 = địa_chỉ_chuỗi_gốc + độ_dài_chuỗi_cũ (t5).
	li	t1, 0				# Đặt t1 = 0 (giá trị byte null để xóa).

goAgain: # Trả chuỗi về trạng thái rỗng để bắt đầu lại.
	sb	t1, (s0)			# Ghi byte null (t1) vào địa chỉ s0 trong bộ đệm 'string' (xóa ký tự).
	nop					# Lệnh nop.
	addi	s0, s0, 1			# Tăng con trỏ s0 lên byte tiếp theo.
	bge	s0, s3, input 			# Nếu s0 lớn hơn hoặc bằng s3 (đã xóa hết chuỗi cũ), nhảy đến 'input' để nhập chuỗi mới.
	nop					# Lệnh nop.
	j	goAgain				# Nhảy trở lại 'goAgain' để tiếp tục xóa.
	nop					# Lệnh nop.

#-----Thoát chương trình----------
exit:
	li	a7, 10				# Đặt mã syscall 10 (thoát chương trình).
	ecall					# Thực hiện syscall để thoát.