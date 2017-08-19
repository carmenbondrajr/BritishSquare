# File: draw_board.asm
# Author: Carmen Bondra
# Section: 02 (TR)
# Description: Draws the Board
# 	draw_board: the main board drawing function
# 	draw_row: called by draw_board, it will format a given 5 chars into the row


.data 
brd_str1 :	.asciiz "***********************\n"
brd_str2 :	.asciiz "*+---+---+---+---+---+*\n"
brd_str3 : 	.asciiz "*"
brd_str4 :	.asciiz "|"
brd_str5 :	.asciiz " "
new_line :	.asciiz "\n"
temp_row :	.asciiz "00000"
x_char :	.ascii "X"
o_char :	.ascii "O"
board_arr :	.ascii "0000000000000000000000000"
#board_arr : .ascii "X0X00X00O0X0X0X0O0O0O0X0O"
.text

.globl draw_board
# DRAW BOARD 
# Loads the temporary row string and calls draw_row
draw_board:

	addi 	$sp, $sp, -24
	sw 	$ra, 20($sp)
	sw 	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw 	$s0, 0($sp)

	la $s0, board_arr	# load the array addr into s2
	la $s1, temp_row	# load the temp arr addr into s3
	addi $s2, $s1, 5	# end of temp_row checker
	addi $s3, $s0, 25	# end of array checker (addr + 25)
	li $v0, 4
	#la $a0, new_line	# Print blank line
	#syscall
	la $a0, brd_str1	# Print starting row
	syscall		
	la $a0, brd_str2	# Print second row
	syscall				

	li $t0, 0
	li $t1, 0	
	li $t2, 0		# Row counter
	li $s4, 0
draw_loop:
	beq	$s0, $s3, draw_board_done	# if the index eq 25, we're done
	addi $s4, $s4, 1		# our index counter
	lb $t1, 0($s0)			# load current arr byte into a0
	sb $t1, 0($s1)			# store that byte into our temp str
	addi $s0, $s0, 1		# increment arr addr
	addi $s1, $s1, 1		# increment temp arr addr
	bne $s1, $s2, dont_draw	# don't draw yet, we don't have 5
	move $a1, $s4			# move t0 to a1
	jal draw_row
	addi $s1, $s1, -5
dont_draw:

	j draw_loop				# loop

draw_board_done:
	li $v0, 4
	la $a0, brd_str1		# print the final row
	syscall	
	la $a0, new_line
	syscall
	lw 	$ra, 20($sp)
	lw 	$s4, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, 24
	jr	$ra	

# END DRAW BOARD	
# ________________

# DRAW ROW
# Manipulates the temp_row array to draw the row twice
# with the required formatting
draw_row:
	
	addi $sp, $sp, -36
	sw 	$ra, 32($sp)
	sw	$s7, 28($sp)
	sw	$s6, 24($sp)
	sw	$s5, 20($sp)
	sw 	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw 	$s0, 0($sp)

	move $s6, $a1		# grab that index number and store in s6
	la $s7, temp_row	# our static root address
	la $s0, temp_row
	li $v0, 4
	la $a0, brd_str3	# PRINT "*"
	syscall
	la $a0, brd_str4	# PRINT "|"
	syscall

	addi $t1, $s0, 5	# end of temp_row checker
	la $t0, x_char		# load x_char into t0
	lb $t2, 0($t0)		# load first byte of x_char into t2
	la $t0, o_char		# load o_char into t0
	lb $t3, 0($t0)		# load first byte of o_char into t3

draw_five_first:
	lb $s1, 0($s0)		# load s0 byte into s1
	slt $t4, $s1, $t2	# compare our byte s1 and the X in t2
	beqz $t4, print_char1 # branch if the char is an X
	slt	$t4, $s1, $t3	# compare our byte s1 and the O in t3
	beqz $t4, print_char1 # branch if the char is an O
	# Otherwise, print the index.
	la $a0, brd_str5
	syscall
	syscall
	syscall
	j printed1
print_char1:
	li $v0, 11
	move $a0, $s1
	syscall
	syscall
	syscall
printed1:
	li $v0, 4			# Load string syscall
	la $a0, brd_str4	# PRINT "|"
	syscall				#
	addi $s0, $s0, 1	# increment index
	bne $s0, $t1, draw_five_first
end_of_row:
	li $v0, 4			# load print string syscall
	la $a0, brd_str3	# PRINT "*"
	syscall

	li $v0, 4
	la $a0, new_line
	syscall
	la $a0, brd_str3	# PRINT "*"
	syscall
	la $a0, brd_str4	# PRINT "|"
	syscall
	la $s0, temp_row

draw_five_second:
	lb $s1, 0($s0)		# load s0 byte into s1
	slt $t4, $s1, $t2	# compare our byte s1 and the X in t2
	beqz $t4, print_char2 # branch if the char is an X
	slt	$t4, $s1, $t3	# compare our byte s1 and the O in t3
	beqz $t4, print_char2 # branch if the char is an O
	# Otherwise, print the index.
	sub $t8, $s0, $s7		# t8 = s0 - s7
	add $t9, $s6, $t8		# t9 = s6 + t8
	addi $t9, $t9, -5
	li $v0, 1
	move $a0, $t9	
	syscall

	li $v0, 4
	la $a0, brd_str5		# print a blank space (valid for all ints)
	syscall
	li $t8, 10				# load 10 into t8
	bge $t9, $t8, printed2	# don't print another blank space if >= 10
	syscall					# print that extra space for ints < 10
	j printed2
print_char2:
	li $v0, 11
	move $a0, $s1		# print our character normally (X or O)
	syscall
	syscall
	syscall
printed2:
	li $v0, 4			# Load string syscall
	la $a0, brd_str4	# PRINT "|"
	syscall				#
	addi $s0, $s0, 1	# increment index
	bne $s0, $t1, draw_five_second
end_of_row1:

	li $v0, 4			# load print string syscall
	la $a0, brd_str3	# PRINT "*"
	syscall

	la $a0, new_line
	syscall

draw_row_done:

	la $a0, brd_str2	# print our line breaker
	syscall

	lw 	$ra, 32($sp)
	lw	$s7, 28($sp)
	lw	$s6, 24($sp)
	lw	$s5, 20($sp)
	lw 	$s4, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, 36
	jr	$ra	

# END DRAW ROW
