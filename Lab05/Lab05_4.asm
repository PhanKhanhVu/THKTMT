.data
buffer: .space 100
message1: .asciz "Nhap xau: "
message2: .asciz "Do dai xau la: "
message3: .asciz "Xau vuot qua ki tu hoac khong ton tai"
.text
li a7, 54
la a0, message1
la a1, buffer
li a2, 100
ecall

get_length:
la a0, buffer # a0 = address(string[0])
li t0, 0 # t0 = i = 0
check_char:
add t1, a0, t0 # t1 = a0 + t0 = address(string[0]+i)
lb t2, 0(t1) # t2 = string[i]
beq t2, zero, end_of_str # Nếu là ký tự NULL thì kết thúc
addi t0, t0, 1 # t0 = t0 + 1 -> i = i + 1
j check_char
end_of_str:
end_of_get_length:
print_length:
blt a1,zero,no_string		# neu a1 < 0 thi se khong co xau nao duoc nhap
addi t1,zero,1
sub a1,t0,t1
j have_string
no_string:
li a7, 59			#in ra message 3
la a0, message3		

ecall
j end
have_string:		
li a7,56			#in ra gia tri do dai xau khong tinh null
la a0,message2
ecall
end:
