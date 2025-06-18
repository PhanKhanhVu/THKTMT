.data
string : .space 1024                
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
message: .asciz "Try another string?" # From g13_s06.asm

.text
main: # Bắt đầu của chương trình chính - We'll jump to getInput directly
	j	getInput

getInput:
  li a7, 4
  la a0, Input
  ecall
  li a7, 8
  la a0, string 
  li a1, 1024 # Max length from final_stack_with_parity.asm
  ecall
  
  # cac bien dung chung
  li t1, 10               # ngăn cách giữa số , chữ trong hex , vua la enter
  li t2, 0                # n = độ dài chuỗi 
  la s1 string
count_n:
  lb s2 0(s1)
  beq s2, t1, exit_count_n   # gap enter (ácii 10 )
  addi t2, t2, 1           # n = n+1 
  addi s1, s1, 1           # next element
  j count_n 
exit_count_n: # Renamed to avoid conflict with `exit` syscall
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
  li t3, 0 # chi so i trong A[i] (Current character index, will be increased by 8 for each block)
  la s1, string   # s1 now points to the beginning of the input string
Loop:
  beq t3, t2, finish # If current index (t3) equals total length (t2), finish
  li s3, 0 # Loop counter for pushing 8 characters
  li s4, 7 # End condition for pushing 8 characters (0 to 7)
  
push:# lay 1 lan 8 ki tu 
  blt s4, s3, Xor # If s4 < s3 (meaning s3 reached 8), jump to Xor
  lb s5, 0(s1) # Load byte from string into s5
  addi sp, sp, -1 # Decrement stack pointer
  sb s5, 0(sp) # Store byte onto stack
  addi s3, s3, 1 # Increment character counter
  addi s1, s1, 1 # Move to next character in string
  j push

Xor:
  add s10, zero, sp  # s10 holds the stack pointer before pushing parity bytes (points to byte0)
  addi sp, sp, -4 # sp moved down 4 bytes (for the 4 parity bytes)
  
  # Calculate and store parity bytes on stack
  lb s6, 3(s10) # byte3
  lb s7, 7(s10) # byte7
  xor t8, s7, s6 # byte3 ^ byte7
  sb t8, 0(sp) # Store parity on stack at (sp)
  
  lb s6, 2(s10) # byte2
  lb s7, 6(s10) # byte6
  xor t8, s7, s6 # byte2 ^ byte6
  sb t8, 1(sp) # Store parity on stack at (sp+1)
  
  lb s6, 1(s10) # byte1
  lb s7, 5(s10) # byte5
  xor t8, s7, s6 # byte1 ^ byte5
  sb t8, 2(sp) # Store parity on stack at (sp+2)
  
  lb s6, 0(s10) # byte0
  lb s7, 4(s10) # byte4
  xor t8, s7, s6 # byte0 ^ byte4
  sb t8, 3(sp) # Store parity on stack at (sp+3)

# The stack now contains: [P3, P2, P1, P0, B7, B6, B5, B4, B3, B2, B1, B0]
# s10 still points to B0
# sp points to P3

# cthuc : 3- [ (t3/8) % 3 ] 
  li a7,8 
  div t5 ,t3, a7     # t5 = t3 / 8 (block number)
  li a7,3 
  rem t5, t5, a7     # t5 = t5 % 3 (determines which disk holds parity)
  neg t5 , t5    
  add t5,a7,t5      # t5 will be 3, 2, or 1
        # xác định cách in dựa trên chỉ số (vị trí) của parity 
	li s7, 3 		# Parity on Disk 3 (Block 0, 3, 6...)
 	li s8, 2                # Parity on Disk 2 (Block 1, 4, 7...)
 	li s9, 1                 # Parity on Disk 1 (Block 2, 5, 8...)
	beq t5, s7, parity_3rd
	beq t5, s8, Parity_2nd
	beq t5, s9, Parity_1st
	
parity_3rd: # Disk 1 data, Disk 2 data, Disk 3 parity
  li a7,4
  la a0,stepdown 
  ecall 
  
  li a7, 4
  la a0, start 
  ecall
  
  # Print bytes 7, 6, 5, 4 (Disk 1 data)
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

  # Print bytes 3, 2, 1, 0 (Disk 2 data)
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

  li s3, 0 # Counter for printing 4 parity bytes
  li s4, 3 # Loop end for printing 4 parity bytes (0 to 3)
  j parity

parity: # Generic parity printing routine for parity_3rd
  blt s4, s3, end_parity # If s4 < s3 (printed all 4), exit loop
  lb a1, 0(sp) # Load parity byte from stack (sp points to P3, P2, P1, P0)
  andi s6, a1, 0xf0 # Get upper nibble
  srli s6, s6, 4
  
  bge s6, t1, char1 # If s6 >= 10, print as char
  blt s6, t1, num1 # Else print as number
  
