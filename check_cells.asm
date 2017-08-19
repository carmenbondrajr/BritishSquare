# File: check_cells.asm
# Author: Carmen Bondra
# Section: 02 (TR)
# Description: The array parser for move legality
# 	check_cells: checks user input cell for occupancy
# 	check_neighbors: checks the 4 neighbors, handles blocks/occupied
# 	find_poss_moves: scans the array for possible moves given the curr player

.globl board_arr
.globl check_cells
.globl find_poss_moves
.globl x_char
.globl o_char

.data
zero_str:		.asciiz "0"
poss_found:		.asciiz "Possible move found.\n"
no_poss_found:	.asciiz "No possible move found.\n"
occ_str:		.asciiz "occupied cell\n"
check_str:		.asciiz " - checking neighbors\n"
.text


# check_cells
# args: a0 - current user, 0 or 1
# 		a1 - user's input (cell #)
check_cells:

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

	move $s0, $a0		# Current user into s0
	move $s1, $a1		# User's input into s1
	la $s2, board_arr	# Load board_arr into s2
	add $t0, $s2, $s1	# s3 = board + cell (addr of user cell)
	lb $s3, 0($t0)		# load the byte at this index


# CHECK USER CELL
	la $t0, x_char			
	lb $s4, 0($t0)
	beq $s3, $s4, occupied	# This square is occupied by an X
	la $t0, o_char
	lb $s5, 0($t0)
	beq $s3, $s5, occupied	# This square is occupied by an O

	move $a0, $s0		# load check_neighbors args
	move $a1, $s1

	jal check_neighbors

check_cells_done:

	lw 	$ra, 32($sp)
	lw	$s7, 28($sp)
	lw	$s6, 24($sp)
	lw	$s5, 20($sp)
	lw 	$s4, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi $sp, $sp, 36
	jr	$ra	

	# Reference
	# s0 - curr user
	# s1 - input index
	# s2 - board_arr
	# s3 - enemy indicator (X or O)

# CHECK NEIGHBORS
# args -	a0 - current user
# 			a1 - the cell	
# return -	v0 - 0 for blocked/occupied, 1 for approved
check_neighbors:
	
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

	move $s0, $a0
	move $s1, $a1
	la $s2, board_arr
	add $s6, $s2, $s1		# effective arr addr in s6

	la $t0, zero_str
	lb $s7, 0($t0)			# s7 = '0'

	beqz $s0, x_turn	# start checking, given x's turn
	j o_turn			# start checking, given o's turn

x_turn:
	move $s3, $s5	# enemy indicator = O
	j check_below
o_turn:
	move $s3, $s4	# enemy indicator = X

check_below:

	li $t0, 19
	bgt $s1, $t0, check_above	# we're on the bottom row, don't do this check
	addi $t1, $s6, 5		# hop down a row
	lb $t6, 0($t1)			# check this bit for occupancy
	beq $t6, $s3, blocked

check_above:

	li $t0, 5
	blt $s1, $t0, check_left	# we're on the top row, don't do this check
	addi $t1, $s6, -5		# hop up a row
	lb $t6, 0($t1)			# check this bit for occupancy
	beq $t6, $s3, blocked

check_left:

	li $t0, 5				# for modulus
	div $s1, $t0			# current cell / 5
	mfhi $t8				# remainder -> t8

	beqz $t8, check_right	# this cell is a left-most cell (cell % 5 = 0)
	addi $t1, $s6, -1		# hop left a cell
	lb $t6, 0($t1)			# check this bit for occupancy
	beq $t6, $s3, blocked

check_right:

	li $t7, 4				# column index = 4
	beq $t8, $t7, approved	# this cell is a right-most cell (cell % 5 = 4)
	addi $t1, $s6, 1		# hop right a cell
	lb $t6, 0($t1)			# check this bit for occupancy
	beq $t6, $s3, blocked

	j approved

blocked:
	#li $v0, 4
	#la $a0, blocked_str
	#syscall
	li $v0, 0	# move declined
	li $v1, 1	# blocked flag
	j check_neighbors_done
 
occupied:
	#li $v0, 4
	#la $a0, occupied_str
	#syscall
	li $v0, 0	# move declined
	li $v1, 2	# occupied flag
	j check_neighbors_done

approved:
	li $v0, 1
	j check_neighbors_done

check_neighbors_done:
	
	lw 	$ra, 32($sp)
	lw	$s7, 28($sp)
	lw	$s6, 24($sp)
	lw	$s5, 20($sp)
	lw 	$s4, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi $sp, $sp, 36
	jr	$ra	

# END CHECK NEIGHBORS

# find_poss_moves
# arg:a0 - the player
# return: v0 - 1 if there is a possible move, 0 if not
find_poss_moves:
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

	move $s0, $a0		# player indicator in s0
	li $s1, 0			# index counter in s1
	li $s7, 24			# end of array counter in s7
	la $s2, board_arr	# board array in s3

	la $t0, x_char
	lb $s4, 0($t0)		# s4 = 'X'
	la $t0, o_char
	lb $s5, 0($t0)		# s5 = 'O'
	li $s6, 0			# will be our effective address
fpm_loop:
	add $s6, $s2, $s1	# compute effective address (arr + index)	
	lb $t1, 0($s6)		# load the effective byte
	beq $t1, $s4, occ_cell	# This square is occupied by an X
	beq $t1, $s5, occ_cell	# This square is occupied by an O
	move $a0, $s0		# parameter #2 for check_neighbors
	move $a1, $s1		# parameter #1 for check_neighbors
	jal check_neighbors	# check availability of this cell
	move $t2, $v0
	bnez $t2, is_poss	# if v0 = 1, we've found a possible move
increment:
	addi $s1, 1
	beq $s1, $s7, no_poss	# if the index = 24, we're done
	j fpm_loop			# loop again

occ_cell:
	j increment

no_poss:
	li $v0, 0
	j fpm_done

is_poss:
	li $v0, 1
	j fpm_done

fpm_done:

	lw 	$ra, 32($sp)
	lw	$s7, 28($sp)
	lw	$s6, 24($sp)
	lw	$s5, 20($sp)
	lw 	$s4, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi $sp, $sp, 36
	jr	$ra	

