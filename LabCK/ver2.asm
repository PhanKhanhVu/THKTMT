.data
string : .space 1024          
string_parity : .space 1024      
Input: .asciz "\nNhap chuoi ki tu: "   
invalid: .asciz "\nNhap sai yeu cau roi"
prompt1: .asciz "       Disk 1       "       
prompt2: .asciz "       Disk 2       "       
prompt3: .asciz "       Disk 3       "      
stepdown : .asciz "\n"
start: .asciz    "|       "           
end: .asciz "       |"             
brackets1: .asciz "[[  "                              
brackets2: .asciz "  ]] "                
space_title: .asciz "          "       
dauPhay: .asciz ","  
CachDong: .asciz "--------------------"     
newline: .asciz "\n"

.text
la t6,string_parity
getInput:
  li a7, 4
  la a0, Input
  ecall
  li a7, 8
  la a0, string 
  li a1, 1024
  ecall
  
  # cac bien dung chung
  li t1, 10               # ngăn cách giữa số , chữ trong hex , vua la enter
  li t2, 0                # n = độ dài chuỗi 
  la s1 string
count_n:
  lb s2 0(s1)
  beq s2, t1, exit   # gap enter (ácii 10 )
  addi t2, t2, 1           # n = n+1 
  addi s1, s1, 1           # next element
  j count_n 
exit:
  # check bội của 8 
  li t4, 8
  rem t4, t2, t4
  bnez t4, again      
  li t4, 8
  j valid       # Chuyển đến in tiêu đề đĩa
again:
  # Hiển thị cảnh báo và yêu cầu nhập lại
  li a7, 4
  la a0, invalid
  ecall
  j getInput
# ================================================================================== 
# Else, Nhập đúng rồi, chạy bình thường 
# ================================================================================== 
valid:
# 2 dong dau
  li a7, 4
  la a0, prompt1
  ecall

  li a7, 4
  la a0, space_title
  ecall
  
  li a7, 4
  la a0, prompt2
  ecall
  
  li a7, 4
  la a0, space_title
  ecall
  
  li a7, 4
  la a0, prompt3
  ecall
  
 li a7,4
 la a0,stepdown
 ecall 
 
  li a7,4
 la a0,CachDong
 ecall
 
 li a7,4
 la a0,space_title
 ecall
 
 li a7,4
 la a0,CachDong
 ecall
 
 li a7,4
 la a0,space_title
 ecall
 
 li a7,4
 la a0,CachDong
 ecall


Chuan_bi_du_lieu:
  li t3, 0 # chi so i trong A[i]
  la s1, string   
Loop:
  beq t3, t2, finish
  li s3, 0
  li s4, 7
  
push:# lay 1 lan 8 ki tu 
  blt s4, s3, Xor 
  lb s5,0(s1)
  addi sp, sp, -1
  sb s5, 0(sp)
  addi s3, s3, 1
  addi s1, s1, 1 
  j push

Xor:
  add s10, zero, sp  # dung s10 thay sp cu
  addi sp,sp,-4 # sp moi
  
  lb s6, 3(s10)
  lb s7, 7(s10)
  xor s7, s7, s6
  sb s7,-1(s10)
  sb s7,0(t6  )
  
  lb s6, 2(s10)
  lb s7, 6(s10)
  xor s7, s7, s6
  sb s7,-2(s10)
  sb s7,1(t6  )
  
  lb s6, 1(s10)
  lb s7, 5(s10)
  xor s7, s7, s6
  sb s7,-3(s10)
  sb s7,2(t6  )
  
  lb s6, 0(s10)
  lb s7, 4(s10)
  xor s7, s7, s6
  sb s7,-4(s10)
  sb s7,3(t6 )
  
  # cthuc : 3- [ (t3/8) % 3 ] 
  li a7,8 
  div t5 ,t3, a7     # t5 = t3 / 8
  li a7,3 
  rem t5, t5, a7     # t5 = t5 % 3
  neg t5 , t5    
  add t5,a7,t5 
        # xác định cách in dựa trên chỉ số (vị trí) của parity 
	li s7, 3 		# Chỉ số parity 3rd
 	li s8, 2                # Chỉ số parity 2nd
 	li s9, 1                 # Chỉ số parity 1st
	beq t5, s7, parity_3rd
	beq t5, s8, Parity_2nd
	beq t5, s9, Parity_1st
	
