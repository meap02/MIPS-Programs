#
#	Name:		Just, Kyle
#	Project:	#4
#	Due:		11/24/2021
#	Course:		cs-2640-02-F21
#
#	Description:
#		This program will take input from the user as strings and store them in a linked
#		list. It will then output all of the strings the user specified by using recursion.

MAXCHARS = 10
DATA = 0
NEXT = 4
	.data
name:	.asciiz	"Link List by K. Just\n\n"
prompt: .asciiz	"Enter text? "
head:	.word	0
	.word	0
buffer:	.space MAXCHARS+1
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
	#This will print a number
numprint:	#INPUT = $a0	(int number)
		#OUTPUT = NONE
#---------------------------------------------------------------------------------------------------
	li	$v0, 1		#prep printInt() syscall
	syscall			#print int in $a0
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
	#This will allocate a specific amount of memory on the heap in sections of 4 bytes
malloc:		#INPUT = $a0	(int sizeOfMemory)
		#OUTPUT = $v0	(ptr* memorySpace)
#---------------------------------------------------------------------------------------------------
	li	$v0, 9		#prep sbrk() syscall
	addi	$a0, $a0, 3	#will add 3 to ensure that the rounding covers the total bytes
	srl	$a0, $a0, 2	#shift right to delete last 2 bits in the number of $a0
 	sll	$a0, $a0, 2	#replace the last 2 bits with 0 which rounds to the nearest 4
	syscall			#allocate the memory
	jr	$ra		#RETURN
####################################################################################################
	#This will get the length of a given string (does not include the terminating character)
strlen:		#INPUT = $a0	(str* address)
		#OUTPUT = $v0	(int length)
#---------------------------------------------------------------------------------------------------
	li	$v0, 0		#$v0 will hold the length
lengthLoop:
	lb	$t0, ($a0)	#grab the character at the beginning of the string
	beqz	$t0, lengthEnd	#if $t0 == 0, that is the terminator
	addi	$a0, $a0, 1	#increment the character in the string
	addi	$v0, $v0, 1	#will add 1 to the total length
	b 	lengthLoop	#repeat the loop
lengthEnd:
	jr	$ra		#RETURN
####################################################################################################
	#This will copy a given string to a new place in allocated in the heap. Additionally it will
	#ensure that every string has or is given a newline to ensure proper alignment when printing
strdup:		#INPUT = $a0		(str* inputString)
		#OUTPUT = $v0, $v1	(str* outputString, bool addedNewline)
#---------------------------------------------------------------------------------------------------
	addi	$sp, $sp, -8	#create room in the stack for 2 addresses
	sw 	$ra, 0($sp)	#keep the return address at the bottom of the stack
	sw	$a0, 4($sp)	#keep the original string above the return address
	jal	strlen		#measure the length of the string
	sub	$t1, $0, $v0	#save the TRUE negative value in $t1 (without /0)
	addi	$a0, $v0, 1	#will add 1 to the string length to make room for the terminator
	jal	malloc		#for the malloc function to allocate
	lw	$a0, 4($sp)	#grab the original string address from the stack
	lw	$ra, 0($sp)	#grab the return address from the stack
	addi	$sp, $sp, 8	#close the spots opened in the stack
fillLoop:
	lb	$t0, 0($a0)	#take the letter of the original string
	sb	$t0, 0($v0)	#place in the same spot on the new string
	beq	$t0, '\n', fillEnd#end if the letter just placed was the newline
	beqz	$t0, maxedEnd	#This will trigger if the string doesn't have a newline
	addi	$a0, $a0, 1	#increment the og string
	addi	$v0, $v0, 1	#increment the dup string
	b	fillLoop	#loop again
fillEnd:
	addi	$t1, $t1, 1	#adjustment for not having the inserted newline
	add	$v0, $v0, $t1	#This will assure that the return points to the correct char
	li	$v1, 0		#Indicates the newline already existed
	jr	$ra		#RETURN
maxedEnd:
	li	$t0, '\n'	#load the newline char
	sb	$t0, 0($v0)	#insert it at the end of the string
	add	$v0, $v0, $t1	#pont address back to the beginning of the string
	li	$v1, 1		#Indicates that the newline was given
	jr	$ra		#RETURN
####################################################################################################
	#This will create a node with a string and a link to the next node
