; LSLTEST.ASM: detect LSL (ODI Link Support Layer)
; some code taken from odipkt.asm

; compile with nasm (or 'nasm16' = nasm 16bit):
; nasm16 -f bin -o LSLTEST.COM LSLTEST.ASM

; Public Domain, Frank Haeseler 6/2023

; ChangeLog
; started as Masm code 8/2022,
; ported to Nasm 6/2023

; additional test (6/2023):
; first do a check, if any int 2Fh handlers have been installed
; (prevent freezing in DOS 2.x)

; RBIL:
; INT 2F - Novell ODI Link Support Layer (LSL.COM) - INSTALLATION CHECK
;       AX = C000h
; Return: AL = FFh if installed
;           DX:BX -> FAR entry point (see #02986,#02987,#02988)
;           ES:SI -> signature string "LINKSUP$"
; Range:  AH=C0h to AH=FFh, selected by scanning for first free multiplex number
; Note:   on return, ES = DX for LSL v1.10 and v2.05; LSL makes use of this in
;         its search for a previous installation
; 
use16
org 100h          ; a COM program

; process command line arguments
 mov  si, 81h       ; get command line args
args: 
 lodsb
 cmp  al, ' '
 jz  args
 cmp  al, '-'
 jz  args
 cmp  al, '/'
 jz  args
 cmp  al, 13            ; CR at end of line?
 jb  start
 cmp  al, 51h           ; is it "Q" ?
 je  quiet
 cmp  al, 71h           ; is it "q" ?
 je  quiet
 cmp  al, 48h           ; is it "H" ?
 je  callHelp
 cmp  al, 68h           ; is it "h" ?
 je  callHelp
 jmp start             ; rest is ignored

quiet:
 mov    byte [quietvar], 1  ; Quiet = User wants no output at all

start:
 cmp    byte [quietvar], 1 ; is quietvar == 1? (User wants no Output)
 je     start1         ; direct jump to start2, if yes
 mov    dx, msg
 mov    ah, 9
 int    21h

start1:
 mov    ax,352Fh ; first check whether any int 2Fh handlers installed
 int    21h      ; will fail with DOS 2.x
 mov    ax,es
 or     ax,bx
 jz     no_int2fh ; if int 2Fh entry is null (in DOS 2.x)

start2: xor ax, ax
 mov    es, ax
 xor    bx, bx
 xor    dx, dx
 mov    ah, 0c0h
start3:
 push   ax
 int    2fh
 cmp    al, 0ffh      ; AL = FFh if installed
 pop    ax
 jz     start5
start4:
 inc    ah
 jnz    start3
 mov    dx, nolsl
 jmp    pexit

start5:
 mov    cx, dx
 or     cx, bx
 jz     start4
 mov    di, si
 mov    si, lslname
 cld
 mov    cx, 8
 repe   cmpsb
 jz     lsl_yes
 xor	bx, bx
 xor    dx, dx
 jmp    start4

no_int2fh:           ; int 2Fh entry is null
 mov    dx, noint    ; (in DOS 2.x, if LSL has NOT been loaded before)

pexit:
 cmp    byte [quietvar], 1 ; is quietvar == 1? (User wants no Output)
 je     qexit        ; direct jump to qexit, if yes
 mov    ah, 9
 int    21h
qexit:
 mov    ax, 4c00h           ; prepare errorlevel 0
 mov    al, byte [errorlvl] ; but we want our errorlevel
 int    21h
 int    20h

lsl_yes:                 ; LSL is loaded
 mov    dx, lslyes
 mov    byte [errorlvl], 1  ; Errorlevel 1
 jmp    pexit

; Help subroutine
callHelp:
 mov    dx, myHelp
 mov    ah, 09h
 int    21h
 jmp    qexit

; Data
quietvar   db 0
errorlvl   db 0

lslname    db   'LINKSUP$'
noint      db   'NO int 2Fh handlers installed.',13,10,'$'
nolsl      db   13,10, 'The Link Support Layer is not loaded.', 13,10, '$'
lslyes     db   13,10, 'The Link Support Layer is loaded.', 13,10, '$'
myHelp     db   'LSLTEST.COM: detect if the Link Support Layer (LSL) is loaded.', 13,10
           db   '    Errorlevel is 1, if LSL is loaded.', 13,10
           db   '    Errorlevel is 0, if LSL is not loaded.', 13,10
           db   'Command-line arguments (optional):', 13,10
           db   '  -h : Display this help screen', 13,10
           db   '  -q : Quiet: No output at all, only errorlevel', 13,10, '$'

msg        db   'LSLTEST.COM', 13,10
           db   'This small program detects if the Link Support Layer (LSL) is loaded.', 13,10
           db   'Help with LSLTEST /h.', 13,10
           db   '(c) Frank Haeseler 2023.', 13,10, '$'

