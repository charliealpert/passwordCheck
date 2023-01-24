# Written by: Charlie Alpert
# Purpose: Checks whether user passcode is a valid passcode that contains one lowercase letter, one capital letter, 
# one number, and one special character while being between 12 and 50 characters.


 		.include "SysCalls.asm"		
		.data
inputPrint: 	.asciiz	"\nEnter a passcode: "
validPrint: 	.asciiz	"\nValid Passcode!\n"
invalidPrint: 	.asciiz	"\nInvalid Passcode!\n\n"

# making size 2 larger than passcode max length of passcode to indicate too many values enterered
		.eqv	passSize	52 	
passcode:	.space	passSize

		.text
		
# a0: pointer to passcode
# t0: each byte of passcode
# t1: passcode size		
# t2: lowercase count
# t3: capital count
# t4: number count
# t5: special char count
# t6: indicates invalid character (0 = valid; 1 = invalid)	
		
		
main:		li	$t1, 0			# t1: length of passcode 
		li	$t2, 0			# t2: lowercase count
		li	$t3, 0			# t3: capital count
		li	$t4, 0			# t4: number count
		li	$t5, 0			# t5: special char count
		li	$t6, 0			# t6: indicates invalid character


		# print input message
		la 	$a0, inputPrint		# input message
		li 	$v0, SysPrintString	# call to print
		syscall		
		
		# read in passcode
		la 	$a0, passcode		# load in variable
		li 	$a1, passSize		# length of string
		li 	$v0, SysReadString	# reads in file 
		syscall 
		
		# load passcode into a0
		la	$a0, passcode		# a0 pointer to passcode
		lbu	$t0, 0($a0)		# load first character
		# don't increment t1 (length) since newline will increment 1 extra time in checkChar
		
		bne	$t0, '\n', checkChar	# call to check each character in passcode
		
		# exit program
		li 	$v0, SysExit		# call to exit
		syscall 
					
									
# loads bytes and calls to check valid characters	
checkChar:	# first character already loaded
		beq	$t0, '\n', validate	# go to validate once newline is found	

		jal	lowerCase		# check what type of character t0 is
		bnez 	$t6, invalidPass	# non valid character type indicated
		
		addi	$a0, $a0, 1		# increment $a0 pointer for next char
		lbu	$t0, 0($a0)		# next byte in passcode
		addi	$t1, $t1, 1		# increment size

		b checkChar	


# counts lower case letters in passcode
lowerCase:	bgt	$t0, 'z', invalidChar	# value is extraneous if greater than z (ascii > 122)
		blt	$t0, 'a', upperCase	# value is not lowercase (ascii < 97)
		# otherwise lowercase
		addi	$t2, $t2, 1		# value is lower case increment lowercase count
		jr 	$ra			# return to checkChar
		
# counts capitals in passcode		
upperCase:	bgt	$t0, 'Z', specialChar	# value is not capital (ascii > 90)
		blt	$t0, 'A', numbers	# value is not capital (ascii < 65)
		# otherwise captial
		addi	$t3, $t3, 1		# value is capital increment capital count
		jr 	$ra			# return to checkChar


# counts numbers in passcode				
numbers:	bgt	$t0, '9', specialChar	# value is not a number (ascii > 57)
		blt	$t0, '0', specialChar	# value is not a number (ascii < 48)
		# otherwise number
		addi	$t4, $t4, 1		# value is number increment number count
		jr 	$ra			# return to checkChar

					
# counts special characters in passcode																
specialChar:	# check whether character is one of the special characters
		beq	$t0, '!', validSpecial	# value is a special character (ascii = 33)
		blt	$t0, '#', invalidChar	# value is not a special character (ascii < 35; excluding 33)
		
		# apostrophe is at 39 (using \' since ' alone doesn't work)
		beq	$t0, '\'', invalidChar	# value is not a special character (ascii = 39) 
		ble	$t0, ')', validSpecial	# ascii between 35-41 (excluding 39)
		
		beq	$t0, ',', validSpecial	# value is a special character (ascii = 44)
		beq	$t0, '.', validSpecial	# value is a special character (ascii = 46)
		beq	$t0, ':', validSpecial	# value is a special character (ascii = 58)
		beq	$t0, ';', validSpecial	# value is a special character (ascii = 59)
		beq	$t0, '@', validSpecial	# value is a special character (ascii = 64)
		beq	$t0, '[', validSpecial	# value is a special character (ascii = 91)
		beq	$t0, '^', validSpecial	# value is a special character (ascii = 93)
		beq 	$t0, ']', validSpecial	# value is a special character (ascii = 94)
	
		b invalidChar			# anything else is invalid
				
		
# indicates valid special character
validSpecial:	addi	$t5, $t5, 1		# value is specialChar increment special count
		jr 	$ra			# return to checkChar


# indicates invalid value was found
invalidChar:	addi	$t6, $t6, 1		# increment invalid character
		jr	$ra			# return to checkChar
		

# checks to make sure length is correct and includes at least 1 of every character
validate:	blt	$t1, 12, invalidPass	# check if size is too small
		bgt	$t1, 50, invalidPass	# check if size is too large
		blez  	$t2, invalidPass 	# check if at least one lowercase letter
		blez 	$t3, invalidPass 	# check if at least one capital letter
		blez 	$t4, invalidPass 	# check if at least one number
		blez 	$t5, invalidPass 	# check if at least one special character
		
		# print valid passcode message
		la 	$a0, validPrint		# valid passcode message
		li 	$v0, SysPrintString	# call to print
		syscall	
		b main				# repeat to ask for new passcode
	
			
# print invalid passcode message					
invalidPass:	la 	$a0, invalidPrint	# invalid passcode message	
		li 	$v0, SysPrintString	# call to print
		syscall	
		b main				# repeat to ask for new passcode

