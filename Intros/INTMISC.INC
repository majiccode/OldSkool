;ษออออออออออออออออออออออออออออออออออออออออออออออออป
;บ  Name:Video_Sync_And_Keyboard_INT_Routines	  บ
;บ                                                บ
;บ  Modified:23-Nov-93			       FB บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออผ
;
;--------------------------------------------------------------
;
; SetINT8
;   -INT8handler
; RestoreINT8
;
; SetINT9
;   -INT9handler
; RestoreINT9
;
; DisableKbd
; EnableKbd
;
; WaitBorder
; GetRasterline
; WaitRasterline
;
;-----------------------------------------------------------------

frametime	dw ?
oldINT8 	dd ?
oldINT9 	dd ?

;-----------------------------------------------------------------
INT8handler PROC FAR

	;timer interrupt
	push	ax
	push	dx

	mov	al,20h
	out	20h,al

	mov	dx,3dah
int8_1: in	al,dx
	test	al,8
        jnz     int8_1     ; wait for VR
int8_2: in      al,dx
	test	al,8
        jz      int8_2     ; wait for VR

       ;call waitborder

	mov	al,34h	   ; pulse
	out	43h,al
	mov	al,byte ptr cs:[frametime]
	out	40h,al
	mov	al,byte ptr cs:[frametime+1]
	out	40h,al

	;NOTE: we are now in a VR!
	;if housekeeper takes relative long you might want to
	;move it to the beginning of the handler and adjust
	;the interrupt timing s.t. the prog gets interrupted
	;some additional scan lines before the VR.
	sti
        ;call    housekeeper
	cli

	pop	dx
	pop	ax
	iret
INT8handler ENDP

;-----------------------------------------------------------------
; SetINT8 - Sets Timer Interrupt (8) - timer synchronized with VR
;    IN     : -
;   OUT     : -
;  Modified : ax,dx
;  Vars Used: oldINT8,frametime


SetINT8 PROC NEAR
	cli
	;set up timer int vector
	push	es
	xor	ax,ax
	mov	es,ax
	mov	ax,es:[8*4]
	mov	word ptr cs:oldINT8[0],ax
	mov	ax,es:[8*4+2]
	mov	word ptr cs:oldINT8[2],ax
	mov	ax,offset INT8handler
	mov	es:[8*4],ax
	mov	es:[8*4+2],cs
	pop	es
	sti

	;find time it takes from VR to next VR
	call	waitborder
	;set timer to max period 65536
	mov	al,34h	    ;pulse
	out	43h,al
	mov	al,0
	out	40h,al
	mov	al,0
	out	40h,al

	call	waitborder
	xor	al,al	    ;latch present counter value
	out	43h,al
	in	al,40h	    ;read LO
	mov	ah,al
	in	al,40h	    ;read HI
	xchg	al,ah

	;counter counts down from 65536
	;to find time: (65536-HILO)=-HILO
	neg	ax

	;frametime = frametime-(frametime/128)
	;make sure we never miss the beginning of a VR
	mov	dx,ax
	shr	ax,7		;7 works fine with short housekeeper
	sub	dx,ax
	mov	cs:frametime,dx 	;length of one frame

	;set timer
	call	waitborder
	mov	al,34h	    ;pulse
	out	43h,al
	mov	al,byte ptr cs:[frametime]
	out	40h,al
	mov	al,byte ptr cs:[frametime+1]
	out	40h,al
	ret

SetINT8 ENDP

;-----------------------------------------------------------------
; RestoreINT8 - Restores Timer Interrupt (8)
;    IN     : -
;   OUT     : -
;  Modified : ax,dx
;  Vars Used: oldINT8


RestoreINT8 PROC NEAR
	cli
	push	es
	mov	ax,0
	mov	es,ax
	mov	ax,WORD PTR cs:oldINT8[0]
	mov	dx,WORD PTR cs:oldINT8[2]
	mov	es:[8*4],ax
	mov	es:[8*4+2],dx
	sti

	; retore timer to old setting
	mov	al,34h	    ;pulse
	out	43h,al
	mov	al,0
	out	40h,al
	mov	al,0
	out	40h,al
	pop	es
	ret

RestoreINT8 ENDP

;-------------------------------------------------------------------
; DisableKbd - Disables Keyboard
;    IN     : -
;   OUT     : -
;  Modified : ax
;  Vars Used: -

