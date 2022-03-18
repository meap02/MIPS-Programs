#
#	Name:		Just, Kyle
#	Project:	#
#	Due:		00/00/2021
#	Course:		cs-2640-02-F21
#
#	Description:
#		This program will
	.data
name:	.asciiz "Lines by K. Just\n\n"
prompt:	.asciiz "Input a number to find the sum: "
	.text
############################################################
fact:		#Will get a factorial of a number
		#input:		$a0
		#output:	$v0
############################################################
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	bnez	$a0, else
	li	$v0, 1
	b	return
else:	sub	$a0, $a0, 1
	jal	fact
	lw	$a0, 4($sp)
	mul	$v0, $a0, $v0
return:
	lw	$ra, 0($sp)
	addi	$sp, $sp, 8
	jr	$ra
############################################################

############################################################
sum1n:		#Will get a sum of a number
		#input:		$a0
		#output:	$v0
############################################################
	beqz	$a0, zero
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	addi	$a0, $a0, -1
	jal	sum1n
	lw	$ra, 0($sp)
	lw	$a0, 4($sp)
	addi	$sp, $sp, 8
	add	$v0, $a0, $v0
	jr	$ra
zero:
	move	$v0, $a0
	jr	$ra

############################################################

main:
	la	$a0, name
	li	$v0, 4
	syscall
	la	$a0, prompt
	syscall
	li	$v0, 5
	syscall
	move 	$a0, $v0
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	sum1n
	lw	$ra, 0($sp)
	move 	$a0, $v0
	li	$v0, 1
	syscall
	li	$a0, '\n'
	li	$v0, 11
	syscall
#	jr	$ra
	li	$v0, 10		# $v0 = 10
	syscall #EXIT PROGARM
