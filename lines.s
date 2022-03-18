#
#	Name:		Just, Kyle
#	Project:	#3
#	Due:		10/29/2021
#	Course:		cs-2640-02-F21
#
#	Description:
#		This program will read the user's input of a string up to 10 times and at a 32
#		character limit storing them in an array. It will then list all of the given strings
#		back to the user.

MAXLINES = 10
LINELEN = 32
LENCHECK = LINELEN - 1
NEWCHECK = LINELEN - 2
	.data
name:	.asciiz "Lines by K. Just\n\n"
prompt:	.asciiz "Enter text? "
inbuf:	.space	LINELEN
lines:	.word	MAXLINES

	.text
####################################################################################################
strlen:		#This will use the register $a0 for its string to read
#---------------------------------------------------------------------------------------------------
	li	$v1, 0		#$v0 will hold the length
	move 	$t0, $a0	#copy the address to a temp register
lengthLoop:
	lb	$t1, ($t0)	# grab the character at the beginning of the array
	beqz	$t1, lengthEnd	# if $t3 == 0, that is the terminator
	addi	$t0, $t0, 1	# increment the character in the string
	addi	$v1, $v1, 1	# add 1 to the total length
	b 	lengthLoop	# repeat the loop
lengthEnd:
	jr	$ra
		#This will return to register $v1
####################################################################################################
strdup:		#This will use the register $a0 to get its string destination
#---------------------------------------------------------------------------------------------------
	addi	$sp, $sp, -8	#create room in the stack for 2 addresses
	sw 	$ra, 0($sp)	#keep the return address at the bottom of the stack
	sw	$a0, 4($sp)	#keep the original string above the return address
	jal	strlen		#measure the length of the string
	sub	$t1, $0, $v1	#save the TRUE negative value in $t1 (without /0)
	addi	$v1, $v1, 1	#will add 1 to the string length to make room for the \0
	move 	$a0, $v1	#put the length in the $a0 register for malloc
	jal	malloc		#for the malloc function to allocate
	lw	$t2, 4($sp)	#grab the original string address from the stack
	lw	$ra, 0($sp)	#grab the return address from the stack
	addi	$sp, $sp, 8	#close the spots opened in the stack
fillLoop:
	lb	$t0, 0($t2)	#take the letter of the original string
	sb	$t0, 0($v0)	#place in the same spot on the new string
	beqz	$t0, fillEnd	#end if the letter just placed was the \0
	addi	$t2, $t2, 1	#increment the og string
	addi	$v0, $v0, 1	#increment the dup string
	b	fillLoop	#loop again
fillEnd:
	add	$v0, $v0, $t1	#This will assure that the return points to the correct char
	jr	$ra
		#This will return the copied string at $v0
####################################################################################################
malloc:		#This will use the register $a0 for the size of memory to allocate
#---------------------------------------------------------------------------------------------------
	li	$v0, 9		#prep sbrk() syscall
	addi	$a0, $a0, 3	#will add 3 to ensure that the rounding covers the total bytes
	srl	$a0, $a0, 2	#shift right to delete last 2 bits in the number of $a0
 	sll	$a0, $a0, 2	#replace to the original number with 0's in the last 2
	syscall			#allocate the memory
	jr	$ra
		#return value will be in $v0
####################################################################################################
gets:		#This will user input store it at the destination at $a0
		#and will use the amount of characters in $a1
#---------------------------------------------------------------------------------------------------
	move 	$t1, $a0	#Hold the pointer to the string
#	addi	$a1, $a1, 1	#need to add 1 to get syscall to accept 32
	li	$v0, 8		#prep readStr() syscall
	syscall			#Collect string to be saved
	li	$t3, 0		#start the counter of how large the string is
getsLoop:			#start of the loop
	lb	$t4, ($a0)	#get the byte to copy from user input
	sb	$t4, ($t1)	#put the byte in the new string
	beq	$t4, '\n', getsEnd	#check if the just placed char is a newline
	beqz	$t4, getsTerminated	#check if we've reached the end of the string
	addi	$a0, $a0, 1	#increment the pointer of the user string
	addi	$t1, $t1, 1	#increment the pointer to the buffer
	addi	$t3, $t3, 1	#increment the count of chars put in
	b	getsLoop	#repeat loop
getsEnd:			#use this label when the string still needs a \0
	addi	$t1, $t1, 1	#increment the buffer 1 last time
	addi	$t3, $t3, 1	#increment the char count one more time
	li	$t4, 0		#load the terminating char into a register
	sb	$t4, ($t1)	#insert the \0 at the end of the buffer string
	sub	$t1, $t1, $t3	#reset the pointer back to the start of the buffer
	move 	$a0, $t1	#move the buffer back to $a0 for ease of use
	jr	$ra
getsTerminated:			#use this when the terminator has already been seen
	sub	$t1, $t1, $t3	#reset the pointer back to the start of the buffer
	li	$a0, '\n'	#load a newline
	li	$v0, 11		#prep printChar() syscall
	syscall			#print the newline
	move 	$a0, $t1	#move the buffer back to $a0 for ease of use
	jr	$ra
#no return value
####################################################################################################
puts:		#this will use $a0 for its input string
#---------------------------------------------------------------------------------------------------
	li	$v0, 4		#prep printStr() syscall
	syscall			#print string in $a0
	jr	$ra
####################################################################################################
main:		#MAIN
#---------------------------------------------------------------------------------------------------
	la	$a0, name	#load name for title
	li	$v0, 4		#prep printStr() syscall
	syscall			#print name
	la	$t2, lines	#get the array that we will be storing in
	li	$t3, 0		#track how many lines I put in
	addi	$sp, $sp, 12	#make room for registers to be saved in the stack
promptLoop:
	beq	$t3, MAXLINES, maxReached	#tests if the lines entered have reached the max
	la	$a0, prompt	#load prompt to print
	li	$v0, 4		#prep printStr() syscall
	syscall			#print prompt
	sw	$t2, 0($sp)	#store array address on bottom
	sw	$t3, 4($sp)	#store counter on top of address
	la 	$a0, inbuf	#load the input buffer to use gets on
	li	$a1, LINELEN	#number of char limit
	jal	gets		#run the gets function
	lb	$t0, ($a0)	#grabs the first letter of the retrved string
	beq	$t0, '\n', promptEnd	#check if the user has hit the return
	jal	strdup		#copy the string in the a0 to a new address
	lw	$t2, 0($sp)	#retrive the array address from stack
	lw	$t3, 4($sp)	#retrive counter from stack
	sw	$v0, 0($t2)	#store the address on the array
	addi	$t2, $t2, 4	#go to the next word in the array
	addi	$t3, $t3, 1	#count 1 line in the array
	b 	promptLoop
maxReached:
	sw	$t3, 4($sp)	#keep the count updated in the stack as well
	sw	$t2, 0($sp)	#keep the stack updated for the list function
promptEnd:
	lw	$t3, 4($sp)	#fetch the latest count from the stack
	lw	$t2, 0($sp)	#fetch array address from stack
	mul	$t0, $t3, 4	#get the total number of bytes that the array has been moved
	sub	$t2, $t2, $t0	#move the array back that ^ many bytes
	li	$t0, 0		#I'll use this to count how many lines I've printed
	li	$a0, '\n'	#load a newline to be printed
	li	$v0, 11		#prep printChar() syscall
	syscall			#print the newline
listLoop:
	beq	$t0, $t3, listEnd	#check if the total amount of lines have been printed
	sw	$t0, 0($sp)	#store the counting variable
	sw	$t3, 4($sp)	#store the total number of lines we have above the counter
	sw	$t2, 8($sp)	#store the array address above the total number of lines
	lw	$a0, ($t2)	#load where the next string should be at in the array
	jal 	strlen		#I'll use this to determine if the string is a max length
	lw	$t0, 0($sp)	#grab the counting variable back from the stack
	lw	$t3, 4($sp)	#grab the total lines back from the stack
	lw	$t2, 8($sp)	#grab the address of the array back from stack
	bne	$v1, LENCHECK, notMax	#check if the line to be printed is at max capacity
	lb	$t4, NEWCHECK($a0)	#grab the char just before the terminating char in a string
	beq	$t4, '\n', notMax	#if its already a new line, then skip this
	jal	puts		#print the string
	li	$a0, '\n'	#load newline to print
	li	$v0, 11		#prep printStr() syscall
	syscall			#print newline for the max length strings
	addi	$t2, $t2, 4	#move to the next string address that will be 4 bytes away
	addi	$t0, $t0, 1	#increment the string counter by 1 since we printed a string
	b	listLoop
notMax:
	jal	puts		#print the string
	addi	$t2, $t2, 4	#move to the next string address that will be 4 bytes away
	addi	$t0, $t0, 1	#increment the string counter by 1 since we printed a string
	b	listLoop	#loop back until finished
listEnd:
	addi	$sp, $sp, -12	#close the space opened in the stack
####################################################################################################
	li	$v0, 10		#prep exit() syscall
	syscall			#EXIT PROGARM