parity_3rd:
  li a7,4
  la a0,stepdown 
  ecall 
  
  li a7, 4
  la a0, start 
  ecall
  
  li a7, 11
  lb a0, 7(s10)
  ecall

  li a7, 11
  lb a0, 6(s10)
  ecall  
  
  li a7, 11
  lb a0, 5(s10)
  ecall  
  
  li a7, 11
  lb a0, 4(s10)
  ecall

  li a7, 4
  la a0, end 
  ecall
  
  li a7, 4
  la a0, space_title
  ecall
  
  li a7, 4
  la a0, start
  ecall

  li a7, 11
  lb a0, 3(s10)
  ecall  
  
  li a7, 11
  lb a0, 2(s10)
  ecall  
  
  li a7, 11
  lb a0, 1(s10)
  ecall  
  
  li a7, 11
  lb a0, 0(s10)
  ecall
  
  li a7, 4
  la a0, end
  ecall
  
  li a7, 4
  la a0, space_title
  ecall
  
  li a7, 4
  la a0, brackets1
  ecall

  li s3, 0
  li s4, 3
  j parity

parity:
  blt s4, s3, end_parity
  lb a1, -1(s10)
  andi s6, a1, 0xf0
  srli s6, s6, 4
  
  bge s6, t1, char1
  blt s6, t1, num1
  
num1:
  li a7, 1
  add a0, zero ,s6
  ecall
  j after1
  
char1:
  addi s6, s6, 87
  li a7, 11
  add a0, zero ,s6
  ecall
  j after1
  
after1:
  andi s7, a1, 0x0f
  bge s7, t1, char2
  blt s7, t1, num2
  
num2:
  li a7, 1
  add a0, zero ,s7
  ecall
  j after2
  
char2:
  addi s7, s7, 87
  li a7, 11
  add a0, zero ,s7
  ecall
  j after2
  
after2:
  addi s10, s10, -1
  bne s3, s4, add_comma_space
  addi s3, s3, 1
  j parity
  
add_comma_space:
  li a7, 4
  la a0, dauPhay
  ecall
  addi s3, s3, 1
  j parity
  
end_parity:
  li a7, 4
  la a0, brackets2
  ecall
  j end_current_loop



#----------------------
Parity_2nd:
  li a7, 4
  la a0, stepdown
  ecall
  
  li a7, 4
  la a0, start
  ecall
  
  li a7, 11
  lb a0, 7(s10)
  ecall
  
  li a7, 11
  lb a0, 6(s10)
  ecall  
  
  li a7, 11
  lb a0, 5(s10)
  ecall  
  
  li a7, 11
  lb a0, 4(s10)
  ecall

  li a7, 4
  la a0, end
  ecall
  
  li a7, 4
  la a0, space_title
  ecall
  
  li a7, 4
  la a0, brackets1
  ecall
  
  li s3, 0  #biến đếm 
  li s4, 3
  j parity2
  
parity2:
  blt s4, s3, end_parity2
  lb a1, -1(s10)
  andi s6, a1, 0xf0
  srli s6, s6, 4
  
  bge s6, t1, char1_2
  blt s6, t1, num1_2
  
num1_2:
  li a7, 1
  add a0, zero ,s6
  ecall
  j after1_2
  
char1_2:
  addi s6, s6, 87
  li a7, 11
  add a0, zero ,s6
  ecall
  j after1_2
  
after1_2:
  andi s7, a1, 0x0f
  bge s7, t1, char2_2
  blt s7, t1, num2_2
  
num2_2:
  li a7, 1
  add a0, zero ,s7
  ecall
  j after2_2
  
char2_2:
  addi s7, s7, 87
  li a7, 11
  add a0, zero ,s7
  ecall
  j after2_2
  
after2_2:
  addi s10, s10, -1
  bne s3, s4, add_comma_space_2 #s3 = s4, quay về parity 2, end 
  addi s3, s3, 1
  j parity2
  
add_comma_space_2:
  li a7, 4
  la a0, dauPhay
  ecall
  addi s3, s3, 1
  j parity2
  
