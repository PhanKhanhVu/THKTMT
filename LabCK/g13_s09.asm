.data
# Phan du lieu hien co
numbers: .space 80000  				# Vùng nhớ 80000 byte để lưu trữ các số đã đọc từ file
input_buffer_size: .word 80000  		# Kích thước của buffer đọc file
count: .word 0      				# Biến đếm số lượng các số nguyên đã đọc được
    
# Them mang bitmask cho so am (1 bit moi so)
# Voi 80000 byte so (20000 so nguyen), chung ta can 20000 bit = 2500 byte
neg_bitmask: .space 2500 			# Mảng bitmask để đánh dấu các số âm, mỗi bit tương ứng một số
    
input_filename: .space 256
file_read_buffer: .space 1024 			# Buffer tạm để đọc từng phần của file
msg_prompt_input: .asciz "Enter filename: "
error_msg: .asciz "\nError opening file\n"
menu: .asciz "\nUser select sorting algorithm:\n1. Bubble Sort\n2. Insertion Sort\n3. Selection Sort\n4. Quick Sort\n5. Close\nChoice: "
    
fd: .word 0					# Biến lưu trữ file descriptor của file input
newline: .asciz "\n"
space: .string " "
start_time: .word 0
end_time: .word 0
    
msg_execution_time: .asciz "\nExecution time (ms): "
    
# Du lieu moi cho file output
output_filename: .asciz "C:\\RISCV\\output5.txt"
out_fd: .word 0					# Biến lưu trữ file descriptor của file output
buffer_number: .space 12			# Buffer tạm để chuyển đổi số sang chuỗi khi ghi file
msg_file_error_open: .asciz "\nError writing to output file\n"
char_minus: .asciz "-"
.text
.globl main
main:
	# In ra msg_prompt_input
	li	a7, 4
	la	a0, msg_prompt_input
	ecall
	# Doc input_filename
	li	a7, 8
	la	a0, input_filename
	li	a1, 256
	ecall
	# Loai bo newline khoi input_filename
	la	t0, input_filename
remove_newline_from_filename:
	# Kiem tra tung ky tu de tim newline
	lb	t1, 0(t0)
	beqz	t1, open_input_file
	li	t2, 10				# 10 = "\n"
	beq	t1, t2, replace_null
	addi	t0, t0, 1
	j	remove_newline_from_filename
replace_null:
	# Thay the newline bang null terminator
	sb	zero, 0(t0)
	
open_input_file:
	# Mo file input
	li	a7, 1024
	la	a0, input_filename
	li	a1, 0
	ecall
	# Kiem tra loi mo file
	bltz	a0, file_error_open
	# Luu file descriptor
	la	t1, fd
	sw	a0, 0(t1)
	# Goi ham doc so tu file
	jal	read_numbers
	
menu_loop:
	# Hien thi menu
	li	a7, 4
	la	a0, menu
	ecall
	
	# Doc lua chon cua nguoi dung
	li	a7, 5
	ecall
	
	# Xu ly lua chon
	li	t0, 1
	beq	a0, t0, bubble_sort_array
	li	t0, 2
	beq	a0, t0, insertion_sort_array
	li	t0, 3
	beq	a0, t0, selection_sort_array
	li	t0, 4
	beq	a0, t0, quick_sort_array
	li	t0,5
	beq	a0, t0, exit
	# Lua chon khong hop le, thoat
	j	exit

file_error_open:
	# In ra thong bao loi mo file
	li	a7, 4
	la	a0, error_msg
	ecall
	j	exit

read_numbers:
	# Luu thanh ghi vao stack
	addi	sp, sp, -16
	sw	ra, 12(sp)
	sw	s0, 8(sp)
	sw	s1, 4(sp)
	sw	s2, 0(sp)

	# Reset count ve 0
	la	t1, count
	sw	zero, 0(t1)
	
	# Khoi tao bien tam de parse so
	li	t0, 0				# So hien tai dang duoc parse
	li	t1, 0				# Co bao hieu dang trong mot so (1=true)
	li	t6, 0				# Co bao hieu so am (1=am)

