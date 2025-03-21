# Laboratory Exercise 4, Home Assignment 4
.text
# TODO: Thiết lập giá trị cho s1 và s2
li s1 0x80000000 
li s2 0x88888888
# Thuật toán xác định tràn số
li t0, 0 # Mặc định không có tràn số
add s3, s1, s2 # s3 = s1 + s2
xor t1, s1, s2 # Kiểm tra s1 với s2 có cùng dấu
blt t1, zero, EXIT # Nếu t1 là số âm, s1 và s2 khác dấu
xor t2 s1, s3 # Kiểm tra s1 với s3 có cùng dấu không
blt t2, zero, OVERFLOW # khác dấu thì tràn số 
j EXIT
OVERFLOW:
li t0, 1 # The result is overflow
EXIT:
