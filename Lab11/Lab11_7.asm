.eqv    IN_ADDRESS_HEXA_KEYBOARD   0xFFFF0012  
.eqv 	OUT_ADDRESS_HEXA_KEYBOARD  0xFFFF0014
.eqv    TIMER_NOW                  0xFFFF0018 
.eqv    TIMER_CMP                  0xFFFF0020 
.eqv    SEVENSEG_LEFT              0xFFFF0011
.eqv    SEVENSEG_RIGHT             0xFFFF0010
.eqv    MASK_CAUSE_TIMER           0x00000004  
.eqv    MASK_CAUSE_KEYPAD          0x00000008  
.eqv 	newline 		   0xa
.data 
        count:          .word 0          # Giá trị đếm hiện tại (0-99)
        direction:      .word 1          # 1 = tăng, -1 = giảm
        period:         .word 1000       # Chu kỳ mặc định (1000ms)
        digit_patterns: .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F  # Mẫu các số 0-9

.text 
main: 
        # Thiết lập trình xử lý ngắt
        la      t0, handler 
        csrrs   zero, utvec, t0 
         
        # Kích hoạt ngắt (ngoại vi và timer)
        li      t1, 0x100 
        csrrs   zero, uie, t1     # Kích hoạt ngắt ngoại vi
        csrrsi  zero, uie, 0x10   # Kích hoạt ngắt timer
         
        csrrsi  zero, ustatus, 1  # Kích hoạt ngắt toàn cục
    
        # Kích hoạt ngắt bàn phím
        li      t1, IN_ADDRESS_HEXA_KEYBOARD 
        li      t2, 0x80          # Kích hoạt ngắt    
        sb      t2, 0(t1) 
    
        # Thiết lập giá trị so sánh timer ban đầu
        li      t1, TIMER_NOW
        lw      t2, 0(t1)
        lw      t3, period
        add     t2, t2, t3
        li      t1, TIMER_CMP
        sw      t2, 0(t1)
        
        # Hiển thị ban đầu
        jal     update_display
    
        # Vòng lặp chính - chờ ngắt
loop:    
        nop 
        j       loop 
end_main: 
    
# -----------------------------------------------------------------
# Trình xử lý ngắt 
# ----------------------------------------------------------------- 
handler: 
        # Lưu ngữ cảnh
        addi    sp, sp, -16 
        sw      a0, 0(sp) 
        sw      a1, 4(sp) 
        sw      a2, 8(sp) 
        sw      a7, 12(sp) 
        
        # Kiểm tra nguyên nhân ngắt
        csrr    a1, ucause 
        li      a2, 0x7FFFFFFF 
        and     a1, a1, a2      # Xóa bit ngắt
        
        li      a2, MASK_CAUSE_TIMER 
        beq     a1, a2, timer_isr 
        li      a2, MASK_CAUSE_KEYPAD 
        beq     a1, a2, keypad_isr 
        j       end_process 
        
timer_isr: 
        # Cập nhật bộ đếm theo hướng
        lw      a0, count
        lw      a1, direction
        add     a0, a0, a1
        
        # Xử lý vòng lặp (99->00 hoặc 00->99)
        li      a2, 100
        bge     a0, a2, wrap_around_high
        bltz    a0, wrap_around_low
        j       store_count
        
wrap_around_high:
        li      a0, 0
        j       store_count
        
wrap_around_low:
        li      a0, 99
        
store_count:
        sw      a0, count, t0   # Lưu giá trị mới vào count
        
        # Cập nhật hiển thị
        jal     update_display   # Gọi hàm cập nhật hiển thị
        
        # Đặt lại timer cho khoảng tiếp theo
        li      a0, TIMER_NOW
        lw      a1, 0(a0)
        lw      a2, period
        add     a1, a1, a2
        li      a0, TIMER_CMP
        sw      a1, 0(a0)
        j       end_process 

keypad_isr:
        # Quét bàn phím từng hàng để kiểm tra phím nào được nhấn
        li      t1, IN_ADDRESS_HEXA_KEYBOARD
        li      t2, OUT_ADDRESS_HEXA_KEYBOARD
        li      t3, 0x01                 # Bắt đầu từ hàng 1 (00000001)
        li      a1, 0                    # a1 sẽ lưu mã phím nếu có

