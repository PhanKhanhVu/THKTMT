# Laboratory Exercise 7 Home Assignment 1 
.text 
main: 
    li  a0, -45     # Tải tham số đầu vào  
    jal abs         # Chuyển điều khiển đến thủ tục abs  
    li  a7, 10      # Kết thúc chương trình  
    ecall  
end_main: 

abs:     
    sub s0, zero, a0    # Đặt -a0 vào s0; trong trường hợp a0 < 0  
    blt a0, zero, done  # Nếu a0 < 0 thì nhảy đến done  
    add s0, a0, zero    # Ngược lại, gán a0 vào s0  
done:    
    jr  ra  # Trả về địa chỉ gọi  