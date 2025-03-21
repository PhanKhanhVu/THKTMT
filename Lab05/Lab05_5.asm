.data
    str:        .space 21         # Dự phòng 1 ký tự NULL ('\0')
    reversed:   .space 21
    message1:   .asciz "Nhap chuoi: "
    message2:   .asciz "Chuoi dao nguoc: "

.text
.globl main
main:
    # In thông báo nhập chuỗi
    li a7, 4
    la a0, message1
    ecall

    # Đọc từng ký tự bằng syscall 12 (giới hạn 20 ký tự)
    la t0, str         # t0 trỏ đến str
    li t1, 0           # t1 là biến đếm độ dài

read_loop:
    li a7, 12          # Syscall 12: Đọc 1 ký tự
    ecall
    li t6, 10
    beq a0, t6, end_input  # Nếu gặp Enter ('\n'), kết thúc nhập
    sb a0, 0(t0)       # Lưu ký tự vào str
    addi t0, t0, 1     # Tiến lên 1 ô nhớ
    addi t1, t1, 1     # Tăng biến đếm độ dài chuỗi
    li t2, 20          # Giới hạn 20 ký tự
    beq t1, t2, end_input  # Nếu đã nhập đủ 20 ký tự, dừng nhập
    j read_loop

end_input:
    sb zero, 0(t0)     # Kết thúc chuỗi bằng NULL ('\0')

# Đảo ngược chuỗi
reverse_string:
    la t2, str         # t2 trỏ đến str
    add t2, t2, t1     # Dời t2 đến ký tự cuối của chuỗi
    la t3, reversed    # t3 trỏ đến reversed

reverse_loop:
    blt t1, zero, show_result  # Khi hết ký tự thì dừng
    lb t4, -1(t2)     # Lấy ký tự cuối cùng từ str
    sb t4, 0(t3)      # Gán vào reversed
    addi t2, t2, -1   # Lùi về trước trong str
    addi t3, t3, 1    # Tiến lên trong reversed
    addi t1, t1, -1
    j reverse_loop

show_result:
    sb zero, 0(t3)      # Thêm ký tự kết thúc chuỗi vào reversed
    li a7, 4           # Print thông báo
    la a0, message2
    ecall
    li a7, 4           # Print reversed
    la a0, reversed
    ecall

exit:
    li a7, 10          # Syscall 10: Thoát
    ecall

	
