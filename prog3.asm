; Adam Weld
; Program 3
; Number Analizer and Histogram
;
      bdos     equ    5         ; CP/M function call address
      boot     equ    0         ; address to get back to CP/M
      conin    equ    1         ; keyboard read function number
      conout   equ    2         ; console output function number
      sprint   equ    9         ; string print function number
      cr       equ    0Dh       ; value of ASCII code of <CR>
      lf       equ    0Ah       ; value of ASCII code of line feed


      org   100h                ; assembler start
      lxi   sp,sp0              ; initialize stack pointer
      mvi   c,sprint            ; set CP/M register to sprint output 
      mvi   b,10                ; set counter b to 10
      lxi   h,n0                ; load address of buffer
      mvi   a,0                 ; load 0 to A, for clearing buffer
clr:  mov   m,a                 ; loop start: zero each place in buffer
      inx   h                   ; increment mem address
      dcr   b                   ; decrement counter
      jnz   clr                 ; loop if counter =/= 0
      lxi   d,m0                ; load address of message 0
      call  bdos                ; print message
      call  inpt                ; take user input
      lxi   d,m1                ; load address of message 1
      call  bdos                ; print message
      call  hist                ; print histogram output
      lxi   d,m2                ; load address of message 2
      call  bdos                ; print message
      jmp   boot                ; end program


; input subroutine
; takes user input numbers, ignores other characters
; input: keyboard [0-9]
; output: saves correct values in buffer n0
; destroys: PSW, BC, DE, HL
; stack size: 10

inpt: push  psw                 ; push destroyed registers
      push  b
      push  d
      push  h
      lxi   d,0                 ; zero DE pair
      mvi   c,conin             ; set CP/M register for input
ir0:  call  bdos                ; loop start: take input character
      cpi   cr                  ; check if CR
      jz    idn                 ; if CR jump to subroutine done
      cpi   30h                 ; these 4 lines check if user has entered a number
      jc    ierr
      cpi   3Ah
      jnc   ierr   
      sui   '0'                 ; convert ASCII input to number
      mov   e,a                 ; move number to E register
      lxi   h,n0                ; load buffer start address
      dad   d                   ; add DE pair to HL, so we have the correct buffer address
      mov   a,m                 ; these three lines increment memory value
      inr   a
      mov   m,a       
      jmp   ir0                 ; loop back
ierr: mvi   c,conout            ; error handling: set CP/M for character output
      mvi   e,8h                ; move BACKSPACE char to E register 
      call  bdos                ; execute BACKSPACE
      mvi   e,' '               ; print SPACE over error character 
      call  bdos                
      mvi   e,8h                ; execute another BACKSPACE
      call  bdos
      mvi   c,conin             ; set CP/M back to character input
      jmp   ir0                 ; jump back to input loop
idn:  pop   h
      pop   d
      pop   b
      pop   psw                 ; pop destroyed registers
      ret
      

; histogram subrouting
; prints histogram from frequency of numbers in buffer
; input: buffer n0
; output: prints message on screen
; destroys: PSW, BC, HL
; stack size: 8

hist: push  psw                 ; push destroyed registers
      push  b
      push  h
      mvi   b,'0'               ; load 0 char to b - this is the value of current hist line
      mvi   c,conout            ; set CP/M for character out
      lxi   h,n0                ; load n0 buffer address to h
hr0:  mvi   e,lf                ; print line feed
      call  bdos
      mvi   e,cr                ; print character return
      call  bdos  
      mov   e,b                 ; print histogram line value
      call  bdos
      mvi   e,':'               ; print semicolon 
      call  bdos
      mvi   e,' '               ; print space 
      call  bdos
      mvi   e,'X'               ; line filler character loaded to E register 
      mov   a,m                 ; load count value
      cpi   0                   ; check if count is 0
      jz    hr2                 ; if so , jump to hr2
hr1:  call  bdos                ; loop start: print filler character
      dcr   a                   ; decrement value counter
      jnz   hr1                 
hr2:  inx   h                   ; increment address and ASCII line value
      inr   b
      mov   a,b                 ; load next value to A register 
      cpi   3Ah                 ; check if B is larger than 10, signifying end of histogram
      jnz   hr0
hdn:  pop 	h
      pop   b
			pop 	psw			            ; pop destroyed registers
			ret					              ; return



m0:   db    'The Number Analizer Mk 3.14159'
      db    cr,lf,'you may enter any number of numbers [0,9]'
      db    cr,lf,'gimme those digits: $'
m1:   db    cr,lf,'numbers got straight analized:',lf,cr,'$'
m2:   db    cr,lf,lf,'thank you for playing!$'
n0:   ds    10                  ; give space for 10 values
      ds    20                  ; give space for stack
			sp0 	equ $		            ; stack address
			end					              ; ends assembler
