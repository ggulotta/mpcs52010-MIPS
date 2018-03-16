	.data	
A_in:    .asciiz "/home/ggulotta/MPCS 52010 - Computer Architecture/MIPS/A.in"
B_in:    .asciiz "/home/ggulotta/MPCS 52010 - Computer Architecture/MIPS/B.in"
C_out: 	 .asciiz "/home/ggulotta/MPCS 52010 - Computer Architecture/MIPS/C.out"
newline: .asciiz "\n"
	.text

main:
	li $t0, 8								# set n = 8
	li $t1, 4					
	mul $t2, $t0, $t0
	mul $t2, $t2, $t1						# 4 * n * n = 256
	li $t4, 0								# i = 0
	li $t5, 0								# j = 0
	sw $t0, -4($sp)							# store n
	sw $t2, -8($sp)							# store array size
	sw $t4, -16($sp)						# store i
	sw $t5,	-20($sp)						# store j
	
	la $a0, A_in							# set filename
	addi $fp, $sp, 0						# set frame pointer
	
	jal read								# read A
	
	la $a0, B_in							# set filename
	lw $t0, -8($sp)							# load array size
	add $fp, $fp, $t0						# increment frame pointer
	
	jal read								# read B
	
	lw $t0, -8($sp)							# load array size
	la $a0, ($sp)							# starting address of A = sp
	add $a1, $a0, $t0						# starting address of B = sp + array size
	add $a2, $a1, $t0						# starting address of C = sp + 2 * array size
	lw $a3, -4($sp)							# load n
	
	jal mxm									# calculate MxM
	
	jal print								# print dot product	
	
	la $a0, C_out							# set filename
	
	jal write								# write to C
	
	li $v0, 10								# exit
	syscall
	
# args: filename (a0)
read: 
	li $v0, 13								# open file for reading		
	li $a1, 00				
	li $a2, 0777			
	syscall
	move $a0, $v0
	
	li $v0, 14								# read from file
	move $a1, $fp							# set starting address
	lw $a2, -8($sp)							# set buffer size = array size
	syscall
	
	jr $ra
	
# args: filename (a0)
write:
	li $v0, 13								# open file
	li $a1, 0x41
	li $a2, 0x1FF
	syscall
	
	move $a0, $v0							# move descriptor to a0
	
	li $v0, 15								# write
	la $a1, ($fp)							# load start address of C
	lw $a2, -8($sp)							# set buffer size = array size
	syscall
	
	move $s0, $v0							# save output code
	
	li $v0, 16								# close file
	syscall
	
	jr $ra

# args: filename (a0)	
print:
	li $t0, 0								# initialize counter
	
	print_loop:
		li $v0, 1								# print c[n]
		lw $a0, ($fp)
		syscall			
	
		li $v0, 4								# print newline
		la $a0, newline
		syscall
	
		addi $fp, $fp, 4						# increment fp
		addi $t0, $t0, 1						# increment counter
		bne $t0, 64, print_loop
		
	lw $t0, -8($sp)								# load array size
	sub $fp, $fp, $t0							# reset fp
	jr $ra
	
	
# args: addr_A (a0), addr_B	(a1), addr_C (a2), n
mxm:
	move $fp, $a2							# set frame pointer to C's start address
	move $s0, $a0							# store start address of A in s0
	move $s1, $a1							# store start address of B in s1
	move $s2, $a2							# store start address of C in s2
	move $s3, $a3							# store n in s3
	sw $ra, -24($sp)						# save current return address
	
	mxm_outer:
		li $t0, 0
		sw $t0, -20($sp)					# reset j
		lw $t3, -8($sp)						# load array size
		add $s1, $sp, $t3					# reset start address of B
		
		mxm_inner:
			move $a0, $s0					# start address of A
			move $a1, $s1					# start address of B
			li $a2, 1						# q = 1
			move $a3, $s3					# p = n = 8
			
			jal dot_product					# calculate dot product (s4)			
			
			sw $s4, ($s2)					# save at start address of C
			
			addi $s1, $s1, 4				# increment start address of B by 4
			addi $s2, $s2, 4				# increment start address of C by 4
			lw $t0, -20($sp)				# load j
			addi $t0, $t0, 1				# increment j
			sw $t0, -20($sp)				# save j
			bne $t0, $s3, mxm_inner 
		
		lw $t0, -16($sp)					# load i
		addi $t0, $t0, 1					# increment i
		sw $t0, -16($sp)					# save i
		li $t1, 4
		mul $t1, $t1, $s3
		add $s0, $s0, $t1					# increment start address of A by (4 * n)
		bne $t0, $s3, mxm_outer
		
	lw $ra, -24($sp)						# load old return address
	jr $ra
		
	
	
# args: addr_A (a0), addr_B (a1), stride p (a2), stride q (a3), n (stack)
dot_product:
	move $t0, $a0							# store start address of A
	move $t1, $a1							# store start address of B
	li $t2, 0								# accumulate sum
	li $t3, 0								# loop counter
	lw $t4, -4($sp)							# store n
	
	dot_loop:
		lw $t5, ($t0)						# load specific value from A
		lw $t6, ($t1)						# load specific value from B
		mul $t6, $t5, $t6					# product = A[n] * B[n]
		add $t2, $t2, $t6					# sum = sum + product
		move $s4, $t2						# move to register s4
		addi $t3, $t3, 1					# increment counter
		li $t7, 4
		mul $t8, $a2, $t7					# actual stride = 4 * p
		mul $t9, $a3, $t7					# actual stride = 4 * q
		add $t0, $t0, $t8					# increment address of A
		add $t1, $t1, $t9					# increment address of B
		bne $t3, $t4, dot_loop

	jr $ra
