#
#	Name:		Just, Kyle
#	Project:	BMI - Final
#	Due:		12/10/2021
#	Course:		cs-2640-02-F21
#
#	Description:
#		This program will calculate BMI given a height and a weight

	.data
name:	.asciiz	"BMI by K. Just\n\n"
promptW:.asciiz	"Enter weight? "
promptH:.asciiz	"Enter height? "
bmiText:.asciiz	"BMI = "


	.text
####################################################################################################
	#This will print a newline
newline:	#INPUT = NONE
		#OUTPUT = NONE
#---------------------------------------------------------------------------------------------------
	li	$a0, '\n'	#load char for newline
	li	$v0, 11		#prep the printChar() syscall
	syscall			#printChar()
	jr	$ra		#RETURN
####################################################################################################
	#This will print a float
floatprint:	#INPUT = $f12	(float number)
		#OUTPUT = NONE
#---------------------------------------------------------------------------------------------------
	li	$v0, 2		#prep printFloat() syscall
	syscall			#print float in $f12
	jr	$ra		#RETURN
####################################################################################################
	#This will print a string
print:		#INPUT = $a0	(str* address)
		#OUTPUT = NONE
#---------------------------------------------------------------------------------------------------
	li	$v0, 4		#prep printStr() syscall
	syscall			#print string in $a0
	jr	$ra		#RETURN
####################################################################################################
bmi:
	#INPUT = $f12, $f13 (weight, height)
	#OUTPUT = $f0	(BMI)
#---------------------------------------------------------------------------------------------------
	mul.s	$f4, $f13, $f13
	li.s	$f5, 703.0
	div.s	$f4, $f5, $f4
	mul.s	$f0, $f4, $f12
	jr	$ra
####################################################################################################
main:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	la	$a0, promptW
	jal	print
	li	$v0, 6
	syscall
	mov.s	$f12, $f0
	la	$a0, promptH
	jal	print
	li	$v0, 6
	syscall
	mov.s	$f13, $f0
	jal	bmi
	mov.s	$f12, $f0
	la	$a0, bmiText
	jal	print
	jal	floatprint
	jal	newline
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
