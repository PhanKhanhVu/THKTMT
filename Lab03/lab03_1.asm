# Laboratory Exercise 4, Home Assignment 1 
.text 
li s1 0x90000000   # Khởi tạo giá trị cho s1
li s2 0x99999999   # Khởi tạo giá trị cho s2
# Thuật toán xác định tràn số 
li    t0, 0             # Mặc định không có tràn số 
add   s3, s1, s2        # s3 = s1 + s2 
xor   t1, s1, s2        # Kiểm tra s1 với s2 có cùng dấu 
blt   t1, zero, EXIT    # Nếu t1 là số âm, s1 và s2 khác dấu 
blt   s1, zero, NEGATIVE   # Kiểm tra s1 và s2 là số âm hay không âm 
bge   s3, s1, EXIT         # s1 không âm, kiểm tra s3 nhỏ hơn s1 không 
# Nếu s3 >= s1, không tràn số 
j     OVERFLOW  
NEGATIVE:
bge   s1, s3, EXIT    # s1 âm, kiểm tra s3 có lớn hơn s1 không 
# Nếu s1 >= s3, không tràn số 
OVERFLOW: 
li    t0, 1          # The result is overflow  
EXIT:
