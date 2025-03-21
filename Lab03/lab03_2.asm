.text
    li s0, 0x20235658  	# Khởi tạo giá trị cho s0 = 0x20235658

# 1. Trích xuất MSB (Most Significant Byte)
    srli t0, s0, 24      # Dịch phải 24 bit để lấy byte cao nhất (MSB)

# 2. Xóa LSB (Least Significant Byte)
    li t1, 0xFFFFFF00    # Khởi tạo giá trị để xóa LSB
    and s0, s0, t1       # Xóa LSB của s0

# 3. Thiết lập LSB thành 0xFF (tất cả bit của byte thấp nhất là 1)
    ori s0, s0, 0xFF     # OR với 0xFF để thiết lập byte thấp nhất

# 4. Xóa thanh ghi s0 bằng cách sử dụng các lệnh logic
          xor s0, s0, s0       # Xóa toàn bộ nội dung của s0 (s0 = 0)

END: