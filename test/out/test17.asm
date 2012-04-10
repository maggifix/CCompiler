.text
_start:
  jal main
  addi $sp, $sp, -4 
  sw $2, 0($sp)
  jal exit
.text

print:
  addi $sp, $sp, -8
  sw $31, 4($sp)
  sw $fp, 0($sp)
  move $fp, $sp

  li $2, 1 
  lw $4, 8($fp)
  syscall 

  li $2, 11
  li $4, 10            # \n
  syscall

  lw $fp, 0($sp)
  lw $31, 4($sp)
  addi $sp, $sp, 8
  jr $31

scan:
  addi $sp, $sp, -8
  sw $31, 4($sp)
  sw $fp, 0($sp)
  move $fp, $sp

  li $2, 5
  syscall 

  lw $fp, 0($sp)
  lw $31, 4($sp)
  addi $sp, $sp, 8
  jr $31

exit:
  addi $sp, $sp, -8
  sw $31, 4($sp)
  sw $fp, 0($sp)
  move $fp, $sp

  li $2, 17 
  lw $4, 8($fp)
  syscall

.data

.text

main:	# Beginning of a function. We will save the return adress $31 and the $fp.
	ADDI $sp, $sp, -8
	SW $31, 4($sp)
	SW $fp, 0($sp)
	MOVE $fp, $sp

	ADDI $sp, $sp, -12	#Allocate Memory on stackpointer for local Variables
	#int hax[1]: 8($sp)
	#int i: 4($sp)
	#int j: 0($sp)
	LI $5, 0	#Number recognised:0
	LW $6, 4($sp)	#Local Variable recognised:i
	SW $5, 4($sp)	#Assign one register to another
	LW $5, 4($sp)	#Local Variable recognised:i
	LI $6, 535821296	#Number recognised:535821296
	SUB $15, $5, $6	#Subtract 2 Variables and store result int temp register
	LW $6, 0($sp)	#Local Variable recognised:j
	SW $15, 0($sp)	#Assign one register to another
	LI $5, 1337	#Number recognised:1337
	LA $6, 8($sp)	#Local Variable recognised:hax
	LW $7, 0($sp)	#Local Variable recognised:j
	LI $8, 4	#Load Number 4 into a register
	MUL $9, $8, $7	#Multiplying array position by 4 (each entry has the size of 4 bytes)
	ADD $9, $6, $9	#Add the starting position of the array to the position
	SW $5, 0($9)	#Assign one register to another
	#End of function main. We will restore the return adress $31 and the $fp. Then we will jump back to where the func was called.
	ADDI $sp, $sp, 12	# delete local variables
	LW $fp, 0($sp)
	LW $31, 4($sp)
	ADDI $sp, $sp, 8
	JR $31

