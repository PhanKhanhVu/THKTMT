 .data
msg1: .asciz "The sum of "
	msg2: .asciz " and "
	msg3: .asciz " is "	
.text
# Gán giá trị số vào thanh ghi
    li s1, 10         # s1 = 10
    li s2, 20         # s2 = 20
    add s0, s1, s2    # s0 = s1 + s2
# In chuỗi "The sum of "
    li a7, 4
    la a0, msg1
    ecall
# In số s1
    li a7, 1
    mv a0, s1
    ecall
# In chuỗi " and "
    li a7, 4
    la a0, msg2
    ecall
# In số s2
    li a7, 1
        mv a0, s2
    ecall
# In chuỗi " is "
    li a7, 4
    la a0, msg3
    ecall
# In kết quả tổng
    li a7, 1
    mv a0, s0
    ecall
# Kết thúc chương trình
    li a7, 10
    ecall

