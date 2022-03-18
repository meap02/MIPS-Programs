#
#	Name:		Just, Kyle
#	Project:	#
#	Due:		00/00/2021
#	Course:		cs-2640-02-F21
#
#	Description:
#		This program will
	.data
array:	.word	1, 2, 3, 4, 5
k:	.word	2
	.text
main:
	la	$t0, array
	lw	$t1, 0($t0)
	lw	$t2, 16($t0)
	add	$t1, $t1, $t2
	lw	$t3, k
	mul	$t3, $t3, 4
	add	$t0, $t0, $t3
	sw	$t1, 0($t0)
	move 	$a0, $t1
	li	$v0, 1
	syscall
	la	$t0, array
	lw	$a0, 8($t0)
	syscall
	li	$v0, 10		# $v0 = 10
	syscall #EXIT PROGARM