read_loop:
	# Doc mot ky tu tu file
	li	a7, 63				# Syscall: 63 - Read
	lw	a0, fd
	la	a1, file_read_buffer
	li	a2, 1
	ecall

	# Kiem tra cuoi file
	beqz	a0, read_done
	
	# Tai ky tu da doc
	lb	t2, 0(a1)
	
	# Kiem tra dau tru '-'
	li	t3, 45
	bne	t2, t3, not_char_minus
	beqz	t1, set_negative
	j	read_loop 
	
set_negative:
	# Dat co so am va co dang trong so
	li	t6, 1
	li	t1, 1
	j	read_loop
	
not_char_minus:
	# Kiem tra ky tu phan cach (space hoac newline)
	li	t3, 32
	beq	t2, t3, save_number
	li	t3, 10
	beq	t2, t3, save_number
	
	# Chuyen doi ky tu ASCII so sang gia tri so
	addi	t2, t2, -48
	li	t3, 10
	mul	t0, t0, t3
	add	t0, t0, t2
	li	t1, 1 # Dat co dang trong so
	j	read_loop
	
save_number:
	# Chi luu neu dang trong mot so
	beqz	t1, read_loop
	
	# Ap dung dau (neu la so am)
	beqz	t6, save_positive
	neg	t0, t0
	
save_positive:
	# Luu so vao mang numbers
	la	t3, count
	lw	t3, 0(t3)
	slli	t4, t3, 2
	la	t5, numbers
	add	t5, t5, t4
	sw	t0, 0(t5)
	
	# Tang bien dem count
	addi	t3, t3, 1
	la	t4, count
	sw	t3, 0(t4)
	
	# Reset bien tam cho so tiep theo
	li	t0, 0
	li	t1, 0
	li	t6, 0
	j	read_loop

read_done:
	# Luu so cuoi cung neu dang parse do khi het file
	beqz	t1, close_file
	
	# Ap dung dau cho so cuoi
	beqz	t6, save_last_positive
	neg	t0, t0
	
save_last_positive:
	# Luu so cuoi vao mang
	la	t3, count
	lw	t3, 0(t3)
	slli	t4, t3, 2
	la	t5, numbers
	add	t5, t5, t4
	sw	t0, 0(t5)
	# Tang count cho so cuoi
	addi	t3, t3, 1
	la	t4, count
	sw	t3, 0(t4)

close_file:
	# Dong file input
	li	a7, 57
	lw	a0, fd
	ecall
	
	# Khoi phuc thanh ghi tu stack
	lw	ra, 12(sp)
	lw	s0, 8(sp)
	lw	s1, 4(sp)
	lw	s2, 0(sp)
	addi	sp, sp, 16
	ret

flag_negative_numbers:
	# Luu thanh ghi
	addi	sp, sp, -16
	sw	ra, 12(sp)
	sw	s0, 8(sp)
	sw	s1, 4(sp)
	sw	s2, 0(sp)
	
	# Khoi tao s0 (dia chi mang), s1 (size), s2 (index)
	mv	s0, a0
	mv	s1, a1
	li	s2, 0
	
flag_loop:
	# Kiem tra ket thuc vong lap
	bge	s2, s1, flag_done
	
	# Tai so hien tai numbers[s2]
	slli	t0, s2, 2
	add	t0, s0, t0
	lw	t1, 0(t0)
	
	# Neu so duong, bo qua
	bgez	t1, skip_flag
	
	# Tinh toan offset byte va vi tri bit trong bitmask
	mv	t0, s2
	srai	t1, t0, 3			# byte_offset = index / 8
	andi	t2, t0, 0x7			# bit_position = index % 8
	li	t3, 1
	sll	t3, t3, t2			# tao bit mask: 1 << bit_position
	
	# Dat bit trong neg_bitmask
	la	t4, neg_bitmask
	add	t4, t4, t1			# dia chi byte trong bitmask
	lb	t5, 0(t4)			# load byte hien tai
	or	t5, t5, t3			# set bit
	sb	t5, 0(t4)			# luu lai byte
	
