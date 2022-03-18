#
#	Name:		Just, Kyle
#	Project:	#5
#	Due:		12/03/2021
#	Course:		cs-2640-02-F21
#
#	Description:
#		This program will solve quadratic equations. To do this, it will fetch the a, b,
#		and c coeficients of the desired equation to be solved and then perform the required
#		operations to tell you of the roots are imaginary, the equation is not quadratic
#		or the 1 or 2 roots to the equation.

	.data
name:	.asciiz	"Quadratic Equation Solver by K. Just\n\n"
prompta:.asciiz	"Enter values for a: "
promptb:.asciiz	"Enter values for b: "
promptc:.asciiz	"Enter values for c: "
result:	.asciiz	"x = "
result1:.asciiz	"x1 = "
result2:.asciiz	"x2 = "
notquad:.asciiz	"Not a quadratic equation."
imagi:	.asciiz	"Roots are imaginary."
avar:	.float	0.0
bvar:	.float	0.0
cvar:	.float	0.0

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
###################################################################################################
	#This will print a float
floatprint:	#INPUT = $a0	(float number)
		#OUTPUT = NONE
#---------------------------------------------------------------------------------------------------
	li	$v0, 2		#prep printFloat() syscall
	syscall			#print float in $a0
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
	#This will take a float and return the square root of the input as a float as well. Will
	#specifically use the babylonian method to calculate the square root.
sqrts:		#INPUT = $f12	(float radicand)
		#OUTPUT = $f0	(float result)
#---------------------------------------------------------------------------------------------------
	li.s	$f0, 0.0	#load in 0 to be checked against $f12
	c.eq.s	$f12, $f0	#check if the the sqrt(0) is being calculated
	bc1t	endloop		#jump to the end because sqrt(0) = 0
	mov.s	$f20, $f12	#keep the original number to calculate for
	li.s	$f21, 2.0	#Keep 2 in a saved register for repeated use
	li.s	$f0, 1.0	#start the comparison at 1, because sqrt(1) = 1
startloop:
	c.eq.s	$f0, $f12	#check if the convergence of the last interation and this are equal
	mov.s 	$f12, $f0	#copy the current value to use as next iterations prev value
	bc1t	endloop		#if they are, we have reached max accuracy with a float
	div.s	$f4, $f20, $f0	#divide the original value by the last value
	add.s	$f4, $f4, $f0	#will add the prev divided value to the last value
	div.s	$f0, $f4, $f21	#divide the entire expression by 2
	b	startloop	#repeat
endloop:
	jr	$ra		#RETURN
####################################################################################################
	#This will solve for the roots of a quadratic system of equations
quadeqs:
		#INPUT = $f12, $f13, $f14	(float a, float b, float c)
		#OUTPUT = $v0:
			#-1:	imaginary	string in $v1
			#0:	not quadratic	string in $v1
			#1:	single root	x in $f0
			#2:	double root	x1 and x2 in $f0 and $f1
#---------------------------------------------------------------------------------------------------
	mtc1	$0, $f19	#make a $0 register within the FPU
	c.eq.s	$f12, $f19	#check if a = 0
	bc1t	a0		#if a = 0 then we narrow down the options
	mul.s	$f4, $f13, $f13	#$f4 will hold b^2
	mul.s	$f5, $f12, $f14	#$f5 will hold ac, to then be multiplied by 4
	li.s	$f6, 4.0	#load 4.0 into $f6 to be used in the next instruction
	mul.s	$f5, $f6, $f5	#calculation for 4ac in the quadratic equation
	sub.s	$f15, $f4, $f5	#$f15 will hold our discriminant
	c.lt.s	$f15, $f19	# if d is less than 0, than the roots are imaginary
	bc1t	xi		#d IS negative and the roots are imaginary
	neg.s	$f13, $f13	#negate the b value for calculations (og b is not needed anymore)
	addi	$sp, $sp, -16	#make room in the stack for 4 words
	sw	$ra, 0($sp)	#store return address as this is a non leave function
	s.s	$f12, 4($sp)	#store the first operand, a
	s.s	$f13, 8($sp)	#store the second operand, b
	s.s	$f14, 12($sp)	#store the third operand, c
	mov.s	$f12, $f15	#move the d into $f12 to be square rooted
	jal	sqrts		#call the sqrt function on d
	mov.s 	$f15, $f0	#move the sqrt(d) back into $f15
	lw	$ra, 0($sp)	#fetch the return address to the return register
	l.s	$f12, 4($sp)	#fetch the first operand from the stack
	l.s	$f13, 8($sp)	#fetch the second operand from the stack
	l.s	$f14, 12($sp)	#fethch the third operand from the stack
	addi	$sp, $sp, 16	#close the hole made in the stack
	li.s	$f5, 2.0	#load a 2 to be multiplied by the a
	mul.s	$f12, $f12, $f5	#multiply a by 2 for the division (og a is not needed anymore)
	add.s	$f4, $f13, $f15	#will add -b and d for the upper root numerator
	div.s	$f0, $f4, $f12	#finally will divide -b+d by 2a and places the upper root in $f0
	sub.s	$f4, $f13, $f15	#will subtract d from -b and get the lower root numerator
	div.s	$f1, $f4, $f12	#finally will divide -b-d by 2a and place lower root in $f1
	li	$v0, 2		#notify caller that the quadratic equation had 2 roots
	jr	$ra		#RETURN
a0:
	c.eq.s	$f13, $f4	#now to check if b = 0 as well
	bc1t	ab0		#if it is then our job is done
	neg.s	$f14, $f14	#negate c to use -c in the next instruction
	div.s	$f0, $f14, $f13	#divide -c by b to get the single root in $f0
	li	$v0, 1		#let caller know that there is 1 root
	jr	$ra		#RETURN
ab0:
	li	$v0, 0		#load $v0 to indicate this is not a quadratic
	la	$v1, notquad	#load the string into $v1 to be printed later
	jr	$ra		#RETURN
xi:
	li	$v0, -1		#notify the caller that the roots are imaginary
	la	$v1, imagi	#load the imaginary prompt for the caller to use
	jr	$ra		#RETURN
####################################################################################################
	#This will perform the following instuctions on execution of this file
main:		#INPUT = NONE
		#OUTPUT = NONE
#---------------------------------------------------------------------------------------------------
	addi	$sp, $sp, -4	#create room in stack for return address
	sw	$ra, 0($sp)	#store return address for exiting main
	la	$a0, name	#load my name to be printed
	jal	print		#print my name and name of program
	la	$a0, prompta	#load prompt for a to be printed
	jal	print		#print the prompt for a
	li	$v0, 6		#prepare to get float from user
	syscall			#get float from user
	s.s	$f0, avar	#move the collected float to a
	la	$a0, promptb	#load prompt for b to be printed
	jal	print		#print the prompt for a
	li	$v0, 6		#prepare to get float from user
	syscall			#get float from user
	s.s	$f0, bvar	#move the collected float to b
	la	$a0, promptc	#load prompt for c to be printed
	jal	print		#print the prompt for a
	li	$v0, 6		#prepare to get float from user
	syscall			#get float from user
	s.s	$f0, cvar	#move the collected float to c
	jal	newline		#print a newline for correct output spacing
	l.s	$f12, avar	#load a into the first argument for quadeqs()
	l.s	$f13, bvar	#load b into the first argument for quadeqs()
	l.s	$f14, cvar	#load c into the first argument for quadeqs()
	jal	quadeqs		#run the quadeqs() function to find the roots of the equation
	blez	$v0, string	#if the equation is imaginary or not quadratic
	beq	$v0, 1, oneroot	#if the eqation has 1 root
	la	$a0, result1	#otherwise the equation has 2 roots and we begin loading the output
	jal	print		#print the first root label
	mov.s	$f12, $f0	#move the first root to $f0 to be printed
	jal	floatprint	#print the first root
	jal	newline		#newline for correct output
	la	$a0, result2	#load the second root's label to be printed
	jal	print		#print the second root label
	mov.s	$f12, $f1	#move the second root to $f0 to be printed
	jal	floatprint	#print the second root
	jal	newline		#print another newline for correct output spacing
	b	end		#jump to the end of the program, as it has completed its function
oneroot:
	la	$a0, result	#load the single root label from memory
	jal	print		#print the single root label
	mov.s	$f12, $f0	#move the single root into $f0 to be printed
	jal	floatprint	#print the single root
	jal	newline		#print a newline for correct output
	b	end		#jump to the end of the program, as it has completed its function
string:
	move 	$a0, $v1	#move the string given by quadeqs() to $a0 to be printed
	jal	print		#print the error string
	jal	newline		#create newline for output cleanliness
	b	end		#jump to the end of the program, as it has completed its function
end:
	lw	$ra, 0($sp)	#retrive the original return address from the stack
	addi	$sp, $sp, 4	#close the hole in the stack
	jr	$ra		#EXIT PROGARM
