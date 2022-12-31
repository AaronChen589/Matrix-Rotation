######### Aaron Chen ##########


.text
.globl initialize

# This function reads from a txt file and stores it in buffer

initialize: 
addi $sp, $sp, -44
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 12($sp)
sw $s4, 16($sp)
sw $s5, 20($sp)
sw $s6, 24($sp)
sw $s7, 28($sp)
sw $ra, 32($sp)
sw $a0, 36($sp)
sw $a1, 40($sp)
# open the file
move $s7, $a1 # $s7 = $a1(buffer address)
li $a1, 0 # $a1 = 0, we want to read the file
li $a2, 0 # $a2 = 0, ignored
li $v0, 13 # $v0 = 13 (required to open file)
syscall 
# read from the file (file descriptor/pointer is stored in $v0) 
move $a0, $v0 # $a0 = file pointer
move $s0, $v0 # $s0 = file pointer
move $a1, $s7 # make $a1 = buffer address again
li $a2, 1 # read one character at a time to the buffer
# we first syscall 14 to get the number of rows and columns 
# we account for whitespace, newline, and carriage return 
li $t2, '1' #$t2 = '1'
li $t3, '9' #$t3 = '9'
li $t4, '0'
li $t5, 10 # $t5 = 10
li $t6, 0 # sum for # of rows
li $t7, 48 # $s2 = 48
li $t8, 10 # $t8 = newline
li $s1, 13 # $s1 = carriage return
li $v0, 14 # reads the number of rows 
syscall
lb $t0, 0($a1) # $t0 = character that was read (symbol version of the decimal)
blt $t0, $t2, IncorrectMatrix # if $t0 < $t2('1'), we jump to error
bgt $t0, $t3, IncorrectMatrix # if $t0 > $t3('9'), we jump to error
# now we know the thing we read is between '1' and '9', so we need to account for 10 
bne $t0, $t2, DoneFindingRow # if $t0 != $t2('1'), we know its [2,9] and jump
# 0therwise, we need know if it's 1, 10 or greater
sub $t0, $t0, $t7 # $t0 = $t0 - 48, get decimal equivalent
move $t6, $t0 # $t6 = $t0 (1)
li $v0, 14 # reads the next value after number of rows argument 
syscall
lb $t0, 0($a1) # $t0 = next character that was read (symbol version of the decimal
# case 1, next value = 0, we know its 10 (return 10) ***
# case 2, white space, carriage, or newline ( return original value)
# case 3, others (return error)
beq $t0, $t4, RowIsTen # if $t0(next value) = $t4(0), we know the number of rows = 10
beq $t0, $s1, DoneFindingRow2 # if next value is carriage return, we found the # of rows 
beq $t0, $t8, DoneFindingRow2 # if next value is newline, we found the # of rows
# otherwise, we know the argument is > 10 and throw error
j IncorrectMatrix
RowIsTen: #$t6 = $t0
mul $t6, $t6, $t5 # $t6 = $t6 * $t5(10) # $t6 = # of rows (which is 10)
j row
DoneFindingRow:  
sub $t0, $t0, $t7 # $t0 = $t0 - 48, get decimal equivalent
move $t6, $t0 # $t6 = $t0
j row
DoneFindingRow2: 
# we want to keep $t6 (# of rows) as it is 
row: 
# check to make sure we read past all of the 
li $v0, 14 # reads past carriage returns and newlines till $t0 is neither ($t0 = # of columns/second argument)
syscall
lb $t0, 0($a1)
beq $t0, $s1, row # if next value is carriage return, we syscall 14 to read past it
# otherwise we check to see if it is a newline character
beq $t0, $t8, row # if next value is newline, we syscall 14 to read past it
# otherwise, we know the value isnt newline or carriage return
NonRow:
li $t9, 0 # sum for # of columns
lb $t0, 0($a1)  # load in $t0 = second argument
blt $t0, $t2, IncorrectMatrix # if $t0 < $t2('1'), we jump to error
bgt $t0, $t3, IncorrectMatrix # if $t0 > $t3('9'), we jump to error
# now we know the thing we read is between '1' and '9', so we need to account for 10 
bne $t0, $t2, DoneFindingColumn # if $t0 != $t2('1'), we know its [2,9] and jump
# 0therwise, we need know if it's 1, 10 or greater
sub $t0, $t0, $t7 # $t0 = $t0 - 48, get decimal equivalent
move $t9, $t0 # $t9 = $t0
li $v0, 14 # reads next value
syscall
lb $t0, 0($a1) # $t0 = next character that was read (symbol version of the decimal
# case 1, next value = 0, we know its 10 (return 10) ***
# case 2, white space, carriage, or newline ( return original value)
# case 3, others (return error)
beq $t0, $t4, ColumnIsTen # if $t0(next value) = $t4(0), we know the number of rows = 10
beq $t0, $s1, DoneFindingColumn2 # if next value is carriage return, we found the # of rows 
beq $t0, $t8, DoneFindingColumn2 # if next value is newline, we found the # of rows
# otherwise, we know the argument is > 10 and throw error
j IncorrectMatrix
ColumnIsTen: #$t6 = $t0
mul $t9, $t9, $t5 # $t9 = $t9 * $t5(10) # $t6 = # of rows (which is 10)
j column
DoneFindingColumn:  
sub $t0, $t0, $t7 # $t0 = $t0 - 48, get decimal equivalent
move $t9, $t0 # $t9 = $t0
j column # t9 = # of columns
DoneFindingColumn2: 
# we keep $t9 as it is (t9 = # of rows)
column: 
# check to make sure we read past all of the 
li $v0, 14 # reads past carriage returns and newlines till $t0 is neither ($t0 = # of columns/second argument)
syscall
lb $t0, 0($a1)
beq $t0, $s1, column # if next value is carriage return, we syscall 14 to read past it
# otherwise, check to see if its newline
beq $t0, $t8, column # if next value is newline, we syscall 14 to read past it
# otherwise, we know $t0 not newline or carriage return, we need to make sure if it's length