skip_flag:
	# Tang index
	addi	s2, s2, 1
	j	flag_loop
	
flag_done:
	# Khoi phuc thanh ghi
	lw	ra, 12(sp)
	lw	s0, 8(sp)
	lw	s1, 4(sp)
	lw	s2, 0(sp)
	addi	sp, sp, 16
	ret

quick_sort_array:
	# Lay thoi gian bat dau
	jal	get_time
	sw	a0, start_time, t0 		# t0 la thanh ghi tam, khong can thiet
	
	# Goi Quick Sort
	la	a0, numbers
	li	a1, 0
	lw	a2, count
	addi	a2, a2, -1
	jal	quick_sort_logic
	
	# (Logic danh dau so am co the can xem lai sau khi sap xep gia tri tuyet doi)
	la	a0, numbers
	lw	a1, count
	jal	flag_negative_numbers
	
	# Lay thoi gian ket thuc va in
	jal	get_time
	sw	a0, end_time, t0
	jal	print_time
	
	# Ghi ket qua ra file
	jal	write_results
	j	menu_loop 			# Quay lai menu chinh

quick_sort_logic:
	# Luu thanh ghi vao stack
	addi	sp, sp, -24
	sw	ra, 20(sp)
	sw	s0, 16(sp) 			# array_base
	sw	s1, 12(sp) 			# left_index
	sw	s2, 8(sp)  			# right_index
	sw	s3, 4(sp)  			# pivot_index
	sw	s4, 0(sp)  			# unused
	
	# Luu cac tham so vao thanh ghi s
	mv	s0, a0
	mv	s1, a1
	mv	s2, a2
	
	# Dieu kien dung de quy
	bge	s1, s2, quick_sort_end
	
	# Goi ham phan hoach (partition)
	mv	a0, s0
	mv	a1, s1
	mv	a2, s2
	jal	partition_elements
	mv	s3, a0 				# Luu chi so pivot
	
	# De quy Quick Sort cho phan ben trai pivot
	mv	a0, s0
	mv	a1, s1
	addi	a2, s3, -1
	jal	quick_sort_logic
	
	# De quy Quick Sort cho phan ben phai pivot
	mv	a0, s0
	addi	a1, s3, 1
	mv	a2, s2
	jal	quick_sort_logic
	
quick_sort_end:
	# Khoi phuc thanh ghi tu stack
	lw	ra, 20(sp)
	lw	s0, 16(sp)
	lw	s1, 12(sp)
	lw	s2, 8(sp)
	lw	s3, 4(sp)
	lw	s4, 0(sp)
	addi	sp, sp, 24
	ret

partition_elements:
	# Luu thanh ghi
	addi	sp, sp, -24
	sw	ra, 20(sp)
	sw	s0, 16(sp) 			# array_base
	sw	s1, 12(sp) 			# left
	sw	s2, 8(sp)  			# right
	sw	s3, 4(sp)  			# pivot_value
	sw	s4, 0(sp)  			# i (index of smaller element)
	
	# Luu tham so
	mv	s0, a0
	mv	s1, a1
	mv	s2, a2

	# Chon pivot la phan tu cuoi cung arr[right]
	slli	t0, s2, 2
	add	t0, s0, t0
	lw	s3, 0(t0) 			# s3 = pivot_value
	
	# Khoi tao i = left - 1
	addi	s4, s1, -1
	# Khoi tao j = left
	mv	t1, s1
	
