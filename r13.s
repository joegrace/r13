SECTION	.data
	argumentsInvalidMsg	db	`     :Invalid number of arguments passed. Need to pass one\n`, 10
	argumentsInvalidMsgSize	equ	$-argumentsInvalidMsg

	startingMsg		db	"Starting Conversion", 10
	startingMsgSize		equ	$-startingMsg

	alphabetUc		db 	"ABCDEFGHIJKLMNOPQRSTUVWXYZ", 10
	alphabetUcSize		equ	$-alphabetUc

	alphabetLc		db	"abcdefghijklmnopqrstuvwxyz", 10
	alphabetLcSize		equ	$-alphabetLc
	
	arg1			db 500
	result			db 500

section .text
global _start


	
;;; Main entry point
_start:
	nop

	push rbp
	mov rbp, rsp

	;; Put the argument in rcx and then to memory lcoation arg1
	mov rcx, [rbp+24]	; First arg at that location on the stack
	mov [arg1], rcx

	;; Lets add a line return to the string as well
	mov r9, [arg1]
	call AddLineReturn
	mov [arg1], r8
	
	mov rax, 1        			; write
	mov rdi, 1        			;   STDOUT_FILENO
	mov rsi, [arg1]				; String to write

	;; We need to find the length of the string pointed to by [rbp+24]
	mov r9, rsi
	call GetStringLength
	
	mov rdx, r8
	syscall           			; execute

	call CheckArguments

	;; Now we have the appropriate string in [arg1] Lets convert her now
	call ConvertToR13
	
	;; Exit
	call Exit


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Methods and stuff here
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Exits
Exit:
	mov rax, 60
	mov rdi, 0
	syscall
	

;;; Check arguments
CheckArguments:
	cmp byte[rbp+8], 2
	jne DisplayArgumentsError

	ret

;;; Display arguments error
DisplayArgumentsError:	
	mov rax, 1
	mov rdi, 1
	mov rsi, argumentsInvalidMsg
	mov rdx, argumentsInvalidMsgSize

	syscall
	call Exit	

;;; 
;;; Find string length. This will loop through a string
;;; until we get to a 0 and then will return the length
;;;
;;; Takes the string in r9.
;;; Returns the length in r8.
GetStringLength:
	push rax
	mov rax, r9		; Set rax to string to iterate through
	xor r8, r8		; Set r8 to zero to increment

	;; The string is in r9, we need to loop through this until we get
	;; to a 0
	lengthloop:		; Loop for iterating each chracter
	add rax, 1		; Check next character
	inc r8			; r8 houses the number of caracters, so increment each iteration
	
	cmp [rax], byte 0
	jnz lengthloop		; Loop back to loop if rax doesn't equal a zero. rax is the current char

	
	pop rax
	ret

;;; 
;;; This is the main conversion routine that converts from
;;; Standard ASCII to ROT13
;;; String to convert is in [arg1]
;;; Result is going to go in [result]
;;;
ConvertToR13:
	push rax

	;; We need to loop through the string, start at 0
	xor rax, rax
	
	
	pop rax
	ret



;;;
;;; This adds a line return to a string
;;; Takes in string in r9
;;; Returns new one in r8
;;;
AddLineReturn:
	push rax
	mov rax, r9		; Set rax to string to iterate through
	xor r8, r8		; Set r8 to zero to increment
	xor r10, r10
	
	;; The string is in r9, we need to loop through this until we get
	;; to a 0
	lrloop:			; Loop for iterating each chracter
	add rax, 1		; Check next character
	inc r10
	
	cmp [rax], byte 0
	jnz lrloop		; Loop back to loop if rax doesn't equal a zero. rax is the current char

	
	;; Now we are at the end of the string add a 0xA and a 0xD then a 0
	mov [rax], byte 0xA
	mov [rax+1], byte 0xD
	mov [rax+2], byte 0

	;; Add two to r10  and then the string length
	
	sub rax, r10

	
	mov r8, rax
	
	pop rax
	ret

