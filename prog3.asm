; Adam Weld
; Program 2
;
   bdos     equ    5           ; CP/M function call address
   boot     equ    0           ; address to get back to CP/M
   conin    equ    1           ; keyboard read function number
   conout   equ    2           ; console output function number
   sprint   equ    9           ; string print function number
   cr       equ    0Dh         ; value of ASCII code of <CR>
   lf       equ    0Ah         ; value of ASCII code of line feed
;
      org   100h
      lxi   sp,sp0
      mvi   c,sprint
      lxi   d,m0
      call  bdos
      call  inpt
      lxi   d,m1
      call  bdos
      call  hist

; input subroutine
; takes your goddamn inputs
inpt: push  psw
      push  b
      push  h
      mvi   c,conin
ir0:  call  bdos
      cpi   cr
      jz    idn
      sui   '0'
      lxi   h,n0
      dad   a
      mov   a,m
      inr   a
      mov   m,a
      jmp   ir0

idn:  pop   h
      pop   b
      pop   psw
      ret
      

; histogram subrouting
; prints a goddamn histogram
hist: push  psw
      push  b
      push  h
      mvi   b,'0'
      mvi   c,conout
      lxi   h,n0
hr0:  mov   a,m
      cpi   '$'
      jz    hdn
      mov   e,b
      call  bdos
      mvi   e,':'
      call  bdos
      mvi   e,' '
      call  bdos
      mvi   e,'|'
hr1:  call  bdos
      dcr   a
      jnz   hr1
      inx   h
      inr   b
      jmp   hr0
hdn:  ret
done: pop 	h
      pop   b
			pop 	psw			; pop destroyed registers
			ret					  ; return



m0:   db    'The Number Analser Mk.13'
      db    cr,lf,'enter some goddamn numbers shit$'
      db    cr,lf,'type as many digits as you goddamn want:$'
m1:   db    'numbers got straight analzed:',lf,cr,cr,'$'
n0:   ds    10      ; save space for 10 values
			sp0 	equ $		; stack address
			end					  ; ends assembler