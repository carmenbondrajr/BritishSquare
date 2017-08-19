# File: take_turn.asm
# Author: Carmen Bondra
# Section: 02 (TR)
# Description: Functions necessary for taking an actual turn
#	take_turn: prompts for users turn, passes it to validate_move
#	validate_move: checks the input for bounds and special codes, calls
#	external function check_cells which checks occupancy and neighbors

.globl board_arr
.globl take_turn
.globl check_cells
.globl x_char
.globl o_char
.globl new_line

.data
x_prompt:	.asciiz "Player X enter a move (-2 to quit, -1 to skip move): "
o_prompt:	.asciiz "Player O enter a move (-2 to quit, -1 to skip move): "
ill_loc_str:	.asciiz "Illegal location, try again\n"
center_str:		.ascii "Illegal move, can't place first"
				.asciiz " stone of game in middle square\n"
blank_board:	.ascii "0000000000000000000000000"
valid_str:		.asciiz "Validation complete.\n"

.text

# TAKE TURN
# arg: a0 - the indicator of the player 0 = X, 1 = O
take_turn:

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

	move $s0, $a0		# player indicator > s0
prompt_move:
	li $v0, 4
	beqz $s0, prompt_x
	la $a0, o_prompt
	syscall	
	la $a0, new_line
	syscall
	j prompt_move_done
prompt_x:
	la $a0, x_prompt
	syscall
	la $a0, new_line
	syscall	
prompt_move_done:
	li $v0, 5
	syscall
	move $a0, $s0	# player indicator into a0
	move $a1, $v0	# players move into a1
	j validate_move

take_turn_done:

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
# END TAKE TURN

# VALIDATE MOVE
# arg:	a0 - the user
# 		a1 - the move
validate_move:

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

	move $s0, $a0			# USER IN S0
	move $s1, $a1			# USER'S MOVE IN s1
	li $t0, -1				# -1 = skip
	beq $s1, $t0, validate_done	# user skips turn, we're done
	li $t0, -2				# -2 = quit
	beq $s1, $t0, turn_quit	# user quit
	li $t0, 0				# Check for less than 0
	blt $s1, $t0, ill_loc	# Illegal location branch < 0
	li $t0, 24				# Check for greater than 24
	bgt $s1, $t0, ill_loc	# Illegal location branch > 24
	la $s2, board_arr		# load the board into s1
	la $s3, blank_board		# load the blank_board into s2
# compare boards loop
	move $t0, $s2
	move $t1, $s3
	li $t2, 24
	li $t3, 0
board_compare:
	beq $t2, $t3, first_move
	lb $s6, 0($t0)
	lb $s7, 0($t1)
	slt $s5, $s7, $s6
	bne $s5, $zero, not_first_move
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	addi $t3, $t3, 1
	j board_compare
first_move:
	li $t0, 12	# center of the board
	beq $s1, $t0, first_ill	# illegal location branch
not_first_move:
						# Here is the bread and butter.
	move $a0, $s0		# move current user into a0
	move $a1, $s1		# move user input into a1
	jal check_cells		# CHECK CELLS AND NEIGHBORS
	beqz $v0, validate_done	# move was not approved
	j validated		# move approved! make it

first_ill:
	li $v0, 4
	la $a0, center_str
	syscall
	la $a0, new_line
	syscall
	li $v0, 0
	j validate_done
ill_loc:
	li $v0, 4
	la $a0, ill_loc_str
	syscall
	la $a0, new_line
	syscall
	li $v0, 0
	j validate_done
turn_quit:
	li $v0, -2			# user quit
	j validate_done

validated:		# move approved!
	# Make the move!

	la $t0, x_char
	lb $t4, 0($t0)		# load 'X' into t4
	la $t0, o_char
	lb $t5, 0($t0)		# load 'O' into t5

	add $s2, $s2, $s1	# find effective array addr

	beqz $s0, x_marks	# Jump if it's X's move
	la $t0, o_char		# otherwise O marks
	lb $t1, 0($t0)		# Load O into t1
	move $t9, $t3		# load 'b' (O blocks) into t9
	j mark_it
x_marks:					# X marks
	la $t0, x_char
	lb $t1, 0($t0)		# Load X into t1
	move $t9, $t2		# load 'a' (X blocks) into t9

mark_it:
	sb $t1, 0($s2)		# O marks the spot

	j take_turn_done

validate_done:
#	li $v0, 4
#	la $a0, valid_str
#	syscall

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

# END VALIDATE MOVE



