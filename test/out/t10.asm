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

	ADDI $sp, $sp, -4	#Allocate Memory on stackpointer for local Variables
	#int i: 0($sp)
	LI $5, 0	#Number recognised:0
	LW $6, 0($sp)	#Local Variable recognised:i
	SW $5, 0($sp)	#Assign one register to another
	LW $5, 0($sp)	#Local Variable recognised:i
	BGTZ $5, l0
	J l1
l0:
	LI $5, 12	#Number recognised:12
	LW $6, 0($sp)	#Local Variable recognised:i
	SW $5, 0($sp)	#Assign one register to another
	J l2
l1:
	LW $5, 0($sp)	#Local Variable recognised:i
	LI $6, 10	#Number recognised:10
	LI $15, 1	#Number recognised:1
	SUB $14, $5, $6	#If i1 == i2, i0 = 0, else i0 != 0
	MOVN $14, $15, $14	#if i0 != 0, i0 = 1
	XOR $14, $14, $15	#i0 = !i0
	LI $15, 1	#Number recognised:1
	XOR $14, $14, $15	#i0 = !i0
	BGTZ $14, l3
	J l3
l3:
	LI $5, 0	#Number recognised:0
	LW $6, 0($sp)	#Local Variable recognised:i
	SW $5, 0($sp)	#Assign one register to another
l2:
	LW $5, 0($sp)	#Local Variable recognised:i
	MOVE $2, $5	#Return i
	J l4
l4:
	#End of function main. We will restore the return adress $31 and the $fp. Then we will jump back to where the func was called.
	ADDI $sp, $sp, 4	# delete local variables
	LW $fp, 0($sp)
	LW $31, 4($sp)
	ADDI $sp, $sp, 8
	JR $31

