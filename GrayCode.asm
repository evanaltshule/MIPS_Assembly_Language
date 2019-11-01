#------- Data Segment ----------
.data
# output messages and data
newline: 	.asciiz "\n"
msg1:	.asciiz "The 1-bit Gray Code is:\n"
msg2:	.asciiz "The 2-bit Gray Code is:\n"
msg3:	.asciiz "The 3-bit Gray Code is:\n"
msg4:	.asciiz "The 4-bit Gray Code is:\n"
space: 	.asciiz " "
array1: 	.word 0,1
array2: 	.word 0,0,0,0
array3: 	.word 0,0,0,0,0,0,0,0
array4: 	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

#------- Text Segment ----------
.text 
.globl main
main:

        la      $s1, array1
        la      $s2, array2
        la      $s3, array3
        la      $s4, array4            

        # generate 2-bit Gray Code based on 1-bit Gray Code
        # parameter passing
        add     $a0, $zero, $s1 #$a0 is the base address of array1
        add     $a1, $zero, $s2 #$a1 is the base address of array2
        addi    $a2, $zero, 2   #$a2 is the length of array holding the (n-1)-bit Gray code (i.e. length of the array1 holding the 1-bit Gray code)
        jal     mirror         
        jal     addOneToLeft    

        # generate 3-bit Gray Code based on 2-bit Gray Code
        # parameter passing
        add     $a0, $zero, $s2  #$a0 is the base address of array2
        add     $a1, $zero, $s3  #$a1 is the base address of array3
        addi    $a2, $zero, 4    #$a2 is the length of the array holding the 2-bit Gray code
        jal     mirror         
        jal     addOneToLeft

        # generate 4-bit Gray Code based on 3-bit Gray Code
        # parameter passing
        add     $a0, $zero, $s3  #$a0 is the base address of array3
        add     $a1, $zero, $s4  #$a1 is the base address of array4
        addi    $a2, $zero, 8    #$a2 is the length of the array holding the 3-bit Gray code
        jal     mirror        
        jal     addOneToLeft

        #output 1-bit gray code
        la $a0,msg1
        addi $v0,$zero,4
        syscall
        add $a1,$zero,$s1
        addi $a2,$zero,2
        addi $a3,$zero,1
        jal printGrayCode	
	
        #output 2-bit gray code
        la $a0,msg2
        addi $v0,$zero,4
        syscall
        add $a1,$zero,$s2
        addi $a2,$zero,4
        addi $a3,$zero,2
        jal printGrayCode	

        #output 3-bit gray code
        la $a0,msg3
        addi $v0,$zero,4
        syscall
        add $a1,$zero,$s3
        addi $a2,$zero,8
        addi $a3,$zero,3
        jal printGrayCode	

        #output 4-bit gray code
        la $a0,msg4
        addi $v0,$zero,4
        syscall
        add $a1,$zero,$s4
        addi $a2,$zero,16
        addi $a3,$zero,4
        jal printGrayCode	

        # Terminate the program
        li 	$v0, 10 
        syscall			


# This function does the same thing as the mirror() function in the C++ program
# arguments are in $a0, $a1 and $a2
# $a0 (n-1)-bit Gray Code array address, this is the "int original[]" argument in the C++ code
# $a1 n-bit Gray Code array address, this is the "int after_mirroring[]" argument in the C++ code
# $a2 length of (n-1)-bit Gray Code array, this is the "int n" argument in the C++ code
# preserve registers as needed
mirror:
#TODO1 Below

add $t0, $a2, $zero #int n
add $t1, $a0, $zero #base address of original[]
add $t2, $a1, $zero #base address of after_mirroring
addi $t3, $zero, 0 #iterator i

loop1:
slt $t4, $t3, $t0
beq $t4, $zero, loop1end # i < n

sll $t4, $t3, 2
add $t5, $t4, $t2 #address of after_mirroring[i]
add $t4, $t4, $t1 #address of original[i]
lw $t4, 0($t4) #$t4 = original[i]
sw $t4, 0($t5) #after_mirroring[i] = original[i]

addi $t3, $t3, 1
j loop1

loop1end:

add $t3, $t0, $zero # iterator i
add $t4, $t0, $t0 #$t4 = n * 2

loop2:
slt $t5, $t3, $t4
beq $t5, $zero, loop2end # i < n * 2

sub $t6, $t4, $t3 
addi $t6, $t6, -1 # t6 = n * 2 - i - 1
sll $t6, $t6, 2
add $t6, $t6, $t1 
lw $t6, 0($t6) #$t6 = original[n * 2 - i - 1]

sll $t7, $t3, 2
add $t7, $t7, $t2
sw $t6, 0($t7) # after_mirroring[i] = original [n * 2 - i -1] 

addi $t3, $t3, 1
j loop2

loop2end:

#TODO1 Above
jr $ra	# return from mirror()
	

# This function does the same thing as the addOneToLeft() function in the C++ program	
# arguments are in $a1 and $a2
# a1 n-bit Gray Code array address, this is the "int array[]" argument in the C++ code
# a2 length of (n-1)-bit Gray Code array, this is the "int n" argument in the C++ code
# preserve registers as needed
addOneToLeft:
#TODO2 Below

add $t0, $a2, $zero # $t0 = n
add $t1, $a1, $zero # $t1 = base address of array[]
add $t2, $t0, $zero # $t2 = iterator i
add $t3, $t0, $t0     # $t3 = n * 2

loop3:
slt $t4, $t2, $t3
beq $t4, $zero, loop3end #( i < n*2)

sll $t5, $t2, 2
add $t5, $t5, $t1
lw $t6, 0($t5) # $t6 = array[i]
add $t7, $t6, $t0 # $t7 = array[i] + n
sw $t7, 0($t5)

addi $t2, $t2, 1
j loop3

loop3end:

#TODO2 Above
jr $ra	# return from addOneToLeft()

# a1 n-bit Gray Code array address
# a2 length of n-bit Gray Code array
# a3 number of digit
printGrayCode:
        addi $t1, $zero, 0
        add  $t8, $a2, $zero # t8 length of n-bit Gray Code array
	
        printANum:
        slt  $t2, $t1, $t8 # if t1 < t8
        beq  $t2, $zero, exitPrintGrayCode #finished all the numbers in the array
        sll  $t2, $t1, 2
        add  $t2, $t2, $a1
        lw   $t2, 0($t2) # $t2<-array[i]
	
        addi $t4, $zero, 0 # j = 0
        addi $t9, $zero, 1  # mask to extract a digit: '1000' -> '0100' -> '0010' -> '0001'	
        add $t6, $zero, $a3 #t6 holding shift amount for the mask
	
        printTheSameNum:
        slt  $t5, $t4, $a3 # j < number Of Digit For The Number
        beq  $t5, $zero, doneWithThisNum
	
        addi $t6, $t6, -1
        sllv $t3, $t9, $t6 #t3 holding the mask for the current digit
	
        and  $t7, $t2, $t3 #t2 is array[i]
        slt  $t7, $zero, $t7 #if 0<t7, then this digit is 1, ow this digit is 0
	
        add  $a0, $t7, $zero 
        addi $v0, $zero, 1
        syscall
	
        addi $t4, $t4, 1  #t4 is number of digits printed so far, j=j+1	 
        j printTheSameNum
	
        doneWithThisNum:

        la   $a0, space
        addi $v0, $zero, 4
        syscall 
	
	
        addi $t1, $t1, 1	
        j printANum
	
	
        exitPrintGrayCode:#done
	
        la $a0,newline    #print a new line
        addi $v0,$zero,4
        syscall
        
        jr    $ra			# return