end_parity2:
  addi s10,s10,4
  
  li a7, 4
  la a0, brackets2
  ecall
  
  li a7, 4
  la a0, space_title
  ecall
  
  li a7, 4
  la a0, start
  ecall

  li a7, 11
  lb a0, 3(s10)
  ecall  
  
  li a7, 11
  lb a0, 2(s10)
  ecall  
  
  li a7, 11
  lb a0, 1(s10)
  ecall  
  
  li a7, 11
  lb a0, 0(s10)
  ecall
  
  li a7, 4
  la a0, end
  ecall
	
  j end_current_loop 
  
   
Parity_1st:
  li a7, 4
  la a0, stepdown
  ecall

  li a7, 4
  la a0, brackets1
  ecall

  li s3, 0
  li s4, 3
  j parity3

parity3:
  blt s4, s3, end_parity3

  lb a1, -1(s10)
  andi s6, a1, 0xf0
  srli s6, s6, 4

  bge s6, t1, char1_3
  blt s6, t1, num1_3

num1_3:
  li a7, 1
  add a0, zero, s6
  ecall
  j after1_3

char1_3:
  addi s6, s6, 87
  li a7, 11
  add a0, zero, s6
  ecall
  j after1_3

after1_3:
  andi s7, a1, 0x0f
  bge s7, t1, char2_3
  blt s7, t1, num2_3

num2_3:
  li a7, 1
  add a0, zero, s7
  ecall
  j after2_3

char2_3:
  addi s7, s7, 87
  li a7, 11
  add a0, zero, s7
  ecall
  j after2_3

after2_3:
  addi s10, s10, -1
  bne s3, s4, add_comma_space_3
  addi s3, s3, 1
  j parity3

add_comma_space_3:
  li a7, 4
  la a0, dauPhay
  ecall
  addi s3, s3, 1
  j parity3

end_parity3:
  addi s10,s10,4
  
  li a7, 4
  la a0, brackets2
  ecall

  li a7, 4
  la a0, space_title
  ecall

  li a7, 4
  la a0, start
  ecall

  li a7, 11
  lb a0, 7(s10)
  ecall

  li a7, 11
  lb a0, 6(s10)
  ecall  

  li a7, 11
  lb a0, 5(s10)
  ecall  

  li a7, 11
  lb a0, 4(s10)
  ecall

  li a7, 4
  la a0, end
  ecall

  li a7, 4
  la a0, space_title
  ecall

  li a7, 4
  la a0, start
  ecall

  li a7, 11
  lb a0, 3(s10)
  ecall  

  li a7, 11
  lb a0, 2(s10)
  ecall  

  li a7, 11
  lb a0, 1(s10)
  ecall  

  li a7, 11
  lb a0, 0(s10)
  ecall

  li a7, 4
  la a0, end
  ecall

  j end_current_loop


end_current_loop:
  addi t3, t3, 8
  addi sp,sp,-4
  addi t6,t6,4
  j Loop

finish:
  li a7,4
  la a0,stepdown
  ecall
  
  li a7, 4
  la a0, CachDong
  ecall
  
  li a7, 4
  la a0, space_title
  ecall
  
  li a7, 4
  la a0, CachDong
  ecall
  
  li a7, 4
  la a0, space_title
  ecall
  
  li a7, 4
  la a0, CachDong
  ecall
  

li a6, 0    
la t6, string_parity
aka:
    li a7, 4
    la a0, newline
    ecall
    li s5,12 
    bge a6, s5, enddd # Nếu a6 >= s5, nhảy đến enddd

    lb a0, 0(t6) # Tải byte từ địa chỉ t6 vào a0.
                 # Lưu ý: syscall 36 in 32-bit (0x000000XX).
                 # Nếu muốn chỉ 2 ký tự hex (XX), bạn phải dùng syscall 11 và tự chuyển đổi.
    li a7, 36    # Syscall để in số nguyên dưới dạng hex (chỉ trong MARS/RARS)
    ecall

    # In dấu cách để dễ nhìn
    li a7, 4
    la a0, space_title # Giả sử bạn đã định nghĩa .asciz " " cho space_char
    ecall

    addi t6, t6, 1 # Tăng con trỏ t6 để trỏ đến byte parity tiếp theo
    addi a6, a6, 1 # Tăng biến đếm số byte đã in

    j aka          # Nhảy trở lại đầu vòng lặp

enddd:
