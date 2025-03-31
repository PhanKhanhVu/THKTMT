# Laboratory Exercise 7, Home Assignment 3 
.text 
main:
	li      s0, 18         # Gán giá trị 21 vào thanh ghi s0  
	li      s1, 36          # Gán giá trị 5 vào thanh ghi s1  
push:  
	addi    sp, sp, -8     # Điều chỉnh con trỏ ngăn xếp (giảm 8 byte)  
	sw      s0, 4(sp)      # Đẩy giá trị s0 vào ngăn xếp  
	sw      s1, 0(sp)      # Đẩy giá trị s1 vào ngăn xếp  
work:  
	nop                    # Không làm gì (lệnh chờ)  
	nop  
	nop   
pop:   
	lw      s0, 0(sp)      # Lấy giá trị từ ngăn xếp về s0  
	sw      zero, 0(sp)    # Xóa dữ liệu khỏi ngăn xếp (gán 0)  
	addi    sp, sp, 4      # Điều chỉnh con trỏ ngăn xếp (tăng 4 byte)  
	lw      s1, 0(sp)      # Lấy giá trị từ ngăn xếp về s1  
	sw      zero, 0(sp)    # Xóa dữ liệu khỏi ngăn xếp (gán 0)  
	addi    sp, sp, 4      # Điều chỉnh con trỏ ngăn xếp (tăng 4 byte)  
end: