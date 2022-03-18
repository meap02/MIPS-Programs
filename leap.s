#
#	Name:		Just, Kyle
#	Project:	leap.s
#	Due:		10/20/2021
#	Course:		cs-2640-02-F21
#
#	Description:
#		This program will count the leap years between any 2 years
##########################################################################
	.data
name:	.asciiz	"Leap Years by K. Just\n"
prompt1:.asciiz	"\nFrom year? "
prompt2:.asciiz	"To year? "
errorPrompt:
	.asciiz	"That range is invalid, try swapping the years around\n"
answer:	.asciiz	"\nLeap years from "
to:	.asciiz	" to "
colon:	.asciiz	":\n"
fromyr:	.word	0
toyr:	.word	0
########################################################################
	.text
error:
	la	$a0, errorPrompt
	li	$v0, 4
	syscall
	b	retry
main:
#NAME PRINT
	la	$a0, name	#load name
	li	$v0, 4		#prep printStr() syscall
	syscall			#print name
#PROMPT PRINT AND RETRIVE
retry:
	la	$a0, prompt1	#load first prompt
	syscall			#print the first prompt
	li	$v0, 5		#prep readInt() syscall
	syscall			#fetch from year from user
	sw 	$v0, fromyr	#store the from year in memory
	la	$a0, prompt2	#load the second prompt
	li	$v0, 4		#prep printStr() syscall
	syscall			#print second prompt
	li	$v0, 5		#prep readInt() syscall
	syscall			#fetch to year from user
	sw	$v0, toyr	#store to year in memory
#PRINT ANSWER HEADER
	lw	$t0, fromyr	#load the user's from year
	lw	$t1, toyr	#load the user's to year
	bgt	$t0, $t1, error
	la	$a0, answer	#load the answer prompt
	li	$v0, 4		#prep printStr() syscall
	syscall			#print answer prompt
	move 	$a0, $t0	#move fromyr to print dock
	li	$v0, 1		#prep the printInt() syscall
	syscall			#print user's from year
	la	$a0, to		#load the " to "
	li	$v0, 4		#prep the printStr() syscall
	syscall			#pring the " to "
	move 	$a0, $t1	#move toyr to print dock
	li	$v0, 1		#prep the printInt() syscall
	syscall			#print user's to year
	la	$a0, colon	#load colon
	li	$v0, 4		#prep printStr() syscall
	syscall			#print ":\n"
#LEAP YEAR CONDITIONALS
	addi	$t0, $t0, -1
while:
	addi	$t0, $t0, 1	#Increment the year being checked by 1
	rem	$t3, $t0, 400	#get the 400 remainder for the year
	beqz	$t3, leap	#branch if divisible by 400
	rem	$t3, $t0, 100	#get the 100 remainder for the year
	beqz	$t3, notleap	#branch if is divisible by 100 and not 400
	rem	$t3, $t0, 4	#get the 4 remainder from the year
	bnez	$t3, notleap	#finally branch if it is not a multiple of 4
leap:	move 	$a0, $t0	#load current year to be printed
	li	$v0, 1		#prep printInt() syscall
	syscall			#print the leap year
	li	$a0, '\n'	#load a newline
	li	$v0, 11		#prep printChar() syscall
	syscall			#print the newline
notleap:
	bne	$t0, $t1, while
	li	$v0, 10		# $v0 = 10
	syscall #EXIT PROGARM
