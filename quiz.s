#
#	Name:		Just, Kyle
#	Project:	#
#	Due:		00/00/2021
#	Course:		cs-2640-02-F21
#
#	Description:
#		This program will
	.data
n:	.word 10
	.text
proca:
	addi	$v0, $a0, 1
	jr	$ra
main:
	lw	$a0, n
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	proca
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	sw	$v0, n
	move 	$a0, $v0
	li	$v0, 1
	syscall

	jr	$ra