addNode:	#INPUT = $a0, $a1	(str* stringToStore, ptr* nextNode)
		#OUTPUT = $v0		(ptr* newNode)
#---------------------------------------------------------------------------------------------------
	addi	$sp, $sp, -12	#Make room for 3 words on stack
	sw	$ra, 0($sp)	#Store return adress during calls
	sw	$a0, 4($sp)	#Store string
	sw	$a1, 8($sp)	#Store the next node
	li	$a0, 8		#prepare to allocate the memory for the node (2 words)
	jal	malloc		#Actually allocate that memory
	lw	$a1, 8($sp)	#grab the next node
	lw	$a0, 4($sp)	#grab the duplicated string address
	lw	$ra, 0($sp)	#return the return address to its rightful place
	addi	$sp, $sp, 12	#Close the 3 words on stack
	sw	$a0, DATA($v0)	#store the dup string in the first slot of node
	sw	$a1, NEXT($v0)	#store next address
	jr	$ra		#RETURN
####################################################################################################
	#This will traverse a linked list starting at the head and perform a given operation on the
	#data segment of each node. Operations will be performed from the node furthest from the
	#head to the node closest to the head.
traverse:	#INPUT = $a0, $a1	(ptr* headNode, ptr* operation)
		#OUTPUT = NONE
#---------------------------------------------------------------------------------------------------
	beqz	$a0, endTraverse#check if we've reached the end of the list
	addi	$sp, $sp, -8	#open stack for return address, function and node
	lw	$a0, NEXT($a0)	#move the next node (first node from head at start)
	sw	$ra, 0($sp)	#store the return address for recursion surfacing
	sw	$a0, 4($sp)	#store the node in the stack
	jal	traverse	#call this function again
	lw	$a0, 4($sp)	#get the node back
	lw	$a0, DATA($a0)	#get to data of the node
	jal	$a1		#use the caller defined function
	lw	$ra, 0($sp)	#get the return address back
endTraverse:
	addi	$sp, $sp, 8	#close the hole in the stack
	jr	$ra		#RETURN
####################################################################################################
	#This will run the following program on execution
main:		#INPUT = NONE
		#OUTPUT = NONE
#---------------------------------------------------------------------------------------------------
	la	$a0, head	#ensure that the list starts empty
	sw	$0, DATA($sp)	#DATA = 0
	sw	$0, NEXT($sp)	#NEXT = 0
	addi	$sp, $sp, -4	#clear space for main return address
	sw	$ra, 0($sp)	#store return address
	la	$a0, name	#load name strings
	jal	print		#print name string
mainLoop:
	la	$a0, prompt	#load prompt
	jal	print		#print prompt
	la	$a0, buffer	#load the buffer that strdup will use to copy
	li	$a1, MAXCHARS+1	#use the max char limit for user input
	li	$v0, 8		#prep the readStr() syscall
	syscall			#read user string
	lb	$a1, 0($a0)	#get the first letter of user input
	beq	$a1, '\n', endMainLoop#check if its a newline
	jal	strdup		#duplicate the buffer
	beqz	$v1, skipNewline#check if the strdup() gave the string a newline already
	addi	$sp, $sp, -4	#if it did, make room in the stack
	sw	$v0, 0($sp)	#save $v0 for the next call
	jal	newline		#print a newline
	lw	$v0, 0($sp)	#restore $v0
	addi	$sp, $sp, 4	#close the hole in the stack
skipNewline:
	move 	$a0, $v0	#move the new allocated string to $a0 to be attatched to a node
	la	$s0, head	#load the head node into $s0
	lw	$a1, NEXT($s0)	#use the next of the head as the next of the new node
	jal	addNode		#create new node
	sw	$v0, NEXT($s0)	#set the head's new next to the new node that was created
	b	mainLoop	#repeat
endMainLoop:
	jal	newline		#make space between the prompts and the next output
	la	$a1, print	#load the address to the print function
	la	$a0, head	#load the address to the head node
	jal	traverse	#begin the traversal process
	lw	$ra, 0($sp)	#restore the return address from start of main
	addi	$sp, $sp, 4	#close the final hole in the stack
	jr	$ra		#RETURN
#	li	$v0, 10		# $v0 = 10
#	syscall			#EXIT PROGARM