partition_loop_elements:
	# Vong lap j tu left den right-1
	bge	t1, s2, partition_elements_done
	
	# Tai phan tu arr[j]
	slli	t0, t1, 2
	add	t0, s0, t0
	lw	t2, 0(t0) 			# t2 = arr[j]
	
	# Neu arr[j] <= pivot_value
	bgt	t2, s3, skip_swap
	
	# Tang i
	addi	s4, s4, 1
	
	# Hoan doi arr[i] va arr[j]
	slli	t0, s4, 2 			# dia chi arr[i]
	add	t0, s0, t0
	slli	t3, t1, 2			# dia chi arr[j]
	add	t3, s0, t3
	
	lw	t4, 0(t0)			# temp = arr[i]
	lw	t5, 0(t3)			# arr[j]
	sw	t5, 0(t0)			# arr[i] = arr[j]
	sw	t4, 0(t3)			# arr[j] = temp
	
skip_swap:
	# Tang j
	addi	t1, t1, 1
	j	partition_loop_elements
	
partition_elements_done:
	# Hoan doi arr[i+1] voi arr[right] (pivot)
	addi	s4, s4, 1 			# i+1
	
	slli	t0, s4, 2			# dia chi arr[i+1]
	add	t0, s0, t0
	slli	t1, s2, 2			# dia chi arr[right]
	add	t1, s0, t1
	
	lw	t2, 0(t0)			# temp = arr[i+1]
	lw	t3, 0(t1)			# arr[right] (pivot_value)
	sw	t3, 0(t0)			# arr[i+1] = pivot_value
	sw	t2, 0(t1)			# arr[right] = temp
	
	# Tra ve chi so cua pivot (i+1)
	mv	a0, s4
	
	# Khoi phuc thanh ghi
	lw	ra, 20(sp)
	lw	s0, 16(sp)
	lw	s1, 12(sp)
	lw	s2, 8(sp)
	lw	s3, 4(sp)
	lw	s4, 0(sp)
	addi	sp, sp, 24
	ret

bubble_sort_array:
	# Lay thoi gian bat dau
	jal	get_time
	sw	a0, start_time, t0
	
	# Goi Bubble Sort core
	la	a0, numbers
	lw	a1, count
	jal	bubble_sort_core
	
	# Danh dau so am
	la	a0, numbers
	lw	a1, count
	jal	flag_negative_numbers

	# Lay thoi gian ket thuc va in
	jal	get_time
	sw	a0, end_time, t0
	jal	print_time
	
	# Ghi ket qua ra file
	jal	write_results
	j	menu_loop

insertion_sort_array:
	# Lay thoi gian bat dau
	jal	get_time
	sw	a0, start_time, t0
	
	# Goi Insertion Sort core
	la	a0, numbers
	lw	a1, count
	jal	insertion_sort_array_impl
	
	# Danh dau so am
	la	a0, numbers
	lw	a1, count
	jal	flag_negative_numbers

	# Lay thoi gian ket thuc va in
	jal	get_time
	sw	a0, end_time, t0
	jal	print_time
	
	# Ghi ket qua ra file
	jal	write_results
	j	menu_loop

selection_sort_array:
	# Lay thoi gian bat dau
	jal	get_time
	sw	a0, start_time, t0
	
	# Goi Selection Sort core
	la	a0, numbers
	lw	a1, count
	jal	selection_sort_array_impl
	
	# Danh dau so am
	la	a0, numbers
	lw	a1, count
	jal	flag_negative_numbers
	
	# Lay thoi gian ket thuc va in
	jal	get_time
	sw	a0, end_time, t0
	jal	print_time
	
	# Ghi ket qua ra file
	jal	write_results
	j	menu_loop

bubble_sort_core:
	# Luu thanh ghi
	addi	sp, sp, -16
	sw	ra, 12(sp)
	sw	s0, 8(sp)  			# array_base
	sw	s1, 4(sp)  			# size
	sw	s2, 0(sp)  			# i
	
	# Khoi tao
	mv	s0, a0
	mv	s1, a1
	li	s2, 0 				# i = 0
	
