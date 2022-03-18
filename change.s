#
#	Name:		Just, Kyle
#	Project:	#1
#	Due:		10/08/2021
#	Course:		cs-2640-02-F21
#
#	Description:
#		This program will take a amount of change between 1 and 99
#		and give the optimal amount of quarters, dimes, nickles and pennies
#		to make the amount of change.
	.data
name:			.asciiz "Change by K. Just\n\n"
firstPrompt:		.asciiz "Enter the change? "
quaterPrompt:		.asciiz "Quarter: "
dimePrompt:		.asciiz "Dime: "
nicklePrompt:		.asciiz "Nickle: "
pennyPrompt:		.asciiz "Penny: "
inputErrorPrompt:	.asciiz "The value must be between 1 and 99\nPlease try again\n"
	.text
nl:
	li $a0, 10	#ascii code for LF
	li $v0, 11	#syscall 11 prints the lower 8 bits of $a0 as an ascii character.
	syscall
	jr $ra
inputError:
	la	$a0, inputErrorPrompt	#load name address
	li	$v0, 4	# $v0 = 4
	syscall
	j prompt
main:
	#Print title
	la	$a0, name	#load name address
	li	$v0, 4		# $v0 = 4
	syscall
	#Print prompt
prompt:	la 	$a0, firstPrompt
	syscall
	#Collect user input for the amount of change needed
	li 	$v0, 5
	syscall
	jal nl
	blez	$v0, inputError		# if $v0 <= 0 then inputError
	bgt	$v0, 99, inputError	# if $v0 > 99 then inputError
	#Begin division for quarters
	li	$t0, 25		# $t0 = 25
	div	$v0, $t0	# $v0 / $t0
	mflo	$s0		# $s0 = floor($v0 / $t0)
	mfhi	$v0		# $v0 = $v0 mod $t0
	#Begin division for dimes
	li	$t0, 10		# $t0 = 10
	div	$v0, $t0	# $v0 / $t0
	mflo	$s1		# $s1 = floor($v0 / $t0)
	mfhi	$v0		# $v0 = $v0 mod $t0
	#Begin division for nickles
	li	$t0, 5		# $t0 = 10
	div	$v0, $t0	# $v0 / $t0
	mflo	$s2		# $s2 = floor($v0 / $t0)
	mfhi	$v0		# $v0 = $v0 mod $t0
	#Pennies is leftover
	move 	$s3, $v0	# $v0 = $s3
	#Conditionals to decide what to print
	beqz	$s0, skipQuarter	# if $s0 == zero then skipQuarter
	#Printing for quarters
	la	$a0, quaterPrompt
	li	$v0, 4		# $v0 = 4
	syscall
	move 	$a0, $s0	# $a0 = $s0
	li	$v0, 1		# $v0 = 1
	syscall
	jal nl
skipQuarter:
	beqz	$s1, skipDime	# if $s1 == zero then skipDime
	#Printing for dimes
	la	$a0, dimePrompt
	li	$v0, 4		# $v0 = 4
	syscall
	move 	$a0, $s1	# $a0 = $s1
	li	$v0, 1		# $v0 = 1
	syscall
	jal nl
skipDime:
	beqz	$s2, skipNickle	# if $s2 == zero then skipNickle
	#Printing for nickles
	la	$a0, nicklePrompt
	li	$v0, 4		# $v0 = 4
	syscall
	move 	$a0, $s2	# $a0 = $s2
	li	$v0, 1		# $v0 = 1
	syscall
	jal nl
skipNickle:
	beqz	$s3, skipPenny
	#Printing for pennies
	la	$a0, pennyPrompt
	li	$v0, 4		# $v0 = 4
	syscall
	move 	$a0, $s3	# $a0 = $s3
	li	$v0, 1		# $v0 = 1
	syscall
	jal nl
skipPenny:
	li	$v0, 10		# $v0 = 10
	syscall #EXIT PROGARM
