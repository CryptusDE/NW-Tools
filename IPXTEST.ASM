; IPXTEST.ASM: detect IPX

; Public Domain, Frank Haeseler 6/2023

; compile with nasm (or 'nasm16' = nasm 16bit):
; nasm16 -f bin -o IPXTEST.COM IPXTEST.ASM

; additional test:
; first do a check, if any int 2Fh handlers have been installed
; (prevent freezing in DOS 2.x)

; RBIL:
; INT 2F - Novell NetWare - LOW-LEVEL API (IPX) INSTALLATION CHECK
;       AX = 7A00h
; Return: AL = 00h not installed
;         AL = FFh if installed
;           ES:DI -> FAR entry point for routines accessed exclusively
;                    through INT 7A in NetWare versions through 2.0a.
;                    Call with same values as INT 7A
;           ES:BX -> two bytes containing IPX major/minor version
;                    (IPXODI v2.12; BX unchanged by older IPX drivers)
; 
use16
org 100h          ; a COM program

; process command line arguments
 mov  si, 81h       ; get command line args
args: 
 lodsb
 cmp  al, ' '
 jz   args
 cmp  al, '-'
 jz   args
 cmp  al, '/'
 jz   args
 cmp  al, 13            ; CR at end of line?
 jb   start
 cmp  al, 51h           ; is it "Q" ?
 je   quiet
 cmp  al, 71h           ; is it "q" ?
 je   quiet
 cmp  al, 48h           ; is it "H" ?
 je   callHelp
 cmp  al, 68h           ; is it "h" ?
 je   callHelp
 jmp  start             ; rest is ignored

quiet:
 mov    byte [quietvar], 1  ; Quiet = User wants no output at all

start:
 cmp    byte [quietvar], 1 ; is quietvar == 1? (User wants no Output)
 je     start1             ; direct jump to start2, if yes
 mov    dx, msg
 mov    ah, 9
 int    21h

start1:           ; first check whether any int 2Fh handlers installed;
 mov    ax,352Fh  ; this will fail with DOS 2.x (before loading LSL)
 int    21h
 mov    ax, es
 or     ax, bx
 jz     no_int2fh ; if int 2Fh entry is null (in DOS 2.x)

start2:
 xor    ax, ax
 mov    ax,7A00h
 int    2fh
 cmp    al, 0ffh      ; AL = FFh if installed
 je     ipx_yes

 mov    dx, noipx
 jmp    pexit

ipx_yes:             ; IPX is loaded
 mov    dx, ipxyes
 mov    byte [errorlvl], 1  ; Errorlevel 1
 jmp    pexit

no_int2fh:           ; int 2Fh entry is null
 mov    dx, noint    ; (in DOS 2.x, if LSL has NOT been loaded before)

pexit:
 cmp    byte [quietvar], 1 ; is quietvar == 1? (User wants no Output)
 je     qexit              ; direct jump to qexit, if yes
 mov    ah, 9
 int    21h
qexit:
 mov    ax, 4c00h           ; prepare errorlevel 0
 mov    al, byte [errorlvl] ; but we want our errorlevel
 int    21h
 int    20h

; Help subroutine
callHelp:
 mov    dx, myHelp
 mov    ah, 09h
 int    21h
 jmp    qexit

; Data
quietvar   db 0
errorlvl   db 0

noint      db   'NO int 2Fh handlers installed.',13,10,'$'
noipx      db   13,10, 'IPX is not loaded.', 13,10, '$'
ipxyes     db   13,10, 'IPX is loaded.', 13,10, '$'
myHelp     db   'IPXTEST.COM - IPX (Internetwork Packet Exchange) protocol:', 13,10
           db   'IPXTEST detects if the IPX protocol is loaded.', 13,10
           db   '    Errorlevel is 1, if IPX is loaded.', 13,10
           db   '    Errorlevel is 0, if IPX is not loaded.', 13,10
           db   'Command-line arguments (optional):', 13,10
           db   '  -h : Display this help screen', 13,10
           db   '  -q : Quiet: No output at all, only errorlevel', 13,10, '$'

msg        db   'IPXTEST.COM', 13,10
           db   'This small program detects if the IPX protocol is loaded.', 13,10
           db   'Help with IPXTEST /h.', 13,10
           db   '(c) Frank Haeseler 2023.', 13,10, '$'
