#
#	Name:		Just, Kyle
#	Midterm:	Part 2
#	Due:		11/05/2021
#	Course:		cs-2640-02-f21
#
#	Description:
#		This program will list the argments of an array and find the
#		maximum and minimum of the array as well
	.data
name:	.asciiz "Min Max by K. Just\n\n"
array:	.word	43, 31, 19, 85, 66, 49, 78, 58, 77, 26
minText:.asciiz	"Min = "
maxText:.asciiz	"Max = "
	.text
###############################################################################
newline:
#------------------------------------------------------------------------------
	li	$a0, '\n'
	li	$v0, 11
	syscall
	jr	$ra
###############################################################################
numPuts:		#this will use $a0 for its input numbers
#------------------------------------------------------------------------------
	li	$v0, 1		#prep printInt() syscall
	syscall			#print int in $a0
	jr	$ra
###############################################################################
puts:		#this will use $a0 for its input string
#------------------------------------------------------------------------------
	li	$v0, 4		#prep printStr() syscall
	syscall			#print string in $a0
	jr	$ra
###############################################################################
minmax:		#This will find the minimum and maximum
			#$a0 is the array address
			#$a1 is the array size
#------------------------------------------------------------------------------
	move 	$t0, $a0	#move address to $t0 to preserve og address
	li	$t1, -1		#Start the counter for the array
	addi	$a1, $a1, -1	#adjust for the loop arithmetic
	lw 	$t3, 0($t0)	#This will hold the max value
	lw	$t4, 0($t0)	#This will hold the min value
	addi	$t0, $t0, -4	#Move onto the next variable
loop:
	addi	$t1, $t1, 1	#make sure to count it
	addi	$t0, $t0, 4
	lw	$t5, 0($t0)	#grab variable at next location
	bgt	$t5, $t4, notMin#compare with the min
	move 	$t4, $t5	#make the new min
notMin:
	blt	$t5, $t3, notMax#compare with max
	move 	$t3, $t5	#make the new max
notMax:
	bne	$t1, $a1, loop	#check if weve reached the end of the array
	move 	$v1, $t3
	move 	$v0, $t4
	jr	$ra
			#retrun the min at $v0
			#return the max at $v1
###############################################################################

main:
	la	$a0, name
	li	$v0, 4
	syscall
	la	$t0, array
	addi	$t0, $t0, -4
	li	$t1, -1
listLoop:
	addi	$t0, $t0, 4
	addi	$t1, $t1, 1
	lw	$a0, 0($t0)
	jal	numPuts
	jal	newline
	bne	$t1, 9, listLoop
	jal	newline
	la	$a0, array
	li	$a1, 10
	jal	minmax
	move 	$t0, $v0	#keep the min
	move 	$t1, $v1	#keep the max
	la	$a0, minText
	jal 	puts
	move 	$a0, $t0
	jal	numPuts
	jal	newline
	la	$a0, maxText
	jal	puts
	move 	$a0, $t1
	jal	numPuts
	jr	$ra

#	li	$v0, 10		# $v0 = 10
#	syscall #EXIT PROGARM
