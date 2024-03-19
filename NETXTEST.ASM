; NETXTEST.ASM: detect NETX (NetWare Shell)

; Public Domain, Frank Haeseler 8/2023

; compile with nasm (or 'nasm16' = nasm 16bit):
; nasm16 -f bin -o NETXTEST.COM NETXTEST.ASM

; The NetWare API:
; NWGetDefaultConnectionID simply calls DOS function F0h, subfunction 2h.
; Since this function is not used by DOS, it normally returns zero in the
; AL register. If the NetWare shell has intercepted the DOS interrupt vector,
; or if DOS has redirected the interrupt to the NetWare requester, the
; interrupt returns the connection ID for the default server.

; Connection id (INT 21h, F0h - Novell Advanced NetWare 1.0+)
;
;  Entry:
;    AH = F0h
;    AL = subfunction
;        00h  Set preferred connection ID
;        01h  Get preferred connection ID
;        02h  Get default connection ID
;        03h  LPT capture active
;        04h  Set primary connection ID
;        05h  Get primary connection ID
;    DL = preferred file server
;      Return:
;      AL = selected file server

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
 jmp start              ; rest is ignored

quiet:
 mov    byte [quietvar], 1  ; Quiet = User wants no output at all

start:
 cmp    byte [quietvar], 1 ; is quietvar == 1? (User wants no Output)
 je     start1             ; direct jump to start1, if yes
 mov    dx, msg
 mov    ah, 9
 int    21h

start1:
 xor    ax, ax
 mov    ax, 0F002h  ; Whenever the first digit in a hex number is an alphabet (a-h),
                    ; do not forget to put a ‘0’ before this number, otherwise
                    ; an error will occur
 int    21h
 cmp    al, 0
 je     notinstalled

; NetWare Shell is loaded
 mov    dx, shellyes
 mov    byte [errorlvl], 1  ; Errorlevel 1
 jmp    pexit

notinstalled:
 mov    dx, noshell

pexit:
 cmp    byte [quietvar], 1 ; is quietvar == 1? (User wants no Output)
 je     qexit       ; direct jump to qexit, if yes
 mov    ah, 9
 int    21h
qexit:
 mov    ax, 4c00h        ; prepare errorlevel 0
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

noshell    db   13,10, 'The NetWare Shell is not loaded.', 13,10, '$'
shellyes   db   13,10, 'The NetWare Shell is loaded.', 13,10, '$'
myHelp     db   'NETXTEST.COM: detect if the NetWare Shell (NETX) is loaded.', 13,10
           db   '    Errorlevel is 1, if NETX is loaded.', 13,10
           db   '    Errorlevel is 0, if NETX is not loaded.', 13,10
           db   'Command-line arguments (optional):', 13,10
           db   '  -h : Display this help screen', 13,10
           db   '  -q : Quiet: No output at all, only errorlevel', 13,10, '$'

msg        db   'NETXTEST.COM', 13,10
           db   'This small program detects if the NetWare Shell (NETX) is loaded.', 13,10
           db   'Help with NETXTEST /h.', 13,10
           db   '(c) Frank Haeseler 2023.', 13,10, '$'
