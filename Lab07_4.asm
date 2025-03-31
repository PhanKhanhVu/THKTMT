# Laboratory Exercise 7, Home Assignment 4 
.data 
           message: .asciz  "Ket qua tinh giai thua la: " 
.text 
main: 
	jal    WARP 

print: 
	add    a1, s0, zero     # a1 = result từ giai thừa
	li     a7, 4
	la     a0, message
	ecall 
	li     a7, 1
	mv     a0, s0
	ecall

quit: 
	li     a7, 10           # Thoát chương trình
	ecall       
end_main: 

WARP: 
    addi   sp, sp, -4       # Điều chỉnh con trỏ stack 
    sw     ra, 0(sp)        # Lưu địa chỉ trả về vào stack
 
    li     a0, 5           # Gán giá trị test N = 3 
    jal    FACT             # Gọi hàm FACT  
        
    lw     ra, 0(sp)        # Phục hồi địa chỉ trả về 
    addi   sp, sp, 4        # Điều chỉnh lại con trỏ stack 
    jr     ra                             
wrap_end: 

FACT: 
    addi    sp, sp, -8      # Cấp phát stack cho ra và a0  
    sw      ra, 4(sp)       # Lưu thanh ghi ra  
    sw      a0, 0(sp)       # Lưu giá trị N hiện tại  

    li      t0, 2
    bge     a0, t0, recursive  # Nếu N >= 2, tiếp tục đệ quy  
    li      s0, 1           # Nếu N < 2, trả về 1  
    j       done            # Nhảy đến kết thúc  

recursive: 
    addi    a0, a0, -1      # Giảm N xuống (N-1) 
    jal     FACT            # Gọi đệ quy FACT(N-1)  

    lw      s1, 0(sp)       # Lấy lại giá trị N từ stack  
    mul     s0, s0, s1      # s0 = FACT(N-1) * N  

done: 
    lw      ra, 4(sp)       # Phục hồi thanh ghi ra  
    lw      a0, 0(sp)       # Phục hồi giá trị a0  
    addi    sp, sp, 8       # Giải phóng stack  
    jr      ra              # Trả về caller  
fact_end: 