outer_loop_bubble_sort:
	# Vong lap ngoai: i from 0 to size-1
	bge	s2, s1, bubble_done
	li	t0, 0 				# j = 0
	
inner_loop_bubble_sort:
	# Vong lap trong: j from 0 to size-i-2
	sub	t1, s1, s2
	addi	t1, t1, -1 			# limit for j is size-i-1
	bge	t0, t1, inner_done_bubble_sort
	
	# So sanh arr[j] va arr[j+1]
	slli	t2, t0, 2
	add	t2, s0, t2 			# dia chi arr[j]
	lw	t3, 0(t2)  			# arr[j]
	lw	t4, 4(t2)  			# arr[j+1]
	
	# Neu arr[j] <= arr[j+1], khong doi cho
	ble	t3, t4, no_swap_bubble_sort
	
	# Hoan doi arr[j] va arr[j+1]
	sw	t4, 0(t2)
	sw	t3, 4(t2)
	
no_swap_bubble_sort:
	# Tang j
	addi	t0, t0, 1
	j	inner_loop_bubble_sort
	
inner_done_bubble_sort:
	# Tang i
	addi	s2, s2, 1
	j	outer_loop_bubble_sort
	
bubble_done:
	# Khoi phuc thanh ghi
	lw	ra, 12(sp)
	lw	s0, 8(sp)
	lw	s1, 4(sp)
	lw	s2, 0(sp)
	addi	sp, sp, 16
	ret

insertion_sort_array_impl:
	# Luu thanh ghi
	addi	sp, sp, -16
	sw	ra, 12(sp)
	sw	s0, 8(sp)  			# array_base
	sw	s1, 4(sp)  			# size
	sw	s2, 0(sp)  			# i
	
	# Khoi tao
	mv	s0, a0
	mv	s1, a1
	li	s2, 1 				# i = 1
	
outer_loop_insertion:
	# Vong lap ngoai: i from 1 to size-1
	bge	s2, s1, insertion_done
	
	# Lay key = arr[i]
	slli	t0, s2, 2
	add	t0, s0, t0 			# dia chi arr[i]
	lw	t1, 0(t0)  			# t1 = key
	# Khoi tao j = i-1
	addi	t2, s2, -1 			# t2 = j
	
inner_loop_insertion:
	# Vong lap trong: j from i-1 down to 0 AND arr[j] > key
	bltz	t2, inner_done_insertion 	# Neu j < 0
	
	# So sanh arr[j] voi key
	slli	t3, t2, 2
	add	t3, s0, t3 			# dia chi arr[j]
	lw	t4, 0(t3)  			# t4 = arr[j]
	
	ble	t4, t1, inner_done_insertion 	# Neu arr[j] <= key
	
	# Dich chuyen arr[j] sang arr[j+1]
	sw	t4, 4(t3) 			# arr[j+1] = arr[j] (dia chi cua arr[j+1] la 4(t3))
	
	# Giam j
	addi	t2, t2, -1
	j	inner_loop_insertion
	
inner_done_insertion:
	# Chen key vao vi tri arr[j+1]
	addi	t2, t2, 1 			# j+1
	slli	t3, t2, 2
	add	t3, s0, t3 			# dia chi arr[j+1]
	sw	t1, 0(t3)  			# arr[j+1] = key
	
	# Tang i
	addi	s2, s2, 1
	j	outer_loop_insertion
	
insertion_done:
	# Khoi phuc thanh ghi
	lw	ra, 12(sp)
	lw	s0, 8(sp)
	lw	s1, 4(sp)
	lw	s2, 0(sp)
	addi	sp, sp, 16
	ret

selection_sort_array_impl:
	# Luu thanh ghi
	addi	sp, sp, -16
	sw	ra, 12(sp)
	sw	s0, 8(sp)  			# array_base
	sw	s1, 4(sp)  			# size
	sw	s2, 0(sp)  			# i
	
	# Khoi tao
	mv	s0, a0
	mv	s1, a1
	li	s2, 0 				# i = 0
	