li $t2, 0 # $t2 = 0 (counter for # of elements read into the buffer )
li $t3, 10 # $t3 = newline
li $t4, 13 # $t4 = carriage return
li $t5, 32 # $t5 = white space
li $t7, 1 #$t7 = 1 / row counter 
li $t8, 0 #$t8 = 0 / column counter
li $s1, 48 # $s1 = 48
li $s2, '0' # $s2 = '0'
li $s3, '9' # $s3 = '9'
addi $t0, $t0, -48 # $t0 = decimal equivalent
IntegerLengthReader1:
li $v0, 14 # $v0 = 14 
syscall  # read the next character of the file
lb $s4, 0($a1) # load the read character into $s4
#case 1, the next input is whitespace, carriage return or new line character, we jump out of loop
#case 2, the next input is a number between [0-9], we lb the next character and add that to current char * 10
beq  $s4, $t3, ThirdArgDone  # if $s4 = $t3(new line char), we know the digit ended and jump.
#Otherwise, we continue
beq $s4, $t4, ThirdArgDone # if $s4 = $t4(carriage return char), we know the digit ended and jump
 # otherwise, we continue
beq $s4, $t5, ThirdArgDone # if $s4 = $t5(white space char), we know the digit ended and jump
 # otherwise, we continue
blt $s4, $s2, IncorrectMatrix # if $s4 < $s2('0'), we know it isn't an appropriate character and jump
bgt $s4, $s3, IncorrectMatrix # if $s4 > $s3('9'), we know it isn't an appropriate character and jump
# now we know the next character ($s7) is a positive integer and thus, concatonate $t2 and $s7
sub $s4, $s4, $s1 # $s7 = $s7 - $s1 (obtain the correct dec value)
li $s5, 10 # $s5 = 10
mul $t0, $t0, $s5 # $t0 = $t0 * 10
add $t0, $t0, $s4 # $t0 = $t0 + $s4
j IntegerLengthReader1

ThirdArgDone:
addi $t2, $t2, 1 # one element has been read in
addi $t8, $t8, 1# column # is incremented cuz of one elementing being read in
# $t6 = # of rows, #t9 = # of columns, # $s7 $a1 = buffer address
sw $t6, 0($a1) # store # of rows
sw $t9, 4($a1) # store # of columns
sw $t0, 8($a1) # store the $t0 we received 
addi $a1, $a1, 12 # move this pointer to next read open index 	
mul $t1, $t6, $t9 # total # of elements = # of rows * # of columns (excluding the first two argument 
# and their carriage/whitespace/newline characters)

ReadingFromFileToBuffer: 
# now we are at the start of the third row, i.e. the beginning of the matrix
# and must iterate through the txt file's matrix and appending it to the buffer
beq $t1, $t2,DoneReading # if $t1(total # of elements = $t2( # of elements read, we jump)
li $v0, 14 # $v0 = 14 
syscall
lb $t0, 0($a1) # $t0 = the character that was just read in
bne $t0, $t3, NotANewLine #if the char read wasn't a newline, we continue.
#Otherwise, we increment row counter and check column count condition cuz its going to next line
addi $t7, $t7, 1 # row counter is incremented by 1
bne $t8, $t9, IncorrectMatrix # if $t3(counter for elements in each row) != $s4(# of columns) we throw jump
# else, we continue because it satisfy the requirement
li $t8, 0 #reset column counter to 0 (required to check if each row has same amount of elements)
j NotAnElement # otherwise, we dont want to apppend it to the buffer
NotANewLine: 
bne $t0, $t4, NotACarriage # if the char read wasn't a carriage return
j NotAnElement # otherwise, we dont want to apppend it to the buffer
NotACarriage:
bne $t0, $t5, NotAWhiteSpace # if the char read wasn't a white space
j NotAnElement # otherwise, we dont want to apppend it to the buffer
NotAWhiteSpace:
# if it's neither newline, carriage, or whitespace, we check if it's a positive integer (through asciiz)
# since we are reading one digit by a time, we check if the digit is [0-9]
blt $t0, $s2, IncorrectMatrix # if $t0 < $s2('0'), we know it isn't an appropriate character and jump
bgt $t0, $s3, IncorrectMatrix # if $t0 > $s3('9'), we know it isn't an appropriate character and jump
sub $t0, $t0, $s1 # $t0 = $t0 - $s1 (obtain the correct dec value)
# now we know it's a positive integer, we have to check it's length by reading next character
IntegerLengthReader:
li $v0, 14 # $v0 = 14 
syscall  # read the next character of the file
beqz $v0, read # if $v0 = 0 , we know $v0 = 0 or -1, in which we are done looping

lb $s4, 0($a1) # load the read character into $s4
#case 1, the next input is whitespace, carriage return or new line character, we jump out of loop
#case 2, the next input is a number between [0-9], we lb the next character and add that to current char * 10
beq  $s4, $t3, IsNewLine  # if $s4 = $t3(new line char), we know the digit ended and jump.
#Otherwise, we continue
beq $s4, $t4, IsCarriage # if $s4 = $t4(carriage return char), we know the digit ended and jump
 # otherwise, we continue
beq $s4, $t5, IsWhitespace # if $s4 = $t5(white space char), we know the digit ended and jump
 # otherwise, we continue
blt $s4, $s2, IncorrectMatrix # if $s4 < $s2('0'), we know it isn't an appropriate character and jump
bgt $s4, $s3, IncorrectMatrix # if $s4 > $s3('9'), we know it isn't an appropriate character and jump
# now we know the next character ($s7) is a positive integer and thus, concatonate $t2 and $s7
sub $s4, $s4, $s1 # $s7 = $s7 - $s1 (obtain the correct dec value)
li $s5, 10 # $s5 = 10
mul $t0, $t0, $s5 # $t2 = $t2 * 10
add $t0, $t0, $s4 # $t2 = $t2 + $s4
j IntegerLengthReader
IsNewLine: # maybe have a coutner for these???
IsCarriage:
IsWhitespace:
sw $t0, 0($a1) # store this value in $a1
addi $t8, $t8, 1 # increment column count by 1 (it's incrementing for each new element in matrix)
addi $t2, $t2, 1 # increment the # of elements read into the buffer by 1
addi $a1, $a1, 4 # increment by 4 to store the next element of the matrix
NotAnElement: # if it isn't an element, we dont increament the array and overwrite it
j ReadingFromFileToBuffer
DoneReading:
bne $t7, $t6, IncorrectMatrix # if $t7(counter for # of row) != $t6(# of rows in argument) we throw

# else, we continue...
EndingInitizalization: # restore all $s back from the stack
lw $s0, 0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $s3, 12($sp)
lw $s4, 16($sp)
lw $s5, 20($sp)
lw $s6, 24($sp)
lw $s7, 28($sp)
lw $ra, 32($sp)
lw $a0, 36($sp)
lw $a1, 40($sp)
addi $sp, $sp, 44
 jr $ra
IncorrectMatrix: # if an error occurs in initialize function, return -1 in $v0
# also initialize the buffer to have only have 10 by 10 zero matrix +2 for # of rows and # of columns arg
li $v0, -1
# $s7 = address of buffer
li $t0, 102
li $t1, 0 # counter
li $t2, 0
InitializeErrorMatrix:
beq $t1, $t0, FinishingInitializingError # if $t1(row counter) = $t0(100), we jump
sw $t2, 0($s7)
addi $s7, $s7, 4
addi $t1, $t1, 1 # increment $t1 by 1
j InitializeErrorMatrix
FinishingInitializingError:
j EndingInitizalization
read:
sw $t0, 0($a1)
j DoneReading


.globl write_file
write_file: 
addi $sp, $sp, -44
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 12($sp)
sw $s4, 16($sp)
sw $s5, 20($sp)
sw $s6, 24($sp)
sw $s7, 28($sp)
sw $ra, 32($sp)
sw $a0, 36($sp)
sw $a1, 40($sp)
li $s1, 0 # counter for total number of characters read
# open the file that we are going to write to
move $t1, $a1 # $t1 = buffer address
li $a1, 1 # $a1 = 1, we want to write to the file
li $a2, 0 # $a2 = 0, ignored
li $v0, 13 # $v0 = 13 (required to open file)
syscall 
# file descriptor/pointer is stored in $v0
move $s7, $v0 # $s0 = file descriptor of the outputfile
move $a0, $v0 # $a0 = file descriptor of the outputfile
move $a1, $t1 # $a1 = buffer address
li $a2, 1 # $a2 = 1, writing 1 character at a time to the outputfile
li $t2, 48 # $t2 = 48
li $t3, 10 # $t3 = 10
li $t4, '\n'
lb $s2, 0($a1) # load in # of rows
lb $s3, 4($a1) # load in # of columns
move $s5, $s3 # $s5 = # of columns
mul $s2, $s2, $s3 # $s2 = # of rows * # of columns

# hard code the first two arguments
lb $t0, 0($a1) # load in # of rows
beq $t0, $t3, RowTen # if $t0 = $t3(10), we jump 
add $t0, $t0, $t2 # $t0 = $t0 + 48 make it it's asciiz equivalent
sw $t0, 0($a1) # store asciiz back in $a1
li $v0, 15 # read it 
syscall 
addi $s1, $s1, 1 # increment total number of characters read by 1
RowMadeTen:
sw $t4, 0($a1)# store '\n' in the same address 
li $v0, 15 # read it 
syscall 
addi $s1, $s1, 1 # increment total number of characters read by 1
addi $a1, $a1, 4 # $a1 is incremented by 4 to go to next value
lb $t0, 0($a1) # load in # of columns
beq $t0, $t3, ColumnTen # if $t0 = $t3(10), we jump 
add $t0, $t0, $t2 # $t0 = $t0 + 48 make it it's asciiz equivalent
sw $t0, 0($a1) # store asciiz back in $a1
li $v0, 15 # read it 
syscall 
addi $s1, $s1, 1 # increment total number of characters read by 1
ColumnMadeTen:
sw $t4, 0($a1)# store '\n' in the same address 
li $v0, 15 # read it 
syscall 
addi $s1, $s1, 1 # increment total number of characters read by 1
addi $a1, $a1, 4 # $a1 is incremented by 4 to go to next value
j DoneTransferringArguments
RowTen:
li $t6, '1'
li $t7, '0'
sw $t6, 0($a1)
li $v0, 15 # read the 1
syscall
addi $s1, $s1, 1 # increment total number of characters read by 1
sw $t7, 0($a1)
li $v0, 15 # read the 0
syscall
addi $s1, $s1, 1 # increment total number of characters read by 1
j RowMadeTen
ColumnTen:
li $t6, '1'
li $t7, '0'
sw $t6, 0($a1)
li $v0, 15 # read the 1
syscall
addi $s1, $s1, 1 # increment total number of characters read by 1
sw $t7, 0($a1)
li $v0, 15 # read the 0
syscall
addi $s1, $s1, 1 # increment total number of characters read by 1
j ColumnMadeTen
DoneTransferringArguments:

# now we read the matrix ($a1 is now pointing towards the first element of the matrix
# $s2 = total # of elements in matrix excluding the first two arguments
li $t2, 48 # $t2 = 48
li $t4, 0 # $t4 = 0 (counter)
li $t5, 10 # $t5 = 10
li $s3, ' ' # $s3 = ' '
li $s4, '\n' # $s4 = '\n'
# $s5 = # of columns
li $s6, 0 # $s6 = counter for elements in each row
move $t6, $a1 # $t6 = address of $a1 (which is pointing at the first element of the matrix)
ConvertToAsciiz:
bne $s5, $s6, UnequalColumns# if $s5(# of columns) != $s6 (counter for # of elements per row), we jump
addi $sp, $sp, -4
sw $s4, 0($sp) # store newline in $sp
move $a1, $sp # *******the file will now read from the stack ***********
li $v0, 15
syscall 
addi $s1, $s1, 1 # increment total number of characters read by 1
addi $sp, $sp, 4
li $s6, 0 # reset counter to 0
UnequalColumns:
beq $s2, $t4, DoneConverting# if $s2(total number of elements) = $t4(counter), we jump *** need to change afterwards
lw $t1, 0($t6) # load in current value of $a1
li $t9, 0 #$t9 = counter for # of modulo 10
IteratingModularTen:
div $t1, $t5 # $t1 / $t5(10) 
mfhi $t7 # $t7 = remainder
mflo $t8 # $t8 = quotient
beqz $t8, OneDigit # if $t8(quotient)= 0, we know stop and jump
addi $t9, $t9, 1 # increment the # of times we divided $t1 by 10 by 1
addi $sp, $sp, -4 # allocate space for remainder
sw $t7, 0($sp) # store the value of the remainder into the stack
move $t1, $t8 # $t1 = resulting quotient of the first division
j IteratingModularTen
OneDigit: # after $t1 mod 10 = 0, we store 
# $t1 (first digit) in the stack so we can syscall 15 using the stack in $a1
addi $sp, $sp, -4 
add $t1, $t1, $t2 # make $t1 an aciiz character
sw $t1, 0($sp) # store the first digit of the number into the stack
move $a1, $sp # *******the file will now read from the stack ***********
li $v0, 15
syscall
addi $s1, $s1, 1 # increment total number of characters read by 1
addi $sp, $sp, 4
# $t9 = number of times we did modulo 10
ReadingMultipleDigits:
beqz $t9, DoneReadingMultipleDigits # if $t9 = 0, we are done, 
#otherwise, we loop through stack to get the remainders 
lw $t1, 0($sp) # load in the remainder in $t1 
add $t1, $t1, $t2 # make $t1 an aciiz character
sw $t1, 0($sp) # store it back in the same place
move $a1, $sp # *******the file will now read from the current stack pointer ***********
li $v0, 15 # read from the stack and write to the outfile
syscall
addi $s1, $s1, 1 # increment total number of characters read by 1
addi $sp, $sp, 4
addi $t9, $t9, -1 # deincrement $t9 by 1
j ReadingMultipleDigits
DoneReadingMultipleDigits:
addi $sp, $sp, -4
sw $s3, 0($sp) # $s3 = white space 
li $v0, 15
syscall 
addi $s1, $s1, 1 # increment total number of characters read by 1
addi $sp, $sp, 4
addi $t4, $t4, 1 # increment total element counter by 1
addi $t6, $t6, 4 # increment $t6 to get to next element
addi $s6, $s6, 1 # increment # of elements in current row counter $s6 by 1 
j ConvertToAsciiz
DoneConverting:
move $v0, $s1  # $v0 = $s1 = total # of elements read into the text file
# syscall 16 to close the file
move $a0, $s7 
li $v0, 16
syscall
lw $s0, 0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $s3, 12($sp)
lw $s4, 16($sp)
lw $s5, 20($sp)
lw $s6, 24($sp)
lw $s7, 28($sp)
lw $ra, 32($sp)
lw $a0, 36($sp)
lw $a1, 40($sp)
addi $sp, $sp, 44
 jr $ra
 

.globl rotate_clkws_90
rotate_clkws_90:
addi $sp, $sp, -40
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 12($sp)
sw $s4, 16($sp)
sw $s5, 20($sp)
sw $s6, 24($sp)
sw $ra, 28($sp)
sw $a0, 32($sp)
sw $a1, 36($sp)

# $a0 = buffer address, $a1 = filename
move $s4, $a1 #$ s4  = file name address
move $s5, $a0 # $s5 = buffer address (will be kept as the original state)
move $s6, $a0 # $s6 = buffer address
li $t9, 0 # counter for amount of space allocated from stack
lw $t1, 0($a0) # $t1 = number of rows
addi $a0, $a0, 4 # increment to next element
lw $t2, 0($a0) # $t2 = number of columns
addi $a0, $a0, 4 # increment to next element
li $t3, 0 # $t3 = $t3 = row index
move $t0, $a0 # $t0 = base address(address of the first element in the matrix)
move $t4, $t2 # $t4 = $t2 (column counter)
addi $t4, $t4, -1 # $t4 = j index
move $t5, $t0 # $t5 = base address
li $t6, 4 # $t6 = 4
# reading from buffer to stack from top right column to the bottom and row by row leftward
StoringMatrixInStack:
bltz $t4, DoneStoringToStack # if  $t4(j-index)  0, we finished storing matrix to stack 
li $t3, 0  # $t3 = 0 (reset row index to 0 after incrementing the entire column)
ReadingColumn:
beq $t1, $t3, FinishedReadingColumn  # if $t3(row index)= $t1(# of rows), jump to end of inner loop
mul $t7, $t2, $t3 # $t7 = $t2(number of columns)  $t3(i-index) 
add $t7, $t7, $t4 # $t7 = $t7(number of columns)(i-index) + $t4(j-index)
mul $t7, $t7, $t6 # $t7 = $t6(4)  $t7(number of columns  i-index + j-index)
add $t5, $t5, $t7 # $t5 = Base address + $t7 (4 (number of columns  i-index + j-index) 
lw  $t8, 0($t5) # $t8 = the value of $t5 at that address
addi $sp, $sp, -4 # allocate space in stack
addi $t9, $t9, 1 # increment count for space allocated from stack
sw $t8, 0($sp)
addi $t3, $t3, 1
move $t5, $t0 # $t5 = reset $t5 to the base address 
j ReadingColumn
FinishedReadingColumn: 
addi $t4, $t4, -1 # $t4(decrement j-index by 1)
j StoringMatrixInStack
DoneStoringToStack:
# after we finish storing the buffer into the stack, we want to swap the number of rows and columns
move $t3, $t1 # $t3 = (old)number of rows (counter)
move $t4, $t2 #$t4 = (old)number of columns (counter)
move $t1, $t4 #$t1 = (rotated)number of rows
move $t2, $t3 # $t2 = (rotated)number of columns
#now we've stored the rotated the matrix in stack, we know $sp is pointed towards the most recently added element
# we now want to transfer back all the values from the stack back into the buffer
# we first move the swapped arguments back into the first two indices of the buffer
sw $t1, 0($s6) # store # of rows into buffer address
addi $s6, $s6, 4 # increment to next indices
sw $t2, 0($s6) # store # of columns into buffer address
addi $s6, $s6, 4 # increment to next indices

TransferringFromStackToBuffer:
beqz $t9, DoneTransferringFromStackToBuffer #if $t9 = 0, we are done and jump out
lw $t3, 0($sp) # $t3 = element of the current stack address
sw $t3, 0($s6) # Store $t3 into the buffer
addi $s6, $s6, 4 # increment to next indices
addi $sp, $sp, 4 # deallocate space from the stack decrement to the next element
addi $t9, $t9, -1 # decrement $t9 by 1
j TransferringFromStackToBuffer
DoneTransferringFromStackToBuffer:

# call write_file(char* filename, Buffer* buffer
move $a0, $s4
move $a1, $s5
jal write_file
#move $a0, $s4 # $a0 = $s4 (address of the outfile)
#move $a1, $s5 # $a1 = $s5 (address of buffer at its starting point)
# call write_file(char* filename, Buffer* buffer)
lw $s0, 0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $s3, 12($sp)
lw $s4, 16($sp)
lw $s5, 20($sp)
lw $s6, 24($sp)
lw $ra, 28($sp)
lw $a0, 32($sp)
lw $a1, 36($sp)
addi $sp, $sp, 40
 jr $ra

.globl rotate_clkws_180
rotate_clkws_180:

addi $sp, $sp, -40
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 12($sp)
sw $s4, 16($sp)
sw $s5, 20($sp)
sw $s6, 24($sp)
sw $ra, 28($sp)
sw $a0, 32($sp)
sw $a1, 36($sp)
# $a0 = buffer address, $a1 = filename
move $s4, $a1 #$ s4  = file name address
move $s5, $a0 # $s5 = buffer address (will be kept as the original state)
move $s6, $a0 # $s6 = buffer address
li $t9, 0 # counter for amount of space allocated from stack
lw $t1, 0($a0) # $t1 = number of rows
addi $a0, $a0, 4 # increment to next element
lw $t2, 0($a0) # $t2 = number of columns
addi $a0, $a0, 4 # increment to next element
li $t3, 0 # $t3 = $t3 = row index
move $t0, $a0 # $t0 = base address(address of the first element in the matrix)
li $t4, 0 # $t4 = column index
move $t5, $t0 # $t5 = base address
li $t6, 4 # $t6 = 4
# reading from buffer to stack from row to row, left to right
StoringMatrixInStack180:
beq $t3, $t1, DoneStoringToStack180 # if  $t3(i-index) = $t1 (# of rows), we finished storing matrix to stack 
li $t4, 0  # $t3 = 0 (reset row index to 0 after incrementing the entire row)
ReadingColumn180:
beq $t2, $t4, FinishedReadingColumn180  # if $t4(column index)= $t2(# of columns), jump to end of inner loop
mul $t7, $t2, $t3 # $t7 = $t2(number of columns)  $t3(i-index) 
add $t7, $t7, $t4 # $t7 = $t7(number of columns)(i-index) + $t4(j-index)
mul $t7, $t7, $t6 # $t7 = $t6(4)  $t7(number of columns  i-index + j-index)
add $t5, $t5, $t7 # $t5 = Base address + $t7 (4 (number of columns  i-index + j-index) 
lw  $t8, 0($t5) # $t8 = the value of $t5 at that address
addi $sp, $sp, -4 # allocate space in stack
addi $t9, $t9, 1 # increment count for space allocated from stack
sw $t8, 0($sp)
addi $t4, $t4, 1# increment $t4 by 1
move $t5, $t0 # $t5 = reset $t5 to the base address 
j ReadingColumn180
FinishedReadingColumn180: 
addi $t3, $t3, 1 # $t4(increment i-index by 1)
j StoringMatrixInStack180
DoneStoringToStack180:
# after we finish storing the buffer into the stack, we want to swap the number of rows and columns
# since it's 180 rotation, # of rows and columns stay the same
#now we've stored the rotated the matrix in stack, we know $sp is pointed towards the most recently added element
# we now want to transfer back all the values from the stack back into the buffer
# we first move the swapped arguments back into the first two indices of the buffer
sw $t1, 0($s6) # store # of rows into buffer address
addi $s6, $s6, 4 # increment to next indices
sw $t2, 0($s6) # store # of columns into buffer address
addi $s6, $s6, 4 # increment to next indices
TransferringFromStackToBuffer180:
beqz $t9, DoneTransferringFromStackToBuffer180 #if $t9 = 0, we are done and jump out
lw $t3, 0($sp) # $t3 = element of the current stack address
sw $t3, 0($s6) # Store $t3 into the buffer
addi $s6, $s6, 4 # increment to next indices
addi $sp, $sp, 4 # deallocate space from the stack decrement to the next element
addi $t9, $t9, -1 # decrement $t9 by 1
j TransferringFromStackToBuffer180
DoneTransferringFromStackToBuffer180:
# call write_file(char* filename, Buffer* buffer
move $a0, $s4
move $a1, $s5
jal write_file
#move $a0, $s4 # $a0 = $s4 (address of the outfile)
#move $a1, $s5 # $a1 = $s5 (address of buffer at its starting point)
# call write_file(char* filename, Buffer* buffer)
lw $s0, 0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $s3, 12($sp)
lw $s4, 16($sp)
lw $s5, 20($sp)
lw $s6, 24($sp)
lw $ra, 28($sp)
lw $a0, 32($sp)
lw $a1, 36($sp)
addi $sp, $sp, 40
 jr $ra



.globl rotate_clkws_270
rotate_clkws_270:
addi $sp, $sp, -40
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 12($sp)
sw $s4, 16($sp)
sw $s5, 20($sp)
sw $s6, 24($sp)
sw $ra, 28($sp)
sw $a0, 32($sp)
sw $a1, 36($sp)

# $a0 = buffer address, $a1 = filename
move $s4, $a1 #$ s4  = file name address
move $s5, $a0 # $s5 = buffer address (will be kept as the original state)
move $s6, $a0 # $s6 = buffer address
li $t9, 0 # counter for amount of space allocated from stack
lw $t1, 0($a0) # $t1 = number of rows
addi $a0, $a0, 4 # increment to next element
lw $t2, 0($a0) # $t2 = number of columns
addi $a0, $a0, 4 # increment to next element
move $t3, $t1 # $t3 = $t1 = # of rows
addi $t3, $t3, -1 # $t3 = max row index
move $t0, $a0 # $t0 = base address(address of the first element in the matrix)
li $t4,  0 # $t4 = (column counter)
move $t5, $t0 # $t5 = base address
li $t6, 4 # $t6 = 4
# reading from buffer to stack from top right column to the bottom and row by row leftward
StoringMatrixInStack270:
beq $t2, $t4, DoneStoringToStack270 # if  $t4(j-index) = $t2 (number of columns), we finished storing matrix to stack 
move $t3, $t1 # $t3 = $t1(# of rows)
addi $t3, $t3, -1  # $t3 is reset to max row index after incrementing the entire column
ReadingColumn270:
bltz $t3, FinishedReadingColumn270  # if $t3(row index) < 0, jump to end of inner loop
mul $t7, $t2, $t3 # $t7 = $t2(number of columns)  $t3(i-index) 
add $t7, $t7, $t4 # $t7 = $t7(number of columns)(i-index) + $t4(j-index)
mul $t7, $t7, $t6 # $t7 = $t6(4)  $t7(number of columns  i-index + j-index)
add $t5, $t5, $t7 # $t5 = Base address + $t7 (4 (number of columns  i-index + j-index) 
lw  $t8, 0($t5) # $t8 = the value of $t5 at that address
addi $sp, $sp, -4 # allocate space in stack
addi $t9, $t9, 1 # increment count for space allocated from stack
sw $t8, 0($sp)
addi $t3, $t3, -1 # decrement row by 1
move $t5, $t0 # $t5 = reset $t5 to the base address 
j ReadingColumn270
FinishedReadingColumn270: 
addi $t4, $t4, 1 # $t4(increment j-index by 1)
j StoringMatrixInStack270
DoneStoringToStack270:
# after we finish storing the buffer into the stack, we want to swap the number of rows and columns
move $t3, $t1 # $t3 = (old)number of rows (counter)
move $t4, $t2 #$t4 = (old)number of columns (counter)
move $t1, $t4 #$t1 = (rotated)number of rows
move $t2, $t3 # $t2 = (rotated)number of columns
#now we've stored the rotated the matrix in stack, we know $sp is pointed towards the most recently added element
# we now want to transfer back all the values from the stack back into the buffer
# we first move the swapped arguments back into the first two indices of the buffer
sw $t1, 0($s6) # store # of rows into buffer address
addi $s6, $s6, 4 # increment to next indices
sw $t2, 0($s6) # store # of columns into buffer address
addi $s6, $s6, 4 # increment to next indices

TransferringFromStackToBuffer270:
beqz $t9, DoneTransferringFromStackToBuffer270 #if $t9 = 0, we are done and jump out
lw $t3, 0($sp) # $t3 = element of the current stack address
sw $t3, 0($s6) # Store $t3 into the buffer
addi $s6, $s6, 4 # increment to next indices
addi $sp, $sp, 4 # deallocate space from the stack decrement to the next element
addi $t9, $t9, -1 # decrement $t9 by 1
j TransferringFromStackToBuffer270
DoneTransferringFromStackToBuffer270:

# call write_file(char* filename, Buffer* buffer
move $a0, $s4
move $a1, $s5
jal write_file
#move $a0, $s4 # $a0 = $s4 (address of the outfile)
#move $a1, $s5 # $a1 = $s5 (address of buffer at its starting point)
# call write_file(char* filename, Buffer* buffer)
lw $s0, 0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $s3, 12($sp)
lw $s4, 16($sp)
lw $s5, 20($sp)
lw $s6, 24($sp)
lw $ra, 28($sp)
lw $a0, 32($sp)
lw $a1, 36($sp)
addi $sp, $sp, 40
 jr $ra

.globl mirror
mirror:
addi $sp, $sp, -40
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 12($sp)
sw $s4, 16($sp)
sw $s5, 20($sp)
sw $s6, 24($sp)
sw $ra, 28($sp)
sw $a0, 32($sp)
sw $a1, 36($sp)

# $a0 = buffer address, $a1 = filename
move $s4, $a1 #$ s4  = file name address
move $s5, $a0 # $s5 = buffer address (will be kept as the original state)
move $s6, $a0 # $s6 = buffer address
li $t9, 0 # counter for amount of space allocated from stack
lw $t1, 0($a0) # $t1 = number of rows
addi $a0, $a0, 4 # increment to next element
lw $t2, 0($a0) # $t2 = number of columns
addi $a0, $a0, 4 # increment to next element
move $t3, $t1 # $t3 = $t1 = # of rows
addi $t3, $t3, -1 # $t3 = max row index
move $t0, $a0 # $t0 = base address(address of the first element in the matrix)
li $t4,  0 # $t4 = (column counter)
move $t5, $t0 # $t5 = base address
li $t6, 4 # $t6 = 4
# reading from buffer to stack from top right column to the bottom and row by row leftward
StoringMatrixInStackMirror:
bltz $t3, DoneStoringToStackMirror # if  $t3(i-index)< 0 , we finished storing matrix to stack 
li  $t4, 0 # $t4 is reset to the 0th indices 
ReadingColumnMirror:
beq $t4, $t2  FinishedReadingColumnMirror  # if $t4(j-index) = $t2 (number of columns), jump to end of inner loop
mul $t7, $t2, $t3 # $t7 = $t2(number of columns)  $t3(i-index) 
add $t7, $t7, $t4 # $t7 = $t7(number of columns)(i-index) + $t4(j-index)
mul $t7, $t7, $t6 # $t7 = $t6(4)  $t7(number of columns  i-index + j-index)
add $t5, $t5, $t7 # $t5 = Base address + $t7 (4 (number of columns  i-index + j-index) 
lw  $t8, 0($t5) # $t8 = the value of $t5 at that address
addi $sp, $sp, -4 # allocate space in stack
addi $t9, $t9, 1 # increment count for space allocated from stack
sw $t8, 0($sp)
addi $t4, $t4, 1 # increment column index by 1
move $t5, $t0 # $t5 = reset $t5 to the base address 
j ReadingColumnMirror
FinishedReadingColumnMirror: 
addi $t3, $t3, -1 # $t3(decrement i-index by 1)
j StoringMatrixInStackMirror
DoneStoringToStackMirror:
# after we finish storing the buffer into the stack, 
#we dont want to swap the number of rows and columns because it's mirroring
#now we've stored the rotated the matrix in stack, we know $sp is pointed towards the most recently added element
# we now want to transfer back all the values from the stack back into the buffer
# we first move the swapped arguments back into the first two indices of the buffer
sw $t1, 0($s6) # store # of rows into buffer address
addi $s6, $s6, 4 # increment to next indices
sw $t2, 0($s6) # store # of columns into buffer address
addi $s6, $s6, 4 # increment to next indices

TransferringFromStackToBufferMirror:
beqz $t9, DoneTransferringFromStackToBufferMirror #if $t9 = 0, we are done and jump out
lw $t3, 0($sp) # $t3 = element of the current stack address
sw $t3, 0($s6) # Store $t3 into the buffer
addi $s6, $s6, 4 # increment to next indices
addi $sp, $sp, 4 # deallocate space from the stack decrement to the next element
addi $t9, $t9, -1 # decrement $t9 by 1
j TransferringFromStackToBufferMirror
DoneTransferringFromStackToBufferMirror:

# call write_file(char* filename, Buffer* buffer
move $a0, $s4
move $a1, $s5
jal write_file
#move $a0, $s4 # $a0 = $s4 (address of the outfile)
#move $a1, $s5 # $a1 = $s5 (address of buffer at its starting point)
# call write_file(char* filename, Buffer* buffer)
lw $s0, 0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $s3, 12($sp)
lw $s4, 16($sp)
lw $s5, 20($sp)
lw $s6, 24($sp)
lw $ra, 28($sp)
lw $a0, 32($sp)
lw $a1, 36($sp)
addi $sp, $sp, 40
 jr $ra

.globl duplicate
duplicate:

addi $sp, $sp, -4
sw $s1, 0($sp)




move $t0, $a0 #$t0 = buffer address
lw $t1, 0($t0) # %t1 = number of rows
addi $t0, $t0, 4 # increment to next argument
lw $t2, 0($t0) # $t2 = number of columns
addi $t0, $t0, 4 # increment to next argument
# $t1 = # of rows, $t2 = # of columns
li $t3, 0 # row counter
li $t4, 0 # column counter
li $t5, 0 # $sp counter (counts number of times we allocated 4 bytes)
li $t6, 10 # $t6 = 10
move $t9, $sp # $t9 = the original $sp address
li $s1, 2 # $s1 = 2
IteratingColumn:
beq $t1, $t3, DoneIterating  #if $t1(# of rows) = $t3(row counter), we store the value we obtained to stack
li $t4, 0 # $t4 (column counrer)is reset to 0 
li $t7, 0 # $t7 (sum of row is reset to 0)
IteratingRow:
beq $t2, $t4, StoreRowValueToStack # if $t2(# of columns) = $t4(column counter), we are done iterating through the matrix
lw $t8, 0($t0)  # $t8 = current element of the buffer
mul $t7, $t7, $t6 # $t7 (new sum) = $t7(previous sum) * $t6(10)
mul $t8, $t8, $s1 # $s1 = $t8 * $s1(2)
add $t7, $t7, $t8 # $t7(sum) = $t7 + $t8(latest integer loaded from rhe buffer)
addi $t0, $t0, 4 # load the next element of the buffer
addi $t4, $t4, 1 # increment column by 1
j IteratingRow
StoreRowValueToStack:
# after we finished iterating through an entire row, we want to store that value into the stack
addi $sp, $sp, -4
addi $t5, $t5, 1 # increment $t5 ($sp counter) by 1 
sw $t7, 0($sp) # store $t7(value of the row) in the stack
addi $t3, $t3, 1 # increment row counter by 1
j IteratingColumn 
DoneIterating:

#now we compare the values of the rows to each other
# $t5 = number of elements in stack/ space allocated from stack
# $t9 = original $sp address

addi $t9, $t9, -4 # increment $sp to the first row value element we stored in the stack
move $s1, $t9 # $s1 = pointer for the stack 
move $t4, $t1 # $t4 = number of rows
li $t1, 1 # counter for what row we are currenting comparing the rest of the stack to
li $t2, 1 # $t2 = counter(default = 1 (first row): will indicate which row the duplicate first appears

CompareStackValues:
bgt $t1, $t4, NoDuplicates # if $t1(row counter) > $t4(number of rows), we jump
lw $t0, 0($t9) # loads in the current row sum of the stack
move $s1, $t9 # move the head pointer 
addi $s1, $s1, -4 # compare $s1(pointer) to the next row value
IteratingTheStack:
addi $t2, $t2, 1 # increment $t2 by 1 to show where the current row pointer is 
bgt $t2, $t4, CompareNextStackValue # if $t2(row counter) > $t4(number of rows), we jump
lw $t3, 0($s1)
beq $t0, $t3, Duplicate # if $t0 (current row value)= $t3 (current pointer row value)
# otherwise, we compare the next value
addi $s1, $s1, -4 # compare $t0 to the next row value
j IteratingTheStack
CompareNextStackValue:
addi $t1, $t1, 1 # points to next row we are compareing the stack to
move $t2, $t1 # $t2 points to the next row we are comparing the stack to
addi $t9, $t9, -4 # $t9 increment the main pointer( the one we are compareing stack to) to next element
j CompareStackValues

NoDuplicates:
li $v0, -1

j EndingDuplicate


Duplicate:
li $v0, 0
move $v1, $t2
EndingDuplicate:
li $t0, 0 # counter 
# $t5 = number of elements in stack/ space allocated from stack
RestoreTheStack:

beq $t0, $t5, DoneRestoring
addi $t0, $t0, 1
addi $sp, $sp, 4
j RestoreTheStack
DoneRestoring:


lw $s1, 0($sp)
addi $sp, $sp, 4


 jr $ra
