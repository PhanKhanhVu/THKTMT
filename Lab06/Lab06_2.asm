.data 
A: .word 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 
Aend: .word 
space: .asciz " "
newline: .asciz "\n" # Xuống dòng sau mỗi lần in mảng

.text 
main:  
   la    a0, A       # Lưu đỉa chỉ của mảng A 
   la    a1, Aend   
   addi  a1, a1, -4  # Địa chỉ của phần tử cuối cùng trong mảng 
   li    s2 40    # Khởi tạo số byte của mảng
   
   j     sort        # sort 
after_sort: 
   li    a7, 10      
   ecall 
end_main: 

sort:  
   beq   a0, a1, done   # Kiểm tra nếu mảng có 1 kí tự thì kết thúc
   j     max            # Gọi đến hàm tìm max
   
after_max:  
   lw    t0, 0(a1)      # Lấy giá trị của phần tử cuối cùng
   sw    t0, 0(s0)      # Thay giá trị của phần tử cuối cùng bằng phần tử max
   sw    s1, 0(a1)      # Đổi giá trị của phần tử lớn nhất là phần tử cuối vừa trỏ
   addi  a1, a1, -4     # Lùi còn trỏ đến phần tử trước đó
   addi  s5, a0, 0  	
   li    s3 0        # Khởi tạo biến đếm 
arrLoop: 
	add s4, s3, s5	
	lw a0, 0(s4)    
	li a7, 1
	ecall
	
	# In khoảng trắng
	la a0, space
	li a7, 4
	ecall
	
	addi s3, s3, 4	# Tăng biến đếm 
	bge s3, s2, endArrLoop	# Kiểm tra điều kiện dừng
	j arrLoop	# Tiếp tục vòng lặp
endArrLoop:
   la  a0, newline
   li  a7, 4
   ecall
   
   addi a0, s5, 0
   j     sort           # Gọi đến hàm sort và tiếp tục thực hiện
done:  
   j     after_sort
max: 
   addi  s0, a0, 0   # Lấy địa chỉ của phần tử đầu tiên trong mảng
   lw    s1, 0(s0)   # Lấy giá trị của phần tử có vị trí s0 
   addi  t0, a0, 0   # Con trỏ trỏ đến phần tử đầu tiên 
loop: 
   beq   t0, a1, ret # kiểm tra để kết thúc chương trình
   addi  t0, t0, 4   # Tăng biến đếm
   lw    t1, 0(t0)   # load next element into t1 
   blt   t1, s1, loop# kiểm tra để tiếp tục vòng lặp
   addi  s0, t0, 0   # Địa chỉ mới của max    
   addi  s1, t1, 0   # Giá trị mới của max
   j     loop 
# Sau khi đổi tiếp tục thực hiện chương trình 
ret: 
j     after_max