outer_loop_selection:
	# Vong lap ngoai: i from 0 to size-2
	addi	t0, s1, -1 			# size-1
	bge	s2, t0, selection_done
	
	# Khoi tao min_idx = i
	mv	t1, s2 				# t1 = min_idx
	# Khoi tao j = i+1
	addi	t2, s2, 1 			# t2 = j
	
inner_loop_selection:
	# Vong lap trong: j from i+1 to size-1
	bge	t2, s1, inner_done_selection
	
	# So sanh arr[j] voi arr[min_idx]
	slli	t3, t2, 2
	add	t3, s0, t3 			# dia chi arr[j]
	lw	t4, 0(t3)  			# t4 = arr[j]
	
	slli	t5, t1, 2
	add	t5, s0, t5 			# dia chi arr[min_idx]
	lw	t6, 0(t5)  			# t6 = arr[min_idx]
	
	# Neu arr[j] < arr[min_idx], cap nhat min_idx
	bge	t4, t6, no_update_min
	mv	t1, t2				# min_idx = j
	
no_update_min:
	# Tang j
	addi	t2, t2, 1
	j	inner_loop_selection
	
inner_done_selection:
	# Hoan doi arr[i] voi arr[min_idx] (neu min_idx != i)
	beq	t1, s2, no_swap_selection
	
	# temp = arr[i]
	slli	t2, s2, 2
	add	t2, s0, t2 			# dia chi arr[i]
	lw	t3, 0(t2)  			# t3 = temp
	
	# arr[i] = arr[min_idx]
	slli	t4, t1, 2
	add	t4, s0, t4 			# dia chi arr[min_idx]
	lw	t5, 0(t4)  			# t5 = arr[min_idx]
	sw	t5, 0(t2)
	
	# arr[min_idx] = temp
	sw	t3, 0(t4)
	
no_swap_selection:
	# Tang i
	addi	s2, s2, 1
	j	outer_loop_selection
	
selection_done:
	# Khoi phuc thanh ghi
	lw	ra, 12(sp)
	lw	s0, 8(sp)
	lw	s1, 4(sp)
	lw	s2, 0(sp)
	addi	sp, sp, 16
	ret

parse_loop:
	# (Day la doan code khong duoc su dung, s0, s1, s2 khong ro ngu canh)
	# Kiem tra dieu kien vong lap
	bge	s2, s0, read_loop
	
	# Doc ky tu tu buffer (s1 la base, s2 la offset)
	add	t0, s1, s2
	lb	t1, 0(t0)
	
	# Kiem tra space
	li	t2, 32
	beq	t1, t2, next_char
	
	# Chuyen ASCII sang so
	addi	t1, t1, -48
	
	# Luu so vao mang numbers
	lw	t3, count
	slli	t4, t3, 2
	la	t5, numbers
	add	t5, t5, t4
	sw	t1, 0(t5)
	
	# Tang count
	addi	t3, t3, 1
	sw	t3, count, t6 			# t6 la thanh ghi tam

next_char:
	# Tang offset s2
	addi	s2, s2, 1
	j	parse_loop

get_time:
	# Syscall lay thoi gian
	li	a7, 30
	ecall
	ret

print_time:
	# Tinh toan thoi gian thuc thi
	la	t0, start_time
	lw	t1, 0(t0)
	la	t0, end_time
	lw	t2, 0(t0)
	sub	t3, t2, t1 			# execution_time = end - start
	
	# In thong bao
	li	a7, 4
	la	a0, msg_execution_time
	ecall
	
	# In gia tri thoi gian
	li	a7, 1
	mv	a0, t3
	ecall
	ret

