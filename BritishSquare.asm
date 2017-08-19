# File: BritishSquare.asm
# Author: Carmen Bondra
# Section: 02 (TR)
# Description: The main function of the British Square game.
# 	main: our main! welcomes the user and runs the game loop
# 	game_over: handles the end of the game stats and printing

.globl main
.globl new_line
.globl draw_board
.globl take_turn
.globl find_poss_moves
.globl brd_str5
.globl new_line
.globl x_char
.globl o_char
.globl board_arr

.data
welcome_msg :	.ascii "****************************\n"
				.ascii "**     British Square     **\n"
				.asciiz "****************************\n"
x_skip:			.asciiz "Player X has no legal moves, turn skipped.\n"
o_skip:			.asciiz "Player O has no legal moves, turn skipped.\n"
occupied_str:	.asciiz "Illegal move, square is occupied\n"
blocked_str:	.asciiz "Illegal move, square is blocked\n"
x_quit:			.asciiz "Player X quit the game.\n"
o_quit:			.asciiz "Player O quit the game.\n"
game_totals:	.asciiz "Game Totals\n"
x_total:		.asciiz "X's total="
o_total:		.asciiz "O's total="
x_win_str:		.ascii "************************\n"
				.ascii "**   Player X wins!   **\n"
				.asciiz "************************\n"
o_win_str:		.ascii "************************\n"
				.ascii "**   Player O wins!   **\n"
				.asciiz "************************\n"
tie_game_str:	.ascii "************************\n"
				.ascii "**   Game is a tie    **\n"
				.asciiz "************************\n"
.text


main:

	addi $sp, $sp, -16  
	sw 	$ra, 12($sp)	
	sw 	$s2, 8($sp)	
	sw 	$s1, 4($sp)
	sw 	$s0, 0($sp)
	
	li $s0, 0	# PLAYER BOOL, 0 = X, 1 = O
	li $s1, 0	# last player skipped bool
	li $s2, 0	# one player out bool

# Welcome
	li $v0, 4
	la $a0, new_line
	syscall
	la $a0, welcome_msg
	syscall
	la $a0, new_line
	syscall
	jal draw_board

# Game loop
main_loop:
	move $a0, $s0			# player indicator > a0 (for poss moves)
	jal find_poss_moves		# find if this player has a poss move
	beqz $v0, no_poss_skip	# if not, skip him and reloop
turn_loop:
	move $a0, $s0			# player indicator > a0 (for take turn)
	jal take_turn			# take the turn!
	beqz $v0, print_err		# make them go again, invalid move
	li $s1, 0
	li $t0, -2				# load -2 into t0 (for quitting)
	beq $v0, $t0, quit_game	# if take_turn returns -2, we quit

	jal draw_board
	j toggle_players

#	Check if game is over	
	li $v0, 1
	beq $v0, $zero, game_over

j main_loop
# End of the game loop

print_err:
	li $t1, 1
	li $t2,	2
	beq $v1, $t1, print_block
	beq $v1, $t2, print_occup
	j turn_loop
print_block:
	li $v0, 4
	la $a0, blocked_str
	syscall
	la $a0, new_line
	syscall
	j turn_loop
print_occup:
	li $v0, 4
	la $a0, occupied_str
	syscall
	la $a0, new_line
	syscall
	j turn_loop


# NO POSS SKIP
no_poss_skip:
	bnez $s1, second_skip	# if last player has also been skipped, quit the game
	li $s1, 1
	j skip_player
second_skip:
	j game_over

# SKIP PLAYER
skip_player:
	li $v0, 4	
	bnez $s2, toggle_players	# only print the skip string the first time
	beqz $s0, skip_x	# print x_skip if it's x's turn
	la $a0, o_skip		# otherwise print o_skip
	syscall
	la $a0, new_line
	syscall
	li $s2, 1			# flag the skip string as printed
	j toggle_players
skip_x:
	la $a0, x_skip
	syscall
	la $a0, new_line
	syscall
	li $s2, 1			# flag the skip string as printed
	j toggle_players
#
# TOGGLE PLAYERS
toggle_players:
	beqz $s0, O_turn
	li $s0, 0
	j main_loop
O_turn:
	li $s0, 1
	j main_loop
#
 
# QUIT GAME
quit_game:
	li $v1, -99
	move $a0, $s0
	j game_over

# GAME OVER
game_over:
	
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
	
	move $s7, $a0	# player indicator into s7
	li $s0, 0	# X counter in s0
	li $s1, 0	# O counter in s1
	la $t0, x_char
	lb $s2, 0($t0)	# 'X' in s2
	la $t0, o_char
	lb $s3, 0($t0)	# 'O' in s3
	la $s4, board_arr	# board_arr in s4
	
	li $t1, 0
	li $t2, 25
score_loop:
	beq $t1, $t2, score_done
	lb $s5, 0($s4)
	addi $t1, $t1, 1	# increment loop counter
	addi $s4, $s4, 1	# increment arr addr
	beq $s5, $s3, o_inc
	beq $s5, $s2, x_inc
	j score_loop
x_inc:
	addi $s0, $s0, 1	# increment X counter
	j score_loop
o_inc:
	addi $s1, $s1, 1	# increment O counter
	j score_loop

score_done:
	li $v0, 4
	la $a0, game_totals	# Game Totals
	syscall

	la $a0, x_total		# X's total=
	syscall

	li $v0, 1
	move $a0, $s0		# num of X
	syscall

	li $v0, 4
	la $a0, brd_str5	# ' '
	syscall

	la $a0, o_total		# O's total=
	syscall

	li $v0, 1
	move $a0, $s1		# num of O
	syscall

	li $v0, 4
	la $a0, new_line	# \n
	syscall

	li $t0, -99
	beq $v1, $t0, print_quit # Don't display winner if user quit

	beq $s0, $s1, tie_game
	slt $t0, $s0, $s1	# 1 if O wins, 0 if X wins
	beqz $t0, x_wins
	li $v0, 4
	la $a0, o_win_str
	syscall
	j game_over_done
x_wins:
	li $v0, 4
	la $a0, x_win_str
	syscall
	j game_over_done
tie_game:
	li $v0, 4
	la $a0, tie_game_str
	syscall
	j game_over_done

print_quit:
	beqz $s7, quit_x
	la $a0, o_quit
	syscall
	j game_over_done
quit_x:
	la $a0, x_quit
	syscall

game_over_done:

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

main_done:
	lw 	$ra, 8($sp)
	lw 	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi $sp, $sp, 12   

	li $v0, 10		# Exit the game.
	syscall		
	

