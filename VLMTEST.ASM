TITLE VLMTEST
; VLMTEST.ASM: detect VLM (Novell NetWare 4.x)

; Masm code (v4), link with val /COM
; Public Domain, Frank Haeseler 9/2022

; RBIL:
; INT 2F - Novell NetWare - Adv NetWare 4.0 DOS Requester
;          (GET VLM CALL ADDRESS)
;     AX = 7A20h
;     BX = 0000h
; Return: AX = 0000h on success (installed)
;     ES:BX -> far call address for DOS Requester (see #02859)
; Notes: the DOS Requester replaces the NetWare Shell (ANETx, NETx) on
;        NetWare LAN's as of the release of Advanced NetWare 4.0 (1993). It
;        is backward compatible with NetWare 2.1x through 3.11 servers as
;        well. Note that there was a NetWare 4.0 in the early 1980's, which
;        can cause confusion.
;        this call is used as the installation check by VLM.EXE, which is the
;        loader for all the modules of the DOS Requester
;        .VLMs are standard old .EXE format executables whose normal entry point
;        merely terminates to prevent loading from the command line (Novell's
;        VLMs all return errorlevel 6).  The real entry point is found by
;        looking at the VLM header at the beginning of the load image
;        (see #02862)
; Index: installation check; NetWare 4.0 DOS Requester
; SeeAlso: AX=7A20h/BX=0001h,AX=7A20h/BX=0002h
; 
_TEXT   SEGMENT
        ASSUME CS:_TEXT,DS:_TEXT,ES:_TEXT,SS:_TEXT
org     100h

start:
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
 jb   start1
 cmp  al, 51h           ; is it "Q" ?
 je   quiet
 cmp  al, 71h           ; is it "q" ?
 je   quiet
 cmp  al, 48h           ; is it "H" ?
 je   callHelp
 cmp  al, 68h           ; is it "h" ?
 je   callHelp
 jmp  start1            ; rest is ignored

quiet:
 mov  quietvar, 1       ; Quiet = User wants no output at all
 jmp  start2
start1:
 cmp    quietvar, 1    ; is quietvar == 1? (User wants no Output)
 je     start2         ; direct jump to start2, if yes
 mov    dx, offset msg
 mov    ah, 9
 int    21h

start2:
 xor    ax, ax          ; delete AX-register
 mov    ax, 7A20h
 mov    bx, 0
 int    2Fh
 or     ax, ax
 jnz    NO_VLM
                         ; VLM is loaded
 mov    dx, offset vlmyes
 mov    errorlvl, 1      ; Errorlevel 1
 jmp    pexit

NO_VLM:
 mov    dx, offset novlm
 jmp    pexit

pexit:
 cmp    quietvar, 1   ; is quietvar == 1? (User wants no Output)
 je     qexit         ; direct jump to qexit, if yes
 mov    ah, 9
 int    21h
qexit:
 mov    ax, 4c00h        ; prepare errorlevel 0
 mov    al, errorlvl     ; but we want our errorlevel
 int    21h
 int    20h

; Help subroutine
callHelp:
 mov    dx, offset myHelp
 mov    ah, 09h
 int    21h
 jmp    qexit

; Data
quietvar   db 0
errorlvl   db 0

novlm      db   13, 10, 'VLM is not loaded (EL 0).', 13, 10, '$'
vlmyes     db   13, 10, 'VLM is loaded (EL 1).', 13, 10, '$'
myHelp     db   13, 10, 'VLMTEST.COM: detect if Novell NetWare 4.x DOS Requester (VLM) is loaded.', 13, 10
           db   '   Errorlevel is 1, if VLM is loaded.', 13, 10
           db   '   Errorlevel is 0, if VLM is not loaded.', 13, 10
           db   'Command-line arguments (optional):', 13, 10
           db   '   -h : Display this help screen.', 13, 10
           db   '   -q : Quiet: No output at all, only errorlevel.', 13, 10,
           db   13, 10, 'Note:', 13, 10
           db   'This program does not search for the NetWare Workstation Shell 3.x (NETx).', 13, 10, 13, 10, '$'
msg        db   13, 10,'VLMTEST.COM', 13, 10
           db   'This small program detects if Novell NetWare 4.x (VLM) is loaded.', 13, 10
           db   'Help with VLMTEST /h.', 13, 10
           db   '(c) Frank Haeseler 2022.', 13, 10, '$'

_TEXT ENDS
END  start
