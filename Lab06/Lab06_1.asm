.data 
A: .word -2 1 5 2 -5    # Mảng số nguyên

.text
main:  
   la    a0, A          # Lấy địa chỉ của mảng
   li    a1, 20         # Số byte của mảng (5 phần tử, mỗi phần tử 4 byte)
   j     mspfx          # Nhảy đến hàm tính tổng tiền tố

continue: 
exit:  
   li    a7, 10         # Lời gọi hệ thống để kết thúc chương trình
   ecall 

mspfx:  
   li    s0, 0          # Khởi tạo độ dài tổng tiền tố lớn nhất
   li    s1, 0x80000000 # Giá trị nhỏ nhất ban đầu (tương đương -∞)
   li    t0, 0          # Biến đếm (chỉ mục mảng, tính theo byte)
   li    t1, 0          # Tổng tiền tố hiện tại

loop:  
   add   t3, a0, t0     # Lấy địa chỉ của phần tử tiếp theo
   lw    t4, 0(t3)      # Đọc giá trị của A[i] từ bộ nhớ
   add   t1, t1, t4     # Cộng giá trị vào tổng tiền tố hiện tại
   blt   s1, t1, mdfy   # Nếu tổng hiện tại lớn hơn tổng max, cập nhật 

   j     next           # Nếu không cập nhật, tiếp tục vòng lặp

mdfy:  
   srli  s0, t0, 2      # Chia 4 để lấy số phần tử
   addi  s1, t1, 0      # Cập nhật tổng tiền tố lớn nhất

next:  
   addi  t0, t0, 4      # Tăng biến đếm lên 4 (vì mỗi phần tử 4 byte)
   blt   t0, a1, loop   # Kiểm tra điều kiện dừng vòng lặp

done:  
   j     continue 
mspfx_end: