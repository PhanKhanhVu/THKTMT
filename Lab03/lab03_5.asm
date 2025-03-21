.text
li t1 , 6
li t2, 16 # ví dụ 16 sẽ bằng 10000 là có 4bit 0  
addi s0,s0,1 # gán giá trị s0 = 1 để dễ so sánh
loop:
beq t2,s0,break # so sánh giá trị t2 sau khi dịch bit
srli t2,t2,1  # dịch bit sang phải 1 bit lần lượt 
slli t1,t1,1	# dịch bit sang trái 1 bit lần lượt
j loop
break:
