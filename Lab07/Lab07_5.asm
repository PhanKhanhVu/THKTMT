# Laboratory Exercise 7, Home Assignment 5
.data
min_msg:   .string "Smallest: "
at_msg:    .string ", "
max_msg:   .string "Largest: "
newline:   .string "\n"

.text
main: 
   # Nạp 8 số nguyên vào các thanh ghi a0 - a7
   li a0, 0
   li a1, 2
   li a2, 4
   li a3, 6
   li a4, 8
   li a5, 1
   li a6, 3
   li a7, 5

   # Đẩy các giá trị lên ngăn xếp
   addi sp, sp, -32  # Dành chỗ trên stack
   sw a0, 28(sp)
   sw a1, 24(sp)
   sw a2, 20(sp)
   sw a3, 16(sp)
   sw a4, 12(sp)
   sw a5, 8(sp)
   sw a6, 4(sp)
   sw a7, 0(sp)

   # Gọi hàm tìm min/max
   jal find_minmax

   # Hiển thị kết quả
   la a0, min_msg
   li a7, 4
   ecall
   mv a0, s0
   li a7, 1
   ecall
   la a0, at_msg
   li a7, 4
   ecall
   mv a0, s2
   li a7, 1
   ecall
   la a0, newline
   li a7, 4
   ecall

   la a0, max_msg
   li a7, 4
   ecall
   mv a0, s1
   li a7, 1
   ecall
   la a0, at_msg
   li a7, 4
   ecall
   mv a0, s3
   li a7, 1
   ecall

   # Kết thúc chương trình
   li a7, 10
   ecall

find_minmax:
   # Khởi tạo giá trị ban đầu
   lw s0, 28(sp)  # Giá trị nhỏ nhất
   lw s1, 28(sp)  # Giá trị lớn nhất
   li s2, 0       # Vị trí giá trị nhỏ nhất
   li s3, 0       # Vị trí giá trị lớn nhất
   li t0, 1       # Chỉ số hiện tại

   # Vòng lặp kiểm tra từng phần tử
   li t1, 24  # Offset bắt đầu
loop:
   lw t2, (sp)    # Lấy giá trị từ stack
   bge t2, s0, not_min  # Nếu giá trị >= min thì bỏ qua
   mv s0, t2      # Cập nhật giá trị nhỏ nhất
   mv s2, t0      # Cập nhật vị trí nhỏ nhất
not_min:
   ble t2, s1, not_max  # Nếu giá trị <= max thì bỏ qua
   mv s1, t2      # Cập nhật giá trị lớn nhất
   mv s3, t0      # Cập nhật vị trí lớn nhất
not_max:
   addi sp, sp, 4  # Di chuyển đến phần tử tiếp theo
   addi t0, t0, 1  # Tăng chỉ số
   addi t1, t1, -4 # Giảm số phần tử cần duyệt
   bnez t1, loop  # Nếu còn phần tử, tiếp tục lặp

   # Khôi phục stack pointer
   addi sp, sp, -32
   jr ra
