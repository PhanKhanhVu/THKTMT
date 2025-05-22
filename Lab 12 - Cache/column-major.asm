################################################################
#
#  Column-major order traversal of 16 x 16 array of words.
#  Pete Sanderson
#  31 March 2007
#
#  To easily observe the column-oriented order, run the Memory Reference
#  Visualization tool with its default settings over this program.
#  You may, at the same time or separately, run the Data Cache Simulator 
#  over this program to observe caching performance.  Compare the results
#  with those of the row-major order traversal algorithm.
#
#  The C/C++/Java-like equivalent of this MIPS program is:
#     int size = 16;
#     int[size][size] data;
#     int value = 0;
#     for (int col = 0; col < size; col++) {
#        for (int row = 0; row < size; row++) }
#           data[row][col] = value;
#           value++;
#        }
#     }
#
#  Note: Program is hard-wired for 16 x 16 matrix.  If you want to change this,
#        three statements need to be changed.
#        1. The array storage size declaration at "data:" needs to be changed from
#           256 (which is 16 * 16) to #columns * #rows.
#        2. The "li" to initialize $t0 needs to be changed to the new #rows.
#        3. The "li" to initialize $t1 needs to be changed to the new #columns.
#
         .data
data:    .word     0 : 256       # 16x16 matrix of words
         .text
         li       t0, 16        # $t0 = number of rows
         li       t1, 16        # $t1 = number of columns
         la		a0, data
         mv     s0, zero     # $s0 = row counter
         mv     s1, zero     # $s1 = column counter
         mv     t2, zero     # $t2 = the value to be stored
#  Each loop iteration will store incremented $t1 value into next element of matrix.
#  Offset is calculated at each iteration. offset = 4 * (row*#cols+col)
#  Note: no attempt is made to optimize runtime performance!
loop:    mul     s2, s0, t1       # $s2 = row * #cols  (two-instruction sequence)
         add      s2, s2, s1  # $s2 += col counter
         slli      s2, s2, 2    # $s2 *= 4 (shift left 2 bits) for byte offset
         add		s2, a0, s2
         sw       t2, 0(s2) # store the value in matrix element
         addi     t2, t2, 1    # increment value to be stored
#  Loop control: If we increment past bottom of column, reset row and increment column 
#                If we increment past the last column, we're finished.
         addi     s0, s0, 1    # increment row counter
         bne      s0, t0, loop # not at bottom of column so loop back
         mv     s0, zero     # reset row counter
         addi     s1, s1, 1    # increment column counter
         bne      s1, t1, loop # loop back if not at end of matrix (past the last column)
#  We're finished traversing the matrix.
         li       a7, 10        # system service 10 is exit
         ecall                 # we are outta here.
         
         
         
         