num1:
  li a7, 1 # Print integer syscall
  add a0, zero ,s6
  ecall
  j after1
  
char1:
  addi s6, s6, 87 # Convert 10-15 to a-f ASCII ('a' is 97)
  li a7, 11 # Print character syscall
  add a0, zero ,s6
  ecall
  j after1
  
after1:
  andi s7, a1, 0x0f # Get lower nibble
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
  addi sp, sp, 1 # Move stack pointer up to next parity byte (P2, P1, P0)
  bne s3, s4, add_comma_space # If not the last parity byte, add comma and space
  addi s3, s3, 1 # Increment counter
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
Parity_2nd: # Disk 1 data, Disk 2 parity, Disk 3 data
  li a7, 4
  la a0, stepdown
  ecall
  
  li a7, 4
  la a0, start
  ecall
  
  # Print bytes 7, 6, 5, 4 (Disk 1 data)
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
  
  li s3, 0  # Counter for printing 4 parity bytes
  li s4, 3 # Loop end for printing 4 parity bytes
  j parity2
  
parity2: # Generic parity printing routine for Parity_2nd
  blt s4, s3, end_parity2
  lb a1, 0(sp)
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
  addi sp, sp, 1 # Move stack pointer up to next parity byte (P2, P1, P0)
  bne s3, s4, add_comma_space_2 # If not the last parity byte, add comma and space
  addi s3, s3, 1
  j parity2
  
add_comma_space_2:
  li a7, 4
  la a0, dauPhay
  ecall
  addi s3, s3, 1
  j parity2
  
end_parity2:
  # sp now points to P0. We need to move it back to where s10 pointed to (B0) to print B3-B0
  addi sp, sp, 4 # Adjust sp to original position of s10 (pointing to B0)
  
  li a7, 4
  la a0, brackets2
  ecall
  
  li a7, 4
  la a0, space_title
  ecall
  
  li a7, 4
  la a0, start
  ecall

  # Print bytes 3, 2, 1, 0 (Disk 3 data)
  li a7, 11
  lb a0, 3(s10) # Data bytes are relative to s10 (original start of 8-byte block on stack)
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
  
   
Parity_1st: # Disk 1 parity, Disk 2 data, Disk 3 data
  li a7, 4
  la a0, stepdown
  ecall

  li a7, 4
  la a0, brackets1
  ecall

  li s3, 0 # Counter for printing 4 parity bytes
  li s4, 3 # Loop end for printing 4 parity bytes
  j parity3

parity3: # Generic parity printing routine for Parity_1st
  blt s4, s3, end_parity3

  lb a1, 0(sp)
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
  addi sp, sp, 1 # Move stack pointer up to next parity byte (P2, P1, P0)
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
  # sp now points to P0. We need to move it back to where s10 pointed to (B0) to print B3-B0
  addi sp, sp, 4 # Adjust sp to original position of s10 (pointing to B0)
  
  li a7, 4
  la a0, brackets2
  ecall

  li a7, 4
  la a0, space_title
  ecall

  li a7, 4
  la a0, start
  ecall

  # Print bytes 7, 6, 5, 4 (Disk 2 data)
  li a7, 11
  lb a0, 7(s10) # Data bytes are relative to s10
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

  # Print bytes 3, 2, 1, 0 (Disk 3 data)
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
  addi t3, t3, 8 # Increment t3 (character index) by 8 for the next block
  addi sp, sp, 8 # Pop 8 data bytes off the stack
  j Loop

finish: # End of RAID simulation for current string
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
  
  j ask # Jump to ask if user wants to try another string

#--------------------TRY ANOTHER STRING----------------------------
ask: # Hỏi người dùng có muốn thử chuỗi khác không
	li	a7, 50				# syscall 50 (message dialog yes/no/cancel)
	la	a0, message
	ecall
	beq	a0, zero, clear			# a0: 0 = YES; 1 = NO; 2 = CANCEL - If a0 = 0 (Yes), jump to 'clear'
	nop
	j	exit				# If not Yes (No or Cancel), jump to 'exit'
	nop
	
# clear function: Return string to original state
clear: # Xóa nội dung chuỗi đầu vào cũ để chuẩn bị nhập mới
    la s0, string # s0 now points to the beginning of the string buffer
    mv s3, t2 # s3 = original length of the string
    add s3, s0, s3 # s3 = address of the end of the input string
    li t1, 0 # t1 = 0 (null terminator)

goAgain: # Return string to empty state to start again
    sb t1, 0(s0) # Store null terminator at s0
    addi s0, s0, 1 # Move to next character in string buffer
    blt s0, s3, goAgain # If s0 < s3 (not reached end of old string), continue clearing
    j getInput # Jump to getInput for new input

#-----Exit program----------
exit:
	li	a7, 10
	ecall