DisableKbd PROC NEAR
	in	al,21h
	or	al,00000010b
	out	21h,al
	ret
DisableKbd ENDP

;-----------------------------------------------------------------
; EnablesKbd - Enables Keyboard
;    IN     : -
;   OUT     : -
;  Modified : ax
;  Vars Used: -

EnableKbd PROC NEAR
	in	al,21h
	and	al,11111101b
	out	21h,al
	ret
EnableKbd ENDP

;-----------------------------------------------------------------

INT9handler PROC FAR
	push	ax
        in      al,60h
       ; cmp	 al,01h 	 ; ESC
       ; je	 nokey
	cmp	al,1ch		; RETURN
	je	nokey
       ; cmp	 al,39h 	 ; SPACE
       ; je	 nokey

	;ignore all other keys
        in      al,61h
        mov     ah,al
        or      al,80h
        out     61h,al
        xchg    ah,al
        out     61h,al
        mov     al,20h
        out     20h,al
        pop     ax
	iret

nokey:
	pop	ax
        jmp     cs:oldint9
INT9handler ENDP

;-----------------------------------------------------------------
; SetINT9 - Sets Keyboard Interrupt (9)
;    IN     : -
;   OUT     : -
;  Modified : ax
;  Vars Used: -

SetINT9 PROC NEAR
	cli
	push	es
	xor	ax,ax
	mov	es,ax
	mov	ax,es:[9*4]
	mov	word ptr cs:oldint9[0],ax
	mov	ax,es:[9*4+2]
	mov	word ptr cs:oldint9[2],ax
	mov	ax,offset INT9handler
	mov	es:[9*4],ax
	mov	es:[9*4+2],cs
	pop	es
	sti
	ret
SetINT9 ENDP

;-----------------------------------------------------------------
; RestoreINT9 - Restores Keyboard Interrupt (9)
;    IN     : -
;   OUT     : -
;  Modified : ax
;  Vars Used: -

RestoreINT9 PROC NEAR
	cli
	push	es
	xor	ax,ax
	mov	es,ax
	mov	ax,word ptr cs:oldint9[0]
	mov	bx,word ptr cs:oldint9[2]
	mov	es:[9*4],ax
	mov	es:[9*4+2],bx
	pop	es
	sti
	ret
RestoreINT9 ENDP

;-----------------------------------------------------------------
; Waitborder - Wait for next VR
;    IN     : -
;   OUT     : -
;  Modified : -
;  Vars Used: -

Waitborder PROC NEAR
	push	ax
	push	dx
	mov	dx,3dah
wbr1:	in	al,dx
	test	al,8
	jnz	wbr1
wbr2:	in	al,dx
	test	al,8
	jz	wbr2
	pop	dx
	pop	ax
	ret
Waitborder ENDP

;-----------------------------------------------------------------
; GetRasterline - Gets current rasterline (not exact!) apprx range:1..479
;    IN     : -
;   OUT     : ax    (Rasterline)
;  Modified : cx,dx
;  Vars Used: frametime

GetRasterline PROC NEAR
	;AX=scan line the VGA is in (requires ints set)
	cli
	xor	al,al
	out	43h,al
	in	al,40h
	mov	dl,al
	in	al,40h
	mov	dh,al

	mov	ax,cs:frametime
	sub	ax,dx
	mov	cx,506
	mul	cx
	mov	cx,cs:frametime
	div	cx
	sub	ax,26		;adjust to 480 (506-26=480)

	sti
	ret
GetRasterline ENDP

;-----------------------------------------------------------------
; WaitRasterline - Wait until Rasterline (not exact!) apprx. range 1..479
;    IN     : dx    (Rasterline)
;   OUT     : -
;  Modified : ax,cx,dx
;  Vars Used: frametime

WaitRasterline PROC NEAR
	;returns when Scan Line=DX (requires ints set)
	cli
	mov	cx,506	      ;# of horizontal scan lines + VR
	mov	ax,480	      ;# of horizontal scan lines
	sub	ax,dx
	mul	word ptr cs:frametime
	div	cx
	mov	cx,ax

waitraster1:
	xor	al,al
	out	43h,al
	in	al,40h
	mov	ah,al
	in	al,40h
	xchg	al,ah
	cmp	ax,cx
	ja	waitraster1

	sti

	ret
WaitRasterline ENDP
;-----------------------------------------------------------------
