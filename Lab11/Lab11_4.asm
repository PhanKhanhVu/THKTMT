.eqv IN_ADDRESS_HEXA_KEYBOARD   0xFFFF0012  
.eqv TIMER_NOW                  0xFFFF0018 
.eqv TIMER_CMP                  0xFFFF0020 
.eqv MASK_CAUSE_TIMER           4 
.eqv MASK_CAUSE_KEYPAD          8      
 
.data 
    msg_keypad: .asciz "Someone has pressed a key!\n" 
    msg_timer: .asciz "Time inteval!\n" 
 
# ----------------------------------------------------------------- 
# MAIN Procedure 
# ----------------------------------------------------------------- 
.text 
main: 
    la      t0, handler 
    csrrs   zero, utvec, t0 
     
    li      t1, 0x100 
    csrrs   zero, uie, t1     # uie - ueie bit (bit 8) - external interrupt 
    csrrsi  zero, uie, 0x10   # uie - utie bit (bit 4) - timer interrupt 
     
    csrrsi  zero, ustatus, 1    # ustatus - enable uie - global interrupt 
 
    # --------------------------------------------------------- 
    # Enable interrupts you expect 
    # --------------------------------------------------------- 
    # Enable the interrupt of keypad of Digital Lab Sim 
    li      t1, IN_ADDRESS_HEXA_KEYBOARD 
    li      t2, 0x80  # bit 7 of = 1 to enable interrupt    
    sb      t2, 0(t1) 
 
    # Enable the timer interrupt 
    li      t1, TIMER_CMP 
    li      t2, 1000 
    sw      t2, 0(t1) 
 
    # --------------------------------------------------------- 
    # No-end loop, main program, to demo the effective of interrupt 
    # --------------------------------------------------------- 
loop:    
    nop 
    nop 
    nop 
    j   loop 
end_main: 
 
# -----------------------------------------------------------------
# Interrupt service routine 
# ----------------------------------------------------------------- 
handler: 
    # Saves the context 
    addi    sp, sp, -16 
    sw      a0, 0(sp) 
    sw      a1, 4(sp) 
    sw      a2, 8(sp) 
    sw      a7, 12(sp) 
     
    # Handles the interrupt 
    csrr    a1, ucause 
    li      a2, 0x7FFFFFFF 
    and     a1, a1, a2      # Clear interrupt bit to get the value 
     
    li      a2, MASK_CAUSE_TIMER 
    beq     a1, a2, timer_isr 
    li      a2, MASK_CAUSE_KEYPAD 
    beq     a1, a2, keypad_isr 
    j       end_process 
     
timer_isr: 
    li      a7, 4 
    la      a0, msg_timer 
    ecall 
     
    # Set cmp to time + 1000 
    li      a0, TIMER_NOW 
    lw      a1, 0(a0) 
    addi    a1, a1, 1000 
    li      a0, TIMER_CMP 
    sw      a1, 0(a0) 
     
    j       end_process 
 
keypad_isr: 
    li      a7, 4 
    la      a0, msg_keypad 
    ecall 
    j       end_process 
             
end_process: 
    # Restores the context 
    lw      a7, 12(sp) 
    lw      a2, 8(sp) 
    lw      a1, 4(sp) 
    lw      a0, 0(sp) 
    addi    sp, sp, 16 
    uret