row_loop:
        sb      t3, 0(t1)                # Gửi tín hiệu chọn hàng bàn phím
        lb      a0, 0(t2)                # Đọc mã phím (scan code)
        beq     a0, zero, next_row       # Nếu không có phím, chuyển hàng tiếp theo
        add     a1, a0, zero             # Lưu mã phím vào a1
        j       check_key                # Nhảy đến xử lý mã phím

next_row:
        slli    t3, t3, 1                # Chuyển sang hàng tiếp theo (dịch trái 1 bit)
        li      t4, 0x10                 # Giới hạn là hàng 4 (10000)
        blt     t3, t4, row_loop         # Nếu chưa hết hàng, lặp lại

        # Không phát hiện phím nào, bật lại ngắt keypad và kết thúc
        jal     enable_keypad_interrupt
        j       end_process

check_key:
        # Kiểm tra mã phím để xác định chức năng
        li      a2, 0x11                 # Phím 0
        beq     a1, a2, set_increment
        li      a2, 0x21                 # Phím 1
        beq     a1, a2, set_decrement
        li      a2, 0x12                 # Phím 4
        beq     a1, a2, decrease_period
        li      a2, 0x22                 # Phím 5
        beq     a1, a2, increase_period

        # Phím không hợp lệ, vẫn bật lại ngắt keypad
        jal     enable_keypad_interrupt
        j       end_process

set_increment:
        li      a0, 1
        la      t4, direction
        sw      a0, 0(t4)                # Gán hướng tăng
        jal     enable_keypad_interrupt
        j       end_process

set_decrement:
        li      a0, -1
        la      t4, direction
        sw      a0, 0(t4)                # Gán hướng giảm
        jal     enable_keypad_interrupt
        j       end_process

decrease_period:
        la      t4, period
        lw      t5, 0(t4)
        li      t6, 500                  # Giảm từng bước 100
        sub     t5, t5, t6
        li      a3, 500                  # Giới hạn tối thiểu
        bge     t5, a3, save_decrease
        li      t5, 500                  # Nếu nhỏ hơn 100 thì giữ ở 100
save_decrease:
        sw      t5, 0(t4)
        jal     enable_keypad_interrupt
        j       end_process

increase_period:
        la      t4, period
        lw      t5, 0(t4)
        li      t6, 100                  # Tăng từng bước 100
        add     t5, t5, t6
        li      a3, 2000                 # Giới hạn tối đa
        ble     t5, a3, save_increase
        li      t5, 2000                 # Nếu lớn hơn 2000 thì giữ ở 2000
save_increase:
        sw      t5, 0(t4)
        jal     enable_keypad_interrupt
        j       end_process


             
end_process: 
        # Khôi phục ngữ cảnh
        lw      a7, 12(sp) 
        lw      a2, 8(sp) 
        lw      a1, 4(sp) 
        lw      a0, 0(sp) 
        addi    sp, sp, 16 
        uret
# --------------------------------------------------------
# Bật lại ngắt bàn phím sau mỗi lần xử lý để nhận phím mới
# --------------------------------------------------------
enable_keypad_interrupt:
        li      t1, IN_ADDRESS_HEXA_KEYBOARD
        li      t2, 0x80                 # Bit kích hoạt ngắt
        sb      t2, 0(t1)
        ret
# -----------------------------------------------------------------
# Cập nhật hiển thị LED 7 đoạn
# -----------------------------------------------------------------
update_display:
        addi    sp, sp, -12
        sw      ra, 0(sp)
        sw      a0, 4(sp)
        sw      a1, 8(sp)
        
        lw      a0, count
        
        # Lấy chữ số hàng đơn vị
        li      a1, 10
        rem     a1, a0, a1      # a1 = count % 10
        la      t0, digit_patterns
        add     t0, t0, a1
        lb      a1, 0(t0)       # Lấy mẫu cho chữ số phải
        li      t0, SEVENSEG_RIGHT
        sb      a1, 0(t0)       # Hiển thị chữ số phải
        
        # Lấy chữ số hàng chục
        li      a1, 10
        div     a1, a0, a1      # a1 = count / 10
        la      t0, digit_patterns
        add     t0, t0, a1
        lb      a1, 0(t0)       # Lấy mẫu cho chữ số trái
        li      t0, SEVENSEG_LEFT
        sb      a1, 0(t0)       # Hiển thị chữ số trái
        
        lw      a1, 8(sp)
        lw      a0, 4(sp)
        lw      ra, 0(sp)
        addi    sp, sp, 12
        jr      ra