number_to_string:
	# Luu thanh ghi
	addi	sp, sp, -24
	sw	ra, 20(sp)
	sw	s0, 16(sp) 			# buffer_address
	sw	s1, 12(sp) 			# number_to_convert
	sw	s2, 8(sp)  			# string_length
	sw	s3, 4(sp)  			# negative_flag
	sw	s4, 0(sp)  			# temp_pointer_in_buffer
	
	# Khoi tao
	mv	s0, a0
	mv	s1, a1
	li	s2, 0
	li	s3, 0
	
	# Xu ly so 0
	bnez	s1, check_sign
	li	t0, 48 				# '0'
	sb	t0, 0(s0)
	li	a0, 1 				# length = 1
	j	num_to_str_done
	
check_sign:
	# Kiem tra so am
	bgez	s1, convert_digits
	li	s3, 1 				# set negative_flag
	neg	s1, s1 				# make number positive
	
convert_digits:
	# Chuyen doi cac chu so (luu nguoc vao buffer)
	mv	s4, s0 				# s4 la con tro tam trong buffer
digit_loop:
	beqz	s1, finalize_string 		# Neu so = 0, da xong phan chu so
	li	t1, 10
	rem	t2, s1, t1 			# t2 = last_digit
	div	s1, s1, t1 			# number = number / 10
	addi	t2, t2, 48 			# convert digit to ASCII
	sb	t2, 0(s4)  			# store digit in buffer
	addi	s4, s4, 1  			# advance buffer pointer
	addi	s2, s2, 1  			# increment length
	j	digit_loop
	
finalize_string:
	# Them dau '-' neu am
	beqz	s3, reverse_string
	li	t1, 45 				# '-'
	sb	t1, 0(s4)
	addi	s4, s4, 1
	addi	s2, s2, 1

reverse_string:
	# Dao nguoc chuoi trong buffer
	mv	a0, s0     			# start_address
	addi	a1, s4, -1 			# end_address (s4 dang o sau ky tu cuoi)
	jal	str_reverse
	
	# Tra ve do dai
	mv	a0, s2
	
num_to_str_done:
	# Khoi phuc thanh ghi
	lw	ra, 20(sp)
	lw	s0, 16(sp)
	lw	s1, 12(sp)
	lw	s2, 8(sp)
	lw	s3, 4(sp)
	lw	s4, 0(sp)
	addi	sp, sp, 24
	ret

str_reverse:
	# Kiem tra dieu kien dung (start_ptr >= end_ptr)
	bge	a0, a1, str_rev_done
	
	# Hoan doi ky tu
	lb	t0, 0(a0)
	lb	t1, 0(a1)
	sb	t1, 0(a0)
	sb	t0, 0(a1)
	
	# Di chuyen con tro
	addi	a0, a0, 1
	addi	a1, a1, -1
	j	str_reverse
	
str_rev_done:
	ret

write_results:
	# Luu thanh ghi
	addi	sp, sp, -16
	sw	ra, 12(sp)
	sw	s0, 8(sp)			# i (loop counter)
	sw	s1, 4(sp)  			# count (total numbers)
	sw	s2, 0(sp)  			# numbers_array_base
	
	# Mo file output
	li	a7, 1024
	la	a0, output_filename
	li	a1, 1    			# Write-only, create, truncate
	li	a2, 0x1ff 			# Permissions rwxrwxrwx
	ecall
	
	# Kiem tra loi mo file
	bltz	a0, msg_file_error_openor
	sw	a0, out_fd, t0 			# Luu output file descriptor
	
	# Khoi tao vong lap ghi file
	li	s0, 0 # i = 0
	lw	s1, count
	la	s2, numbers
	
