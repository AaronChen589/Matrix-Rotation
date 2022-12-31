

## Part 1 -- Initialize Data Structure
This function takes two arguments -- a string filename and the address of a data structure buffer. The function will read the content in filename, parse it and store the contents in buffer. The contents in buffer should be in the format defined for the data structure above. So, the first two elements should be the no. of rows and columns of a matrix and the remaining elements should be the integers of the matrix. One way to do this is to read the file one character at a time, and store them in the buffer as integers in appropriate positions.

If the file is read without any errors and the buffer is initialized properly, then the function should return 1 in $v0.

The function should return -1 in $v0 if an error occurs during initialization. When this happens the buffer data structure should remain unchanged. You should assume the buffer contains all zeros before initialization. Initialization errors can occur due to the following reasons:

File I/O error.
The first two lines are not [1-10].
The file has more than X lines (excluding the first two lines), where X is the no. of rows in the first line.
The file has more than Y columns (excluding the first two lines), where Y is the no. of columns in the second line.
Lines 3 and after have non-numeric characters.
Numbers in lines 3 and after (except the last number) do not end with exactly one whitespace

## Part 2 -- Write Buffer To File
This function takes two arguments -- a string filename and the address of the buffer data structure (as defined above). It should write the data in buffer to the file in filename. 
The function returns the no. of characters written to the file in register $v0 and -1 if there is an error during writing the file.


## Part 3 -- Rotate Clockwise By 90/180/270
This function takes two arguments -- the address of the buffer data structure and a string filename. It rotates the matrix in buffer clockwise by 90/180/270 degrees and writes it to filename. Note: 90/180/270 are all unique functions and apart of a single function.

## Part 4 -- Mirroring
This function takes two arguments -- the address of the buffer data structure and a string filename. It creates a mirror of the matrix in buffer writes it to filename.

## Part 5 -- Duplicates
This function takes the data structure buffer as an argument. Assume that the matrix in buffer contains only binary values 0 and 1. The function checks to see if the matrix has any duplicate rows. If a duplicate row exists in the matrix then the function returns 1 in $v0 and the index (starting at 1) of the first duplicate row in $v1. If the matrix has no duplicate rows then the function returns -1 in $v0 and 0 in $v1

## Note For Formatting Text File for Part 2
The lines in the file have the following format:
The first line indicates the no. of rows in a two-dimensional (2D) matrix. It must be an integer [1-10].
The second line indicates the no. of columns in a 2D matrix. It must be an integer [1-10].
The subsequent lines represent numbers in a matrix. The numbers are positive integers separated by a whitespace.
Each line represents a row in the matrix. Each line ends with a terminating character/s. On Windows, line endings are terminated with a combination of carriage return (\r) and newline (\n) characters, also referred to as CR/LF.




