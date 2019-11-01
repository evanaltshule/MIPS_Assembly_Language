#------- Data Segment ----------
.data
# output messages and data
initMsg:	.asciiz "Please enter an integer from 0 to 99 into the array A[] one by one:\n"
EnterNumberMsg1: .asciiz "A["
EnterNumberMsg2: .asciiz "]: "
OrignalMsg: 	.asciiz "Original array:"
CountMsg:	.asciiz "\nBin count output:"
OutputCountMsg1:	.asciiz"\nThe count of "
OutputCountMsg2: .asciiz" in A[] is: \t"
# array A[] has 10 elements, each element is of the size of one word, 32 bits.
A: 	.word 0:10
# array A_count[] has 100 elements, each element is of the size of one word, 32 bits.
A_count: 	.word 0:100
# size: the number of elements in array A[]
size: 	.word 10
#max_range: user input range [0, 99] 
max_range: 	.word 99
space: 	.asciiz "\t"

#------- Text Segment ----------
.text
.globl main

main:
        la $s0,A        #$s0 base address of array A[]
        la $s1,size
        lw $s1,0($s1)   #$s1 size of array A[]
        la $s2,A_count  #$s2 base address of array A_count[]
        la $s3,max_range
        lw $s3,0($s3)   #$s3 is 99, the values user can enter is 0,...,99
	
        # cout << "Please enter an integer from 0 to 99 into the array A[] one by one:\n"
        la $a0, initMsg
        addi $v0, $zero, 4
        syscall

        add $t1,$s1,$zero # $t1 is i, iterator of array_input loop. i = 10 initially
	
        array_input:
        beq  $t1,$zero, passpara # while (i != 0) 
	
        # cout << "A["
        la $a0, EnterNumberMsg1
        addi $v0, $zero, 4
        syscall
	
        # print index
        sub $t2, $s1,$t1 #$s1-$t1 is the index of the current user input integer in array A[]
        add $a0,$t2,$zero #print this index calculated and stored in $t2
        addi $v0, $zero, 1
        syscall
	
        # cout << "]: "
        la $a0, EnterNumberMsg2
        addi $v0, $zero, 4
        syscall
	
        # read user input in $v0
        addi $v0, $zero, 5
        syscall
	
        sll $t3,$t2,2   
        add $t3,$t3,$s0 # $t3 = i*4 + base of A in $s0, addr of A[i]
        sw $v0, 0($t3)  # A[i] = $v0
	
        addi $t1,$t1,-1 # i--
	
        j array_input   # goto array_input, end of while loop

        passpara:
        # bin_count(A, A_count, size)
        add $a0,$s2,$zero # $a0 is base address of A_count[]
        add $a1,$s0,$zero # $a1 is the base address of A[]
        add $a2,$s1,$zero # $a2 is the size of the A[]
        jal bin_count
	
        # cout << "Original array:"
        la $a0, OrignalMsg
        addi $v0, $zero, 4
        syscall
        # arrayPrint(A, size)
        add $a0,$s0,$zero 
        add $a1,$s1,$zero
        jal arrayPrint
        # cout << "\nBin count output:"
        la $a0, CountMsg
        addi $v0, $zero, 4
        syscall
        # arrayPrint(A_count, max_range)
        add $a0,$s2,$zero
        add $a1,$s3,$zero
        add $a1,$a1,1
        jal countPrint
        # return
        exit:
        addi $v0, $zero, 10 
        syscall
	
# This function counts the frequencies of each integer in A[]
# the results are stored in A_count[]. 
# after running the function, A_count[i] is supposed to be holding the frequency of integer i in the array A[]
# Assume the following :
# base address of A_count[] is in $a0
# the base address of   A[] is in $a1
# the size of           A[] is in $a2
# preserve registers as needed
bin_count:
#TODO below
	addi $t5,$zero,0 # $t5 = 0, iterator i
	add $t6,$a0,$zero # $t6 = start addr of A_count[]
	add $t7,$a1,$zero # $t7 = start addr of A[]

	Loop1:
	slt $t4, $t5, $a2 # while( i < size)
	beq $t4, $zero, L7
	
	sll $t2,$t5,2
	add $t2,$t2,$t7
	lw $t2, 0($t2) # $t2 = A[i]
	
	add $t0, $t2, $zero #$t0 = $t2
	sll $t4, $t0, 2
	add $t4,$t4,$t6 # $t4 = i*4 + base of A in $t6, addr of A_count[i]
	lw $t0, 0($t4)
	addi $t0, $t0, 1 #$t0 = $t0 + 1
	sw $t0, 0($t4) #put updated word back  in array
	
	addi $t5, $t5, 1
	j Loop1
	
	
	
	L7:
	
#TODO Above			
jr $ra	# return from bin_count()



# Procedure arrayPrint
# Prints array content on the screen
arrayPrint:
        addi $t1,$zero,0 # $t1 = 0, iterator i
        add $t3,$a0,$zero # $t3 = start addr of array
	
        Loop2:
        slt $t2,$t1,$a1 # while ( i < size)
        beq $t2,$zero,L3
	
        sll $t2,$t1,2
        add $t2,$t2,$t3
        lw $t2,0($t2) # $t2 = array[i]
	
        add $a0,$t2,$zero # cout << array[i]
        addi $v0, $zero, 1
        syscall
	
        la $a0,space # cout << ' '
        addi $v0, $zero, 4
        syscall 
	
        addi $t1,$t1,1 # i++
        j Loop2
	
        L3:	        
        jr    $ra      # return

	
# This function prints count results on the screen
# $a0 holding the base address of A_count[]
# $a1 holding the max_range
countPrint:
        addi $t1,$zero,0
        add $t3,$a0,$zero  
	
        readA_count:
        slt $t2,$t1,$a1
        beq $t2,$zero,exitCountPrint
	
        sll $t2,$t1,2
        add $t2,$t2,$t3
        lw $t2,0($t2) # $t2<-array[i]
	
	
        beq $t2,$zero,noOutput #frequency 0, do not output it
	
	
        # print part1
        la $a0, OutputCountMsg1
        addi $v0, $zero, 4
        syscall
        # print index	
        add $a0,$t1,$zero
        addi $v0, $zero, 1
        syscall
        # print part2
        la $a0, OutputCountMsg2
        addi $v0, $zero, 4
        syscall
	
        add $a0,$t2,$zero
        addi $v0, $zero, 1
        syscall
	
        # Print a space to separate numbers
        la $a0,space
        addi $v0, $zero, 4
        syscall 
	
        noOutput:

        addi $t1,$t1,1	
        j readA_count
	
        exitCountPrint:	        
        jr    $ra      # return
