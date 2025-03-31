# Laboratory Exercise 7, Home Assignment 2 
.text 
main:   
    li    a0, 1    # Nạp giá trị kiểm tra đầu vào (a0 = 4)  
    li    a1, 18     # Nạp giá trị a1 = 7  
    li    a2, 36     # Nạp giá trị a2 = 5  
    jal   max       # Gọi thủ tục max để tìm giá trị lớn nhất  
    li    a7, 10    # Kết thúc chương trình  
    ecall  
end_main:

max:   
    add     s0, a0, zero    # Sao chép giá trị a0 vào s0; giả sử là lớn nhất  
    sub     t0, a1, s0      # Tính a1 - s0  
    blt     t0, zero, okay  # Nếu a1 - s0 < 0 thì giữ nguyên s0  
    add     s0, a1, zero    # Ngược lại, cập nhật s0 thành a1 (a1 lớn hơn)  
okay:  
    sub     t0, a2, s0      # Tính a2 - s0  
    blt     t0, zero, done  # Nếu a2 - s0 < 0 thì giữ nguyên s0  
    add     s0, a2, zero    # Ngược lại, cập nhật s0 thành a2 (a2 lớn nhất)  

done:  
    jr      ra              # Quay lại chương trình gọi  
