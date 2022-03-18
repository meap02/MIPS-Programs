#
#	MIPS32 Hello World!
#	cs2640
#

	.data
hello:	.ascii "MIPS32 by K. Just\n\n"
	.asciiz	"Hello World!\n"

	.text
main:
	la	$a0, hello	#display Hello
	li	$v0, 4
	syscall

	li	$v0, 10		#exit
	syscall