write_loop:
	# Kiem tra ket thuc vong lap
	bge	s0, s1, write_done
	
	# Tai so hien tai numbers[i]
	slli	t0, s0, 2
	add	t1, s2, t0
	lw	t2, 0(t1)
	
	# Chuyen so sang chuoi
	la	a0, buffer_number
	mv	a1, t2
	jal	number_to_string
	mv	t3, a0 				# t3 = length of stringified number
	
	# Ghi chuoi so vao file
	li	a7, 64 				# WriteFile syscall
	lw	a0, out_fd
	la	a1, buffer_number
	mv	a2, t3
	ecall
	
	# Ghi dau cach (neu khong phai so cuoi cung)
	addi	t0, s1, -1 			# last_index = count - 1
	bge	s0, t0, skip_space
	
	li	a7, 64
	lw	a0, out_fd
	la	a1, space
	li	a2, 1
	ecall
	
skip_space:
	# Tang bien dem i
	addi	s0, s0, 1
	j	write_loop

write_done:
	# Ghi newline cuoi file
	li	a7, 64
	lw	a0, out_fd
	la	a1, newline
	li	a2, 1
	ecall
	
	# Dong file output
	li	a7, 57 				# CloseFile syscall
	lw	a0, out_fd
	ecall
	
	# Khoi phuc thanh ghi
	lw	ra, 12(sp)
	lw	s0, 8(sp)
	lw	s1, 4(sp)
	lw	s2, 0(sp)
	addi	sp, sp, 16
	ret

msg_file_error_openor:
	# In thong bao loi ghi file
	li	a7, 4
	la	a0, msg_file_error_open
	ecall
	
	# Khoi phuc thanh ghi (neu can)
	lw	ra, 12(sp)
	lw	s0, 8(sp)
	lw	s1, 4(sp)
	lw	s2, 0(sp)
	addi	sp, sp, 16
	ret

write_positive_numbers:
	# (Doan code nay khong duoc goi va co the co loi logic ve tham so s0,s1,s2)
	# Tai so (gia su s0 la index, s2 la base address)
	slli	t0, s0, 2
	add	t1, s2, t0
	lw	t2, 0(t1)
	
	# Lay gia tri tuyet doi
	bgez	t2, skip_abs
	neg	t2, t2
skip_abs:
	
	# Chuyen so sang chuoi
	la	a0, buffer_number
	mv	a1, t2
	jal	number_to_string
	# mv    a2, a0 # a0 sau number_to_string la do dai, can luu vao a2
	
	# Ghi so (Loi: a0 dang la do dai, can la fd)
	li	a7, 64
	# lw a0, out_fd # Can load fd
	la	a1, buffer_number
	# mv a2, <length_from_number_to_string> # Can dung do dai chinh xac
	ecall
	
	# Ghi dau cach (gia su s1 la count)
	addi	t0, s1, -1
	bge	s0, t0, skip_space_positive 	# Doi ten nhan de tranh trung
	
	li	a7, 64
	# lw a0, out_fd # Can load fd
	la	a1, space
	li	a2, 1
	ecall

skip_space_positive: # Doi ten nhan
	# (Ket thuc ham thieu ret va khoi phuc stack)
	nop 					# Placeholder

check_negative:
	# (Day la mot phan cua number_to_string, khong phai ham doc lap)
	# Kiem tra so am (s1 la so, s0 la con tro buffer, s2 la do dai)
	bgez	s1, positive_conversion
	
	# Xu ly so am
	li	t0, 45 # '-'
	sb	t0, 0(s0)
	addi	s0, s0, 1
	addi	s2, s2, 1
	neg	s1, s1
	
positive_conversion:
	# (Tiep tuc logic cua number_to_string)
	mv	t0, s0
	mv	t1, s1

reverse_digits:
	# (Day la mot phan cua number_to_string)
	# chuan bi goi str_reverse (s0 la start_buffer, s2 la length)
	mv	a0, s0
	add	a1, s0, s2
	addi	a1, a1, -1 			# end_char_address
	
	# Them null terminator
	add	t0, s0, s2 			# address after last char
	sb	zero, 0(t0)
	
	jal	str_reverse
	
	# Tra ve do dai
	mv	a0, s2

exit:
	# Ket thuc chuong trinh
	li	a7, 10
	ecall