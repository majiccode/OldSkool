;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; XCOPY-PC Source Code Listing
;
; A-Level Computer Science Project 1995
;
;  Version - 3.01
;     Date - 9/2/95
; Compiled - 9/2/95
;
; (c)1995 Matrix Design, Paul Adams. All rights reserved!
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴



                call    Start                   ; Go to start of program.

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Global Varibals and Constants
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PaletteData     db      768 dup(0)              ; Buffer to store palette.
VideoBuffer     dw      0A000h                  ; Segment address of video
                                                ; buffer.
; *** Mouse Varibles ***

MouseVisable    db      0                       ; 1 if Mouse Visable
MouseCursor     db      1                       ; Mouse cursor type.
                                                ; 1=Standard, 2=Disk, 3=Help
OldInt33        dd      00000000                ; Storage for old int. vector.
MouseBuffer     db      15*15 dup(0)            ; Buffer for mouse cursor.
					
MouseX          dw      0                       ; Mouse X coordinate.
MouseY          dw      0                       ; Mouse Y coordinate.
RButton         db      0                       ; 1=Right mouse button pressed.
LButton         db      0                       ; 1=Left mouse button pressed.
                                                
; *** Error status varibles ***

ErrorFlag       db      0                       ; >0 if error occured.
ErrorStatus     db      0                       ; 1 if processing error.
SkipBack        dd      0                       ; Storage for SS:SP

; *** File copying varibles ***

Verify          db      0                       ; 1=Verify data on.
DiskType        db      0                       ; F0=High density, F9=Low!
Drive           db      0                       ; 0=A: 1=B:
Buffer          db      18*512*2 dup(0)         ; Storage for disk data.
BufferSize      dw      0                       ; Size of buffer.
Copies          db      1                       ; Number of copies from source.
CopyAmount      dw      1                       ; Number of copies from source.
Handle          dw      0                       ; File handle.
TempFile        db      '_DISK_.TMP',0          ; Temporay file for disk.
Sectors         db      0                       ; Current sector being used.
Track           db      0                       ; Current track being used.
Head            db      0                       ; Current head.
WriteOk         db      0                       ; 1=Enable write option.
DoWrite         db      0                       ; ?

; *** Messages ***

StartupError1   db      'X-COPY PC Must be ran from the hard drive.$'
StartupError2   db      'X-COPY PC Requires a VGA card.$'
StartupError3   db      'X-COPY PC Requires DOS Version 3 or above.$'
StartupError4   db      'X-COPY PC Requires a Microsoft Mouse or Compatible Mouse Driver.$'

CopyrightMsg    db      'X-COPY PC V3.01 BY PAUL ADAMS',13
		db      '(C)1994-95 MATRIX DESIGN',0
Ready           db      'READY....',0
HelpModeActive  db      'INTERACTIVE HELP MODE (TM)',13
		db      'POINT ON OBJECT TO GET HELP!',13
		db      'RIGHT MOUSE BUTTON TO EXIT.',0
CheckFAT        db      'CHECKING MEDIA IDENTIFICATION!!',0
Copy144         db      'READING 1.44MB DISK',0
Verify144       db      'VERIFYING 1.44MB DISK',0
Write144        db      'WRITING 1.44MB DISK',0
Copy720         db      'READING 720K DISK',0
Verify720       db      'VERIFYING 720K DISK',0
Write720        db      'WRITING 720K DISK',0
CheckDisk       db      'CHECKING DISK SURFACE AREA....',0
Format144       db      'FORMATING 1.44MB DISK',0
Format720       db      'FORMATING 720K DISK',0
FormatError     db      'ERROR(S) OCCURED DURING FORMAT!',13
		db      'THIS DISK SHOULD BE CHECKED.',0
ReadError       db      'ERROR(S) OCCURED DURING COPY OF',13
		db      'THE DISK. PLEASE CHECK DISK!',0
WriteError      db      'ERROR(S) OCCURED DURING WRITE OF',13
		db      'THE DISK. PLEASE CHECK DISK!',0
VerifyError     db      'ERROR(S) OCCURED DURING VERIFY OF',13
		db      'THE DISK. PLEASE RE-FORMAT!!',0
DoneNoRead      db      'PLEASE SELECT READ OPTION BEFORE',13
		db      'A WRITE OPTION.',0
EnterVolume     db      'ENTER A VOLUME NAME. 11 CHARS MAX:',0
InputSpace      db      53 dup(20h),0
VolumeLabel     db      11 dup(20h)

; *** Help messages ***

HelpMsg1        db      'THIS IS THE DISK MAP KEY. EACH COLOUR',13
                db      'REPRESENTS THE STATUS OF THE OPERATION.',0
HelpMsg2        db      'THIS IS THE MESSAGE WINDOW. MESSAGES',13
                db      'AND ERRORS ARE DISPLAYED HERE!',0
HelpMsg3        db      'THIS IS THE TIME DISPLAY. IT TELLS YOU',13
                db      'THE CURRENT TIME.',0
HelpMsg4        db      'THIS OPTION IS USED TO READ THE DISKS.',13
                db      'JUST PLACE YOUR DISK IN THE DRIVE AND',13
                db      'CLICK HERE. THE DISK WILL THEN BE READ.',0
HelpMsg5        db      'THIS OPTION IS USED AFTER THE READ ',13
                db      'OPTION. IT WILL WRITE THE DATA READ ONTO',13
                db      'YOUR SOURCE DISK!',0
HelpMsg6        db      'THIS OPTION WILL DISPLAY INFORMATION',13
                db      'ABOUT THE DISK INSERTED. IT WILL TELL',13
                db      'YOU EVERYTHING YOU WOULD WANT TO KNOW',0
HelpMsg7        db      'THIS OPTION IS VERY USEFULL. IT WILL SCAN',13
                db      'THIS DISK INSERTED FOR ERRORS. IT CAN BE',13
                db      'USED BEFORE A WRITE OPERATION FOR SAFTEY',0
HelpMsg8        db      'THIS OPTION WILL ALLOW YOU TO FORMAT YOUR',13
                db      'DISKS TO EITHER 720K OR 1.44MB.',0
HelpMsg9        db      'USE THIS OPTION TO SELECT THE NUMBER OF',13
                db      'COPIES NEEDED OF THE SOURCE DISK. THIS',13
                db      'SAVES MULTIPLE READS OF THE SOURCE DISK!',0
HelpMsg10       db      'EXIT BACK TO DOS!!!!!',0
HelpMsg11       db      'CLICK ON THIS TO SELECT IF THE SOURCE',13
                db      'DISK IS IN DRIVE A:',0
HelpMsg12       db      'CLICK ON THIS TO SELECT IF THE SOURCE',13
                db      'DISK IS IN DRIVE B:',0
HelpMsg13       db      'CLICK ON THIS TO TOGGLE THE VERIFY OPTION',13
                db      'ON OR OFF. IF ON THE DATA BEING WRITTEN IS',13
                db      'VERIFYED. THIS PREVENTS YOU USING A BAD DISK',0
HelpMsg14       db      'THIS IS THE DISKMAP. IT SHOWS YOU',13
                db      'GRAPHICALLY WHERE ABOUT ERRORS OCCUR ON',13
                db      'THE DISK ETC.',0
HelpMsg15       db      'THIS TELLS YOU THE CURRENT TRACK NUMBER',13
                db      'BEING READ.',0
HelpMsg16       db      'THIS TELLS YOU THE TIME TAKEN FOR A DISK',13
                db      'OPERATION!',0
HelpMsg17       db      'X-COPY PC VERSION 3.01',13
                db      '(C)OPYRIGHT MATRIX DESIGN 1994-5',13
                db      'WRITTEN BY PAUL ADAMS IN ASSEMBLER!',0

; *** Error Messages ***

Error1          db      'INVALID COMMAND!',0
Error2          db      'ADDRESS MARK NOT FOUND!',0
Error3          db      'DISK WRITE-PROTECTED?',0
Error4          db      'SECTOR NOT FOUND!',0
Error5          db      'RESET FAILED. (HARD DISK)',0
Error6          db      'DISKETTE CHANGED',0
Error7          db      'BAD PARAMETER TABLE (HARD DISK)',0
Error8          db      'DMA OVERRUN (FLOPPY DISK)',0
Error9          db      'DMA ACROSS THE 64K BOUNDARY',0
Error10         db      'BAD SECTOR DETECTED (HARD DRIVE)',0
Error11         db      'BAD TRACK DETECTED (HARD DRIVE)',0
Error12         db      'UNSUPPORTED TRACK (FLOPPY DISK)',0
Error13         db      'INVALID NUMBER OF SECTORS (HARD DRIVE)',0
Error14         db      'WHAT????',0
Error15         db      'DMA ARBITRATION ERROR (HARD DRIVE)',0
Error16         db      'BAD CRC-ECC',0
Error17         db      'DATA ECC CORRECTED (HARD DRIVE)',0
Error18         db      'ERROR IN DISK CONTROLLER',0
Error19         db      'SEEK FAILED',0
Error20         db      'DISK NOT INSERTED IN DRIVE!',0
Error21         db      'DRIVE NOT READY',0
Error22         db      'DISK TYPE NOT SUPPORTED!!!',0


; This table contains the addresses of the error messages. They are accessed
; by using the error returned by the functions as an index in the table.
;
; Eg/ if the ErrorFlag=3 (Disk Write Protected) then the index is 3.
;     so the address at index 3 coresponds to Errro3 = Disk Write Protect.
; NB. The table is a list of words so the value returned must be multiplyed
;     by two to allow for this. To multiply by two I would simply shift the
;     value left by one place. -> SHL BX,1 ; BX=BX*2

ErrorTable      dw      Error1,Error2,Error3,Error4,Error5,Error6,Error7
		dw      Error8,Error9,Error10,Error11,Error12,Error13,Error14
		dw      Error15,Error16,Error17,Error18,Error19,Error20
		dw      Error21,Error22




; *** Formating variable ***

OldDBT          dd      00000000                ; 

NewDBT          db      0af,02,25h,02,30h,1bh,0ffh,6ch,0f6h,0fh,08,00,00,00
AddrField       db      0,0,1,2,0,0,2,2,0,0,3,2,0,0,4,2,0,0,5,2,0,0,6,2
		db      0,0,7,2,0,0,8,2,0,0,9,2,0,0,10,2,0,0,11,2,0,0,12,2
		db      0,0,13,2,0,0,14,2,0,0,15,2,0,0,16,2,0,0,17,2,0,0,18,2
		db      0,0,19,2

CurTrack        db      0                       ;
CurHead         db      0                       ;
                                                
FmtType         db      0                       ; storgae for varibles in
TtlHeads        db      0                       ; data table below
TtlTracks       db      0                       ;
TtlSectors      db      0                       ;
SecPerClust     db      0                       ;
FATSectors      db      0                       ;
DIRSectors      db      0                       ;
DIREntries      db      0                       ;
FATid           db      0                       ;
                                                
Disk720         db      04                      ; format type
                db      02                      ; number of heads
                db      80                      ; number of tracks
                db      09                      ; number of sectors
                db      02                      ; sectors per cluster
                db      06                      ; total FAT sectors
                db      07                      ; root directory sectors
                db      112                     ; root entries
                db      0f9h                    ; fat id
Disk144         db      04                      ; format type
                db      02                      ; number of heads
                db      80                      ; number of tracks
                db      18                      ; number of sectors
                db      01                      ; sectors per cluster
                db      18                      ; total FAT sectors
                db      14                      ; root directory sectors
                db      224                     ; root entries
                db      0f0h                    ; fat id

ConfigTable     dw      Disk720                 ; Table addresses
                dw      Disk144                 ;

FormatSize      db      0                       ; Requested format size


; Menu jump table. See description of Errortable for use!

OptionRoutines  dw      HelpMode,ShutDown,ReadDisk,WriteDisk,DiskInfo,VerifyDisk
		dw      Format,CopiesSelect,SelectA,SelectB,VerifySwitch


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Macro Definitions.
;
; Notes:
;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PushIt Macro                            
 Push Ax,Bx,Cx,Dx,Es,Ds,Si,Di,Bp        
 PushF                                  
#EM                                     
PopIt Macro                             
 PopF                                   
 Pop Bp,Di,SI,Ds,Es,Dx,Cx,Bx,Ax         
#EM                                     


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure Decompress / Decompresses image. 
;
; DS:SI = Compressed image, ES:DI = Destination for decompressed image
; BX = Image size (in bytes)
;
; Notes: This procedure will decompress data to its original size. It uses
;        a simple Run Length Encoding method. 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Decompress:     cmp     bx,0                     ; Have we done all bytes?
                je      FinishDecomp             ; Yes, so exit.
                mov     al,ds:[si]               ; Get byte from source.
                dec     bx                       ; Decrease bytes done by one.
                cmp     al,128                   ; Is byte below 128.
                jb      GetPixel1                ; Yes, so jump to GetPixel1.
                sub     al,128                   ; Subtract 128 from al.
                inc     si                       ; Point to next source byte.
                mov     ah,ds:[si]               ; Get next byte.
                dec     bx                       ; Decrease bytes done by one.
                mov     ch,0                     ; Initalise counter to al.
                mov     cl,al                    ;
                inc     cx                       ; Add 1 to counter.
GetPixel2:      mov     es:[di],ah               ; Fill destination with ah.
                inc     di                       ; Point to next destination.
                loop    GetPixel2                ; Loop until cx=0
                inc     si                       ; Point to next source byte.
                cmp     bx,0                     ; Done all bytes?
                je      FinishDecomp             ; Yes, so exit!
                jmp     Decompress               ; Do again.
GetPixel1:      mov     es:[di],al               ; Place al at destination.
                inc     di                       ; Point to next dest. byte.
                inc     si                       ; Point to next source byte.
                cmp     bx,0                     ; Done all bytes?
                je      FinishDecomp             ; Yes, so exit!
                jmp     Decompress               ; Do again
FinishDecomp:   ret                              ; Finished procedure.

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure GetMem, Allocates a 64k block of memory and returns the
; segment address in AX for use with DS, ES etc.
; 16bytes in 1 paragraph
; 1000h paragraphs = 4096*16 = 65536k
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
GetMem:         mov     ds,cs                    ; Initalise data segment.
                mov     bx,1000h                 ; bx=Number of paragraphs
                mov     ah,4ah                   ; Modify allocated memory.
                int     21h                      ; Dos interrupt.
                mov     bx,1000h                 ; bx=Number of paras.
                mov     ah,48h                   ; Allocate memory.
                int     21h                      ; Dos interrupt.
                jb      MemoryError              ; Branch if error occured!
                ret                              ; Return from procedure.
                                                 
MemoryErrorMsg  db      'Sorry, You do not have enough memory!$'
MemoryError:    lea     dx,MemoryErrorMsg        ; load dx with address of
                mov     ah,9                     ; string.
                int     21h                      ; Print string function.
                mov     ah,4ch                   ; Exit to DOS
                int     21h                      ; 

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure SetPallete 
;
; Notes: This procedure reads the palette data file into a buffer and then
;        sets the palette using the VGA card directly.
;
; Technical Info: Port ->  3c7h = PEL Address Read Mode!     (get palette)
;                      ->  3c8h = PEL Address Write Mode!    (set palette)
; ALL VGA CARDS!       ->  3c9h = PEL Address Data Register! (RGB Values)
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PaletteName     db      'XCOPY.PAL',0            ; Filename of palette data.
					      
SetPalette:     mov     ds,cs                    ; Initalise data segment.
                mov     ah,3dh                   ; Open file function.
                mov     al,0                     ; Read mode 0.
                lea     dx,PaletteName           ; dx=offset of filename
                int     21h                      ; Dos function.
                cmp     ax,2                     ; Is file missing.
                je      PaletteMissing           ; Yes, so exit with error.
                push    ax                       ; Save file handle.
                mov     bx,ax                    ; 
                mov     ah,3fh                   ; Read data from file.
                mov     cx,768                   ; Number of bytes to read.
                lea     dx,PaletteData           ; ds:dx points to buffer.
                int     21h                      ; Dos function.
                pop     ax                       ; Restore file handle.
                mov     bx,ax                    ;
                mov     ah,3eh                   ; Close file
                int     21h                      ; Dos function.
                mov     cx,255                   ; Initalise counter.
                lea     si,PaletteData           ; ds:si points to buffer
                mov     dx,3c8h                  ; PEL Address Write Mode.
                mov     al,0                     ; Colour 0
                out     dx,al                    ; Send byte to port.
                inc     dx                       ; PEL Address Data Register.
SetPEL:         lodsb                            ; Get byte from ds:si
                out     dx,al                    ; Send to port.
                lodsb                            ; Get byte from ds:si
                out     dx,al                    ; Send to port.
                lodsb                            ; Get byte from ds:si
                out     dx,al                    ; Send to port.
                loop    SetPEL                   ; Loop until cx=0
                ret                              ; Finish procedure.
                                                 
PaletteError    db      'Sorry, File ''XCOPY.PAL'' is missing!$'

PaletteMissing: mov     ax,3                     ; Clear screen.
                int     10h                      ; Video Service Interrupt.
                lea     dx,PaletteError          ; dx=offset of message.
                mov     ah,9                     ; Print string.
                int     21h                      ; Dos interrupt.
                mov     ah,4ch                   ; Exit to DOS
                int     21h                      ;

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure Retrace, Wait for screen retrace.
;
; Notes: When a screen is redrawing. It sends a beam down the screen. Once
;        this occurs this is called the retrace period. To prevent flicker
;        or snow when writing to the screen all writes are done in this
;        period! 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Retrace:        mov     dx,3dah                  ; Video Status port.
Sync:           in      al,dx                    ; Get status byte.
                test    al,8                     ; Is bit 3 set?
                jz      Sync                     ; Yes, so try again.
                ret                              ; Return from procedure.

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure Display, Displays the graphical user input screen.
;
; Notes: This routine will load the screen from disk. It calls the decompress
;        procedure to restore the image to a raster format. It places it in
;        a 64k block of allocated memory and displays it on the screen.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ScreenSeg       dw      0000                     ; Segment address of graphics.
MenuSeg         dw      0000                     ; Segment address of menus.
TempSeg         dw      0000                     ; Temp segment.
Filename        db      'XCOPY.SCR',0            ; Filename of screen data.
ImageSize       dw      0000                     ; Size of screen data.

FileMissingErr  db      'Sorry, File ''XCOPY.SCR'' is missing!$'

FileMissing:    lea     dx,FileMissingErr        ; dx=offset of message.
                mov     ah,9                     ; Print String.
                int     21h                      ; Dos Function.
                mov     ah,4ch                   ; Exit to DOS
                int     21h                      ;

Display:        call    GetMem                   ; Allocate Memory.
                mov     w[ScreenSeg],ax          ; Save segment address.
                call    GetMem                   ; Allocate Memory.
                mov     w[TempSeg],ax            ; Save segment address.
                mov     ah,3dh                   ; Open file.
                mov     al,0                     ; Read mode 0
                lea     dx,Filename              ; dx=offset of filename.
                int     21h                      ; Dos function.
                push    ax                       ; Save file handle.
                cmp     ax,2                     ; Is file missing?
                je      FileMissing              ; Yes, so exit.
                mov     bx,ax                    ;
                mov     ah,3fh                   ; Read data from file.
                mov     al,0                     ; 
                mov     cx,0ffffh                ; Number of bytes to read.
                mov     ds,w[TempSeg]            ; ds:dx = destination
                xor     dx,dx                    ; clear dx.
                int     21h                      ; Dos function.
                mov     ds,cs                    ; Initalise data segment.
                mov     w[ImageSize],ax          ; Save size for later.
                pop     ax                       ; Restore file handle
                mov     bx,ax                    ; 
                mov     ah,3eh                   ; Close file.
                int     21h                      ; Dos function.
                mov     bx,w[ImageSize]          ; Get size for data.
                mov     es,w[ScreenSeg]          ; es:di = Screen Segment
                mov     di,0                     ;
                mov     ds,w[TempSeg]            ; ds:si = Temp Segment.
                mov     si,0                     ;
                call    Decompress               ; Decompress data.
                mov     ds,cs:w[ScreenSeg]       ; ds:si = Screen Segment.
                mov     es,cs:w[VideoBuffer]     ; es:di = Video buffer.
                mov     di,0                     ;
                mov     si,0                     ;
                mov     cx,320*185 /2            ; Bytes to display.
                repz    movsw                    ; Block move.
                mov     ah,49h                   ; Free allocated memory.
                mov     es,cs:w[TempSeg]         ; Segment to free.
                int     21h                      ; Dos function.
                mov     ds,cs                    ; Initalise data segment.
                call    GetMem                   ; Allocate memory.
                mov     w[MenuSeg],ax            ; Save segment address.
                mov     bx,w[MenuBoxSize]        ; Size of data to decompress.
                mov     ds,cs                    ; Initalise data segment.
                lea     si,MenuBox               ; si=Source data.
                mov     di,0                     ; es:di = destination data.
                mov     es,w[MenuSeg]            ;
                call    Decompress               ; Decompress data.
                ret                              ; Return from procedure.
                                                 

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Part of SetupMouse Procedure
;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
NewInt33:       cmp     ax,1                     ; Check function number.
                je      ShowMouse                ; 1=Showmouse.
                cmp     ax,2                     ; 2=HideMouse.
                je      HideMouse                ;
                jmp     cs:OldInt33              ; Jump to old interrupt.
                iret                             ; Return from interrupt.
ShowMouse:      mov     cs:b[MouseVisable],1     ; Make mouse visable.
                mov     cs:b[RestoreFlag],0      ; Reset restore flag.
                cmp     cs:b[MouseCursor],1      ; Check for cursor type.
                je      ShowPointer              ; Normal pointer?
                cmp     cs:b[MouseCursor],2      ; 
                je      ShowDisk                 ; Disk pointer?
                cmp     cs:b[MouseCursor],3      ;
                je      ShowHelp                 ; Help pointer?
                iret                             ; Return from interrupt.
HideMouse:      PushIt                           ; Macro name - Save regs.
                call    RestoreCursor            ; Restore background under
                mov     cs:b[MouseVisable],0     ; cursor.
                PopIt                            ; Macro name - Resore regs.
                iret                             ; Return from interrupt.
                                                 
ShowPointer:    PushIt                           ; Display normal cursor.
                mov     ax,320*187+261           ;  
                mov     cs:w[SpritePos],ax       ; Store bitmap position
                call    ArrowSprite              ; Do arrow cursor
                PopIt                            ; Restore all registers
                iret                             ; Return from interrupt.
		
ShowDisk:       PushIt                           ; Display Disk cursor
                mov     ax,320*187+278           ;
                mov     cs:w[SpritePos],ax       ; Bitmap position
                call    DiskSprite               ; Do disk cursor
                PopIt                            ; Restore all registers
                iret                             ; Return from interrupt.

ShowHelp:       PushIt                           ; Display help cursor.
                mov     ax,320*187+300           ;
                mov     cs:w[SpritePos],ax       ; Store bitmap position
                call    HelpSprite               ; Do help cursor
                PopIt                            ; Restore all registers
                iret                             ; Return from interrupt.

ScreenPos       dw      0                        ; Screen position
SpritePos       dw      0                        ; Bitmap position in memory
                                                 
MouseHandler:   PushIt                           ; Save all registers.
                push    cx                       ; 
                mov     ax,dx                    ; Work out screen position.
                mov     cx,320                   ;
                mul     cx                       ; AX=CX*AX
                pop     cx                       ;
                shr     cx,1                     ; Get correct X coordinate.
                add     ax,cx                    ; AX=AX+CX
                mov     cs:w[ScreenPos],ax       ; Save screen position.
                cmp     cs:b[MouseVisable],1     ; Is mouse visable.
                je      DisplayMouse             ; Yes, so update display.
                PopIt                            ; Restore all registers.
                retf                             ; Return far.

DisplayMouse:   cmp     cs:b[MouseCursor],1      ; Check which cursor is
                je      ArrowCursor              ; being used.
                cmp     cs:b[MouseCursor],2      ;
                je      DiskCursor               ;
                cmp     cs:b[MouseCursor],3      ;
                je      HelpCursor               ;
                PopIt                            ; Restore all registers.
                retf                             ; Return far.

ArrowCursor:    mov     ax,320*187+261           ; Display arrow cursor.
                mov     cs:w[SpritePos],ax       ; Store bitmap position
                call    ArrowSprite              ; Do arrow cursor
                PopIt                            ; Restore all registers
                retf                             ; Return far.

DiskCursor:     mov     ax,320*187+278           ; Display disk cursor
                mov     cs:w[SpritePos],ax       ; Store bitmap position
                call    DiskSprite               ; Do disk cursor
                PopIt                            ; Restore all registers
                retf                             ; Return far.

HelpCursor:     mov     ax,320*187+300           ; Display help cursor
                mov     cs:w[SpritePos],ax       ; Store bitmap position
                call    HelpSprite               ; Do help cursor
                PopIt                            ; Restore all registers
                retf                             ; Return far.

ArrowSprite:    call    Retrace                  ; Screen retrace
                call    RestoreCursor            ; Restore contents under cursor
                call    SaveCursor               ; Save contents under cursor
                call    DrawCursor               ; Draw cursor to screen
                ret                              ; Return to caller

DiskSprite:     call    Retrace                  ; Screen retrace
                call    RestoreCursor            ; Restore contents under cursor
                call    SaveCursor               ; Save contents under cursor
                call    DrawCursor               ; Draw cursor to screen
                ret                              ; Return to caller

HelpSprite:     call    Retrace                  ; Screen Retrace
                call    RestoreCursor            ; Restore contents under cursor
                call    SaveCursor               ; Save contents under cursor
                call    DrawCursor               ; Draw cursor to screen
                ret                              ; Return to caller
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Restore Old Data Under Cursor
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
OldScreenPos    dw      0                        ; Storage for old position.
RestoreFlag     db      0                        ; Storage for restore flag.
RestoreCursor:  cmp     cs:b[RestoreFlag],1      ; Check if restore flag set?
                jne     DontRestore              ; no, so don't restore
                mov     ds,cs                    ;
                lea     si,MouseBuffer           ; ds:si point to buffer
                mov     es,cs:w[VideoBuffer]     ; es = video buffer address
                mov     di,cs:w[OldScreenPos]    ; di = old screen position.
                mov     cx,11                    ; height of cursor
RestoreCursor1: push    cx                       ;
                mov     cx,15                    ; width of cursor
                repz    movsb                    ; block move
                sub     di,15                    ; reset pointer
                add     di,320                   ;
                pop     cx                       ;
                loop    RestoreCursor1           ; loop until cx=0
DontRestore:    ret                              ; Return from routine.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Save Old Data Under Cursor
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SaveCursor:     mov     cs:b[RestoreFlag],1      ; Set restore flag for later
                mov     si,cs:w[ScreenPos]       ; Get screen position 
                mov     ds,cs                    ; ds = code segment
                lea     di,MouseBuffer           ; ds:di point to buffer
                mov     ds,cs:w[VideoBuffer]     ; ds = Video buffer
                mov     es,cs                    ; es = code segment
                mov     cx,11                    ; height of cursor
SaveCursor1:    push    cx                       ;
                mov     cx,15                    ; width of cursor
                repz    movsb                    ; block move
                sub     si,15                    ; reset pointer
                add     si,320                   ;
                pop     cx                       ;
                loop    SaveCursor1              ; loop until cx=0
                mov     ax,cs:w[ScreenPos]       ; update cursor screen
                mov     cs:w[OldScreenPos],ax    ; position
                ret                              ; return from routine.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Draws cursor to screen
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DrawCursor:     mov     es,cs:w[VideoBuffer]     ; ES = video buffer address
                mov     ds,cs:w[ScreenSeg]       ; DS = Screen data
                mov     di,cs:w[ScreenPos]       ; DI = Cursor Screen position
                mov     si,cs:w[SpritePos]       ; SI = Cursor Memory position
                mov     cx,11                    ; heigh of cursor
DrawCursor2:    push    cx                       ;
                mov     cx,15                    ; width of cursor
DrawCursor3:    lodsb                            ; get byte in AL
                cmp     al,0                     ; is it black
                je      TransParent              ; yes, so don't display
                mov     es:[di],al               ; store byte on screen
TransParent:    inc     di                       ; point to next byte
                loop    DrawCursor3              ; loop until cx=0
                sub     di,15                    ; reset pointer
                sub     si,15                    ;
                add     si,320                   ;
                add     di,320                   ;
                pop     cx                       ;
                loop    DrawCursor2              ; loop until cx=0
                ret                              ; Return from routine

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure SetupMouse, Sets up the mouse and makes it ready for use.
;
; Notes: This routine will save the old interrupt vector and replace it
;        with my own. The reason for this is simple because I am re-writing
;        the Mouse Handler which displays a mouse pointer to a nice
;        256 colour cursor.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SetupMouse:     mov     ds,cs                    ; Initalise data segment.
                mov     ax,3533h                 ; Get interrupt 33h 
                int     21h                      ; Dos function.
                mov     w[OldInt33],bx           ; Save old int offset addr.
                mov     w[OldInt33+2],es         ; Save old int segment addr.
                mov     ax,2533h                 ; Set interrupt 33h
                lea     dx,NewInt33              ; DS:DX offset of handler.
                int     21h                      ; Dos function
                                                 ;
                xor     ax,ax                    ; Reset mouse driver.                       
                int     33h                      ; Mouse function.
                                                 ;
                mov     ax,000ch                 ; Set custom mouse handler.
                mov     cx,1                     ; Mouse movement only!
                mov     es,cs                    ; 
                lea     dx,MouseHandler          ; ES:DX offset of handler.
                int     33h                      ; Mouse function.
                mov     ax,7                     ; Set mouse cursor range.
                mov     cx,0                     ; X1
                mov     dx,610                   ; X2
                int     33h                      ; Mouse function
                mov     ax,8                     ; Set mouse cursor range.
                mov     cx,0                     ; Y1
                mov     dx,189                   ; Y2
                int     33h                      ; Mouse function.
                mov     ax,1                     ; Display mouse driver.
                int     33h                      ; Mouse function.
                mov     b[MouseCursor],1         ; Set mouse cursor to normal.
                mov     ax,4                     ;
                mov     cx,0                     ;
                mov     dx,0                     ;
                int     33h                      ; Mouse function.
                ret                              ; Return from procedure.
                                                 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; MOUSE FUNCTIONS, Use Microsoft Mouse Driver Interrupt 33h 
; 
; Notes: The Microsoft (tm) Mouse Driver has a quirk, in which it returns
;        double the correct value of the X Coordinate in Mode 13h. To solve
;        this, the X value is divided by two before it is stored!
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
MouseOn:        mov     ax,1                     ; Switch mouse on.
                int     33h                      ; Mouse driver function.
                ret                              ; Return.
MouseOff:       mov     ax,2                     ; Switch mouse off.
                int     33h                      ; Mouse driver function.
                ret                              ; Return
MousePos:       mov     ax,3                     ; Get mouse position.
                int     33h                      ; Mouse driver function.
                shr     cx,1                     ; cx=X, Divide X by 2
                mov     cs:w[MouseX],cx          ; Store X coordinate.
                mov     cs:w[MouseY],dx          ; Store Y coordinate.
                push    bx                       ; Save mouse button status.
                and     bx,1                     ; Is bit 0 set?
                jz      NotPressed1              ; No, so branch.
                mov     cs:b[LButton],1          ; Left button pressed.
NextPress:      pop     bx                       ; Restore button status.
                and     bx,2                     ; Is bit 1 set?
                jz      NotPressed2              ; No, so branch.
                mov     cs:b[RButton],1          ; Right button pressed.
                ret                              ; Return from procedure.
NotPressed1:    mov     cs:b[LButton],0          ; Left button not pressed.
                jmp     NextPress                ; Check Right button.
NotPressed2:    mov     cs:b[RButton],0          ; Right button not pressed.
                ret                              ; Return from procedure.
MousePause:     mov     ax,3                     ; Get Mouse Position.
                int     33h                      ; Mouse driver function.
                and     bx,1                     ; Is left button pressed?
                jnz     MousePause               ; Yes, so try again.
                mov     cs:b[LButton],0          ; Left button not pressed.
                ret                              ; Return from procedure.
                                                 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure DisableKBD, Disables keyboard to stop bogus input.
;
; Notes: PC's have a programmable interrupt controller IC which allows you to
;        stop IRQ's from occuring. To do this you simply mask out the bits
;        of that IRQ (Interrupt Request Line, Hardware interrupt!)
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DisableKBD:     in      al,21h                   ; Interrupt controller.
                or      al,2                     ; Mask off keyboard IRQ
                out     21h,al                   ; Send to chip.
                ret                              ; Return from procedure.
EnableKBD:      in      al,21h                   ; Get status 
                and     al,253                   ; Mask on keyboard IRQ
                out     21h,al                   ; Sent to chip
                ret                              ; Return from procedure.


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure ShutDown, Closes down the program and exits cleanly to DOS.
;
; Notes: This procedure will exit the program, restore the computer to its
;        original state and then exit cleanly. It displays a thank you
;        message on exit!
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
EndMsg          db      'Thanks For Using X-COPY PC',13,10,13,10
		db      'A-LEVEL Computer Project, (C)1995 Paul Adams - MATRIX DESIGN$'

ShutDown:       call    EnableKBD                ; Enable keyboard.
                mov     ax,3                     ; Clear screen.
                int     10h                      ; Video service.
                mov     ds,cs                    ; Initalise data segment.
                mov     es,w[ScreenSeg]          ; Free allocated memory.
                mov     ah,49h                   ; 
                int     21h                      ; Dos function.
                mov     es,w[MenuSeg]            ; Free allocated memory.
                mov     ah,49h                   ; 
                int     21h                      ; Dos function.
                mov     ds,cs:w[OldInt33+2]      ; 
                mov     dx,cs:w[OldInt33]        ;
                mov     ax,2533h                 ; Set interrupt vector.
                int     21h                      ; Dos function
                mov     ds,cs                    ;
                xor     ax,ax                    ; Turn mouse off.
                int     33h                      ;
                mov     ds,cs                    ;
                lea     dx,EndMsg                ; DS:DX -> Ascii string
                mov     ah,9                     ; Print string
                int     21h                      ; Dos function.
                mov     ah,4ch                   ; Exit to DOS.
                int     21h                      ;
                                                 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure Print, X-COPY Font Output Routine. Writes text to the screen.
;
; Notes: In mode 13h the text is large and blocky. It is difficult to read
;        and therefore I have draw a font to replace it. This is simply a
;        bitmap. This procedure simply translates the Ascii code to an 
;        offset in memory where the character is.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CharWidth       dw      4,4,4,4,4,4,4,4,3,4,4,4,5,4,4,4,4,4,4,5,4,5,5,5,5,5
CharOffset      dw      28,33,38,43,48,53,58,63,68,72,77,82,87,93,98,103,108
		dw      113,118,123,129,134,140,146,152
PunctOffset     dw      164,169,173,178,183,189,194,199,204,209
PunctWidth      dw      4,3,4,4,5,4,4,4,4,4
Punct2Offset    dw      216,0,0,0,0,0,0,230,233,0,240,0,236,228,0,0,0,0,0,0
		dw      0,0,0,0,0,223,225,0,244,0,219
Punct2Width     dw      1,0,0,0,0,0,0,2,2,0,3,1,3,1,0,0,0,0,0,0,0,0,0,0,0,1
		dw      2,0,4,0,3
			    
CurrentWidth    dw      0                        ; Width of font character
FinishPrint     db      0                        ;
GetChar:        mov     al,ds:[di]               ; Get char to print.
                cmp     al,65                    ; is it in limit?
                jb      Punct                    ; No, so check next limit
                sub     al,65                    ; scrap ascii weighting
                xor     ah,ah                    ; clear AH
                mov     bx,ax                    ; 
                shl     bx,1                     ; BX=BX*2 
                mov     si,cs:w[CharOffset+bx]   ; Get character offset
                mov     ax,191                   ; work out correct position
                mov     cx,320                   ; of bitmap in memory
                mul     cx                       ; AX=CX*AX
                add     si,ax                    ; si points to char in mem.
                mov     cx,cs:w[CharWidth+bx]    ; get character width
                inc     cx                       ; add a little
                mov     cs:w[CurrentWidth],cx    ; store character width
                ret                              ; Return to caller
Punct:          cmp     al,0                     ; Was it a terminator?
                je      HaltString               ; Yes, so end message
                cmp     al,13                    ; Was it a CR?
                je      NextLine                 ; Yes, so goto next line
                cmp     al,32                    ; Was it a space?
                je      Space                    ; Yes, so make space
                jmp     CheckPunct               ; jump to next check
                ret                              ; Return to caller
NextLine:       add     cs:w[PrintY],7           ; Point to next line
                mov     ax,cs:w[PrintY]          ;              
                mov     cx,320                   ; AX=CX*AX
                mul     cx                       ;
                add     ax,cs:w[PrintX]          ; Work out new position
                mov     cs:w[PrintPos],ax        ;
                inc     di                       ;
                jmp     GetChar                  ; Get char again.
HaltString:     mov     cs:b[FinishPrint],1      ; End printing of string.
                ret                              ; Return from caller.
Space:          mov     si,320*191+251           ; SI points to blank memory
                mov     cs:w[CurrentWidth],4     ; witdth of space char
                ret                              ; Return to caller.
CheckPunct:     cmp     al,57                    ; Is char a number?
                jbe     Numbers1                 ; Yes, so do numbers
                jmp     Punct2                   ; Next check
Numbers1:       cmp     al,48                    ; Is char in number range?
                jae     Numbers2                 ; Yes, so do numbers
                jmp     Punct2                   ; Next check
Numbers2:       sub     al,48                    ; Scrap ascii weighting
                xor     ah,ah                    ; clear AH
                mov     bx,ax                    ;
                shl     bx,1                     ; BX=BX*2
                mov     si,cs:w[PunctOffset+bx]  ; get char offset in memory
                mov     ax,191                   ; work out correct memory
                mov     cx,320                   ; location of bitmap
                mul     cx                       ; AX=AX*CX
                add     si,ax                    ;
                mov     cx,cs:w[PunctWidth+bx]   ;
                inc     cx                       ; Store address of char
                mov     cs:w[CurrentWidth],cx    ;
                ret                              ; Return to caller.
Punct2:         sub     al,33                    ; Scrap ascii weighting
                xor     ah,ah                    ; clear AH
                mov     bx,ax                    ;
                shl     bx,1                     ; BX=BX*2
                mov     si,cs:w[Punct2Offset+bx] ; get char offset in memory
                mov     ax,191                   ; work out correct location
                mov     cx,320                   ; of bitmap
                mul     cx                       ; AX=AX*CX
                add     si,ax                    ;
                mov     cx,cs:w[Punct2Width+bx]  ; Store address of char
                inc     cx                       ;
                mov     cs:w[CurrentWidth],cx    ;
                ret                              ; Return to caller
                                                 
PrintPos        dw      0                        ; Print position on screen
PrintX          dw      0                        ; X coordinate
PrintY          dw      0                        ; Y coordinate
Colour          db      0                        ; Colour of text
PrintMode       db      0                        ; Mode for printing
Print:          mov     ds,cs                    ;
                mov     cs:b[Colour],cl          ; Store colour.
                mov     di,dx                    ;
                push    ax                       ;
                mov     cs:w[PrintX],ax          ; Store X coord.
                mov     ax,bx                    ;
                mov     cs:w[PrintY],ax          ; Store Y coord.
                mov     cx,320                   ;
                mul     cx                       ; Create screen position
                mov     bx,ax                    ; 
                pop     ax                       ;
                add     ax,bx                    ;
                mov     cs:w[PrintPos],ax        ; Store actual screen pos.
                                                 ;
                mov     cs:b[FinishPrint],0      ; Reset finish print flag.
Print_:         mov     ds,cs                    ;
                call    GetChar                  ; Get char offset.
                cmp     cs:b[FinishPrint],1      ; Was it a terminator.
                je      EndPrint                 ; Yes, so exit print.
                                                 ;
                push    di                       ;
                mov     es,cs:w[VideoBuffer]     ; ES = screen buffer       
                mov     di,cs:w[PrintPos]        ; DI = Print position
                mov     ds,cs:w[ScreenSeg]       ; DS = Bitmap storage area
                mov     cx,6                     ; height of character
DrawChar:       push    cx                       ;
                mov     cx,cs:w[CurrentWidth]    ; get width of character
DrawChar1:      lodsb                            ; get byte from font char
                cmp     al,0                     ; is it black?
                je      DontPrint1               ; Yes, so dont print
                mov     al,cs:b[Colour]          ; get colour of font
                jmp     DoPrint1                 ; Print pixel of font char
DontPrint1:     cmp     cs:b[PrintMode],1        ; Check what print mode?
                je      DontPrint2               ; 0=Block print.
DoPrint1:       mov     es:[di],al               ; Print pixel of char
DontPrint2:     inc     di                       ; point to next pixel
                loop    DrawChar1                ; loop until cx=0
                sub     di,cs:w[CurrentWidth]    ; reset pointer
                sub     si,cs:w[CurrentWidth]    ;
                add     di,320                   ;
                add     si,320                   ;
                pop     cx                       ;
                loop    DrawChar                 ; loop until cx=0
                pop     di                       ;
                inc     di                       ;
                mov     ax,cs:w[CurrentWidth]    ; reset width
                add     cs:w[PrintPos],ax        ; point to next screen pos.
                jmp     Print_                   ; start over again.
EndPrint:       ret                              ; Return from procedure.
                                                 

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure DiskCounter, outputs the time and track to screen
;
; Notes: 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DiskTime        db      '00:00 ',0               ; Storage for Disk time
TrackCounter    db      '00 ',0                  ; Storage for track count
StartTime       dw      0                        ;

InitCounters:   mov     ah,2ch                   ; Get system time
                int     21h                      ; Dos function
                push    dx                       ;
                xor     ch,ch                    ; clear CH
                mov     ax,60                    ; Work out starting time.
                mul     cx                       ; AX=CX*AX
                pop     dx                       ;
                xor     dl,dl                    ; clear DL
                xchg    dl,dh                    ; Swap DL with DH
                add     ax,dx                    ; AX=AX+DX
                mov     cs:w[StartTime],ax       ; Store start time
                                                 ;
                mov     cs:b[DiskTime],'0'       ; Reset display varibles
                mov     cs:b[DiskTime+1],'0'     ;
                mov     cs:b[DiskTime+2],':'     ;
                mov     cs:b[DiskTime+3],'0'     ;
                mov     cs:b[DiskTime+4],'0'     ;
                mov     cs:b[TrackCounter],'0'   ;
                mov     cs:b[TrackCounter+1],'0' ;
                ret                              ; Return from caller.

DiskCounter:    PushIt                           ; Save all registers
                mov     ah,2ch                   ; Get system time
                int     21h                      ; Dos function
                push    dx                       ;
                xor     ch,ch                    ; Work out actual time
                mov     ax,60                    ; taken 
                mul     cx                       ;
                pop     dx                       ;
                xor     dl,dl                    ;
                xchg    dl,dh                    ;
                add     ax,dx                    ;
                cmp     ax,cs:w[StartTime]       ; Has time changed
                je      EndDiskTime              ; No, so skip display
                mov     cs:w[StartTime],ax       ; Update time display
                inc     cs:b[DiskTime+4]         ;
                cmp     cs:b[DiskTime+4],'9'     ;
                ja      ResetDiskTime1           ;
DiskMins:       mov     ax,279                   ; X
                mov     bx,177                   ; Y
                mov     cl,22                    ; Colour
                mov     ds,cs                    ;
                lea     dx,DiskTime              ; Display time
                call    Print                    ;
                mov     ax,191                   ;
                mov     bx,177                   ;
                mov     cl,22                    ;
                mov     ds,cs                    ;
                lea     dx,TrackCounter          ; Display Track
                call    Print                    ;
EndDiskTime:    PopIt                            ;
                ret                              ;
                                                 ;
		

ResetDiskTime1: mov     cs:b[DiskTime+4],'0'     ;
                inc     cs:b[DiskTime+3]         ;
                cmp     cs:b[DiskTime+3],'6'     ;
                jae     ResetDiskTime2           ;
                jmp     DiskMins                 ;
ResetDiskTime2: mov     cs:b[DiskTime+3],'0'     ;
                inc     cs:b[DiskTime+1]         ;
                jmp     DiskMins                 ;
                                                 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure ShowTime, outputs the time to screen
;
; Notes: 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Hours           db      0                        ;
Mins            db      0                        ;
Secs            db      0                        ;
Time            db      '00:00.00',0             ;
Hour1           db      'AM',0                   ;
Hour2           db      'PM',0                   ;
ShowTime:       PushIt                           ; Save all registers
                mov     ah,2                     ; Get time
                int     1ah                      ;
                mov     cs:b[Hours],ch           ; Store hours
                mov     cs:b[Mins],cl            ; Store minutes
                mov     cs:b[Secs],dh            ; Store seconds
                mov     ds,cs                    ;
                lea     di,Time                  ;
                mov     al,ch                    ;
                cmp     al,13h                   ; Is it in 24hour?
                jae     Convert24Hour            ; Yes, so convert to norm
                cmp     al,12h                   ; AM or PM?
                je      Sub1                     ; PM, so display PM
                push    di                       ;
                mov     ds,cs                    ;
                lea     dx,Hour1                 ;
                mov     bx,57                    ; X
                mov     ax,303                   ; Y
                mov     cl,22                    ; Colour
                call    Print                    ; Print time hour
                pop     di                       ;
                jmp     DisplayHour              ; Display hour
Convert24Hour:  sub     al,12h                   ;
                mov     cs:b[Hours],al           ;
Sub1:           push    di                       ;
                mov     ds,cs                    ;
                lea     dx,Hour2                 ;
                mov     bx,57                    ; X
                mov     ax,303                   ; Y
                mov     cl,22                    ; Colour
                call    Print                    ;  
                pop     di                       ;
                jmp     DisplayHour              ;
DisplayHour:    mov     ds,cs                    ;
                mov     al,cs:b[Hours]           ;
                xor     ah,ah                    ;
                shr     ax,4                     ;
                add     al,48                    ;
                mov     ds:[di],al               ;
                inc     di                       ;
                mov     al,cs:b[Hours]           ;
                xor     ah,ah                    ;
                shl     ax,4                     ;
                xor     ah,ah                    ;
                shr     ax,4                     ;
                add     al,48                    ;
                mov     ds:[di],al               ;
                inc     di                       ;
                inc     di                       ;
                ; Minutes                        ;
                mov     al,cs:b[Mins]            ; Get minutes
                xor     ah,ah                    ;
                shr     ax,4                     ; 
                add     al,48                    ;
                mov     ds:[di],al               ;
                inc     di                       ;
                mov     al,cs:b[Mins]            ;
                xor     ah,ah                    ;
                shl     ax,4                     ;
                xor     ah,ah                    ;
                shr     ax,4                     ;
                add     al,48                    ;
                mov     ds:[di],al               ;
                inc     di                       ;
                inc     di                       ;
                ; Seconds                        ;
                mov     al,cs:b[Secs]            ;
                xor     ah,ah                    ;
                shr     ax,4                     ;
                add     al,48                    ;
                mov     ds:[di],al               ;
                inc     di                       ;
                mov     al,cs:b[Secs]            ;
                xor     ah,ah                    ;
		shl     ax,4
		xor     ah,ah
		shr     ax,4
		add     al,48
		mov     ds:[di],al
		; Display Time
		lea     di,Time
		mov     al,ds:[di]
		cmp     al,48
		je      ResetTime
ContinueTime:   mov     ax,265
		mov     bx,57
		mov     cl,22
		mov     ds,cs
		lea     dx,Time
		call    Print
		PopIt
		ret
ResetTime:      mov     al,' '
		mov     ds:[di],al
		jmp     ContinueTime
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure Error, outputs an error message to screen
;
; Notes: After a disk operation an error may occur. In which case it should
;        be delt with. After each criticle disk operation this routine is
;        called. If there is no error it will simple return back to the
;        original process. If there is an error, then an error message will
;        be displayed and a flag will be set where the rest of the program
;        will detect and deal with, such as terminating the current routine
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Error:          mov     ds,cs                   ; Initalise DS
                mov     al,b[ErrorFlag]         ; Get error
                cmp     al,0                    ; did error occur?
                je      NoErrorFound            ; no, so exit.
                cmp     al,20h                  ; What error?
                jae     Errora                  ; TypeA
                                                ;
GotError:       call    ClearWindow             ; Clear message window
                xor     ah,ah                   ; clear AH
                dec     ax                      ;
                shl     ax,1                    ; make word.
                mov     bx,ax                   ; use error as index.
                mov     ds,cs                   ;
                mov     dx,w[ErrorTable+bx]     ; Get address of error msg.
                mov     ax,80                   ; X
                mov     bx,65                   ; Y
                mov     cl,21                   ; Colour
                call    Print                   ; Print error message
                mov     ds,cs                   ;
                mov     b[ErrorStatus],1        ; Set Error Status flag
                mov     b[Errorflag],0          ; Clear error flag.
ErrorWait:      call    MousePause              ; Mouse pause
ErrorWait2:     call    MousePos                ;  
                cmp     b[LButton],1            ;
                jne     ErrorWait2              ;
                call    MousePause              ;
                ret                             ; Return from procedure.
NoErrorFound:   mov     b[ErrorStatus],0        ; Clear error status
                ret                             ; Return from procedure.
Errora:         cmp     al,20h                  ; Work out correct error
                ja      Errorb                  ; status.
                mov     al,18                   ;
                jmp     GotError                ;
Errorb:         cmp     al,40h                  ;
                ja      Errorc                  ;
                mov     al,19                   ;
                jmp     GotError                ;
Errorc:         cmp     al,80h                  ;
                ja      NoErrorFound            ;
                mov     al,20                   ;
                jmp     GotError                ;
                                                
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure ClearWindow, Clears the help/message window.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ClearWindow:    mov     es,cs:w[VideoBuffer]     ; ES = Video buffer address        
                mov     ds,cs:w[ScreenSeg]       ; DS = Screen segment
                mov     di,320*58+68             ; DI = Screen address of
                mov     si,320*58+68             ; SI = Window    
                mov     cx,40                    ; Height of window to clear.
ClearWindow1:   push    cx                       ; Save Height.
                mov     cx,190 / 2               ; Width of window to clear.
                repz    movsw                    ; Block Move ds:si > es:di
                pop     cx                       ; Restore height
                loop    ClearWindow1             ; Loop until cx=0
                ret                              ; Return from procedure

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure InputBox, Displays and input box on screen and waits for input
; 
;
; Notes: This will create an input box on the screen and allow the user to
;        input data. 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
OutputChar      db      0,0
CursorX         dw      0
MaxInputLength  dw      0
InputBox:       call    EnableKBD                ; Enable keyboard.
                mov     cs:w[MaxInputLength],cx  ; Store max input length.
                push    ds                       ;
                push    di                       ;
                call    MouseOff                 ; Turn mouse off.
                mov     es,cs:w[VideoBuffer]     ; Retreive seg addr of VRAM.
                mov     ds,cs:w[MenuSeg]         ; Get seg addr of GFX data.
                lea     si,73*320+88             ; Source of input box in mem
                mov     di,87*320+50             ; Destination to place box.
                mov     cx,25                    ; Box Height.
DisplayInputBox:push    cx                       ;
                mov     cx,222                   ; Witdh of box.
                repz    movsb                    ; Block move.
                sub     di,222                   ; Reset DI
                sub     si,222                   ; Reset SI
                add     di,320                   ; Point to next row.
                add     si,320                   ; Point to next row.
                pop     cx                       ;
                loop    DisplayInputBox          ; Loop until CX=0
                                                 ;
                mov     cs:b[PrintMode],1        ; Select print mode 1.
                mov     ax,55                    ; X
                mov     bx,90                    ; Y
                mov     cl,21                    ; Colour
                mov     ds,cs                    ;
                lea     dx,EnterVolume           ; DS:DX -> Box message
                call    Print                    ; Print string.
                mov     cs:b[PrintMode],0        ; Reset print mode.
                mov     ax,55                    ; X
                mov     bx,100                   ; Y
                mov     cl,21                    ; Colour
                mov     ds,cs                    ;
                lea     dx,InputSpace            ; DS:DX -> String
                call    Print                    ; Print
                pop     di                       ;
                pop     ds                       ; ds:di = input buffer              
                mov     cs:w[CursorX],55         ; Cursor start.
                xor     bx,bx                    ;
ReadKeyLoop:    push    bx                       ;
                mov     ax,0                     ; Read keyboard
                int     16h                      ; ROM BIOS!
                pop     bx                       ;
                cmp     al,0dh                   ; Was enter key pressed?
                je      EnterKey                 ; Yes!
                cmp     ah,0eh                   ; Was backspace pressed?
                je      BackSpace                ; Yes!
                cmp     al,32                    ; Was space bar pressed?
                je      StoreChar                ; Yes!
                cmp     cs:w[MaxInputLength],bx  ; Have we reached MAX input?
                jbe     ReadKeyLoop              ; No to repeat.
                cmp     al,123                   ; Is char in range?
                jae     ReadKeyLoop              ; No, so repeat!
                cmp     al,97                    ;
                jae     TurnUpper                ; No, so repeat!
                cmp     al,90                    ;
                ja      ReadKeyLoop              ;
                cmp     al,65                    ; No, so repeat!
                jb      ReadKeyLoop              ;
                jmp     StoreChar                ; Store input and display.
EnterKey:       jmp     TerminateInput           ; Finish input.
StoreChar:      mov     ds:[di+bx],al            ; Store char in input buffer
                mov     cs:b[OutputChar],al      ; Setup char to output.
                inc     bx                       ; Point to next input space.
                call    DisplayChar              ; Display input char.
                mov     ax,cs:w[CurrentWidth]    ; Increment cursor.
                add     cs:w[CursorX],ax         ;
                jmp     ReadKeyLoop              ; Repeat again.
TurnUpper:      sub     al,32                    ; Turn to upper case.
                jmp     StoreChar                ; Store input and display.
BackSpace:      cmp     bx,0                     ; Are we at start of buffer?
                je      ReadKeyLoop              ; Yes, so start again.
                mov     cs:b[OutputChar],20h     ; Delete char.
                mov     al,ds:[di+bx-1]          ;
                cmp     al,20h                   ;
                je      DelSpace                 ;
                cmp     al,97                    ;
                jae     BackSpace3               ;
                sub     al,65                    ;
BackSpace2:     xor     ah,ah                    ;
                push    bx                       ;
                mov     bx,ax                    ;
                shl     bx,1                     ;
                mov     ax,cs:w[CharWidth+bx]    ;
                pop     bx                       ;
                inc     ax                       ;
BackSpace4:     sub     cs:w[CursorX],ax         ;
                call    DisplayChar              ;
                add     cs:w[CursorX],4          ;
                call    DisplayChar              ;
                sub     cs:w[CursorX],4          ;
                dec     bx                       ;
                mov     byte ptr ds:[di+bx],20h  ;
                jmp     ReadKeyLoop              ;
BackSpace3:     sub     al,97                    ;
                jmp     BackSpace2               ;
DelSpace:       mov     ax,4                     ;
                jmp     BackSpace4               ;
                                                 ;
TerminateInput: mov     es,cs:w[VideoBuffer]     ;
                mov     ds,cs:w[ScreenSeg]       ;
                mov     si,87*320+50             ;
                mov     di,si                    ;
                mov     cx,25                    ;
DestroyInputBox:push    cx                       ;
                mov     cx,222                   ;
                repz    movsb                    ;
                sub     di,222                   ;
                sub     si,222                   ;
                add     di,320                   ;
                add     si,320                   ;
                pop     cx                       ;
                loop    DestroyInputBox          ;
                call    MouseOn                  ;
                call    DisableKBD               ;
                ret                              ;

DisplayChar:    PushIt                           ; Save all registers.
                mov     ax,cs:w[CursorX]         ; Get cursor position.
                mov     bx,100                   ; Y
                mov     cl,21                    ; Colour
                mov     ds,cs                    ;
                lea     dx,OutPutChar            ; DS:DX -> Char to display.
                call    Print                    ; Print char.
                PopIt                            ; Restore all registers.
                ret                              ; Return to caller.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure Delay, Generate a short delay
;
; Notes: This a crude but good way of generating a delay. The program simply
;        goes in a loop until the counter has reached 0.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Delay:          mov     cx,20                    ; Counter=20
DelayLoop1:     push    cx                       ;
                mov     cx,0ffffh                ; Counter=ffffh
DelayLoop2:     loop    DelayLoop2               ; Loop until counter=0
                pop     cx                       ; Get back orig counter.
                loop    DelayLoop1               ; Loop until that is 0
                ret                              ; Return from procedure.

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure GetInput
;
; Notes: To check what icon has been clicked on, one must check the X and Y
;        values returned from the mouse with the icon position on the screen.
;        One way would be to check the mouse position with all icon positions
;        using seprate compares! This would be slow and make it a long 
;        routine. So I have devised a way of using a table of X and Y values
;        of the icons. The routine checks them and returns a value in AX
;        corresponding to the icon clicked on. 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
IconAmount      dw      0                        ; Number of icons
CurrentIcon     db      0                        ; Icon being checked
CheckButton     db      1                        ; Check button flag
GetInput:       mov     di,dx                    ; DS:DI points to table
                shl     bx,1                     ; BX=Number of icons
                mov     cs:w[IconAmount],bx      ; Store total icons.
                xor     bx,bx                    ; clear BX
                mov     cs:b[CurrentIcon],255    ;
                call    MousePos                 ; Get mouse position
                cmp     cs:b[CheckButton],0      ; Check button?
                je      SwitchOn                 ; No, so ignore mouse button
                mov     ax,cs:w[MouseX]          ; Get X coordinate
                jmp     GetInputa_               ;
SwitchOn:       mov     cs:b[LButton],1          ;
GetInputa_:     inc     cs:b[CurrentIcon]        ; Icon to check
                mov     ax,cs:w[MouseX]          ; Get X coordinate
                cmp     ax,cs:[di+bx]            ; Is it in range?
                ja      GetInputb                ; Yes, so check next
                add     bx,2                     ; Point to next icon
                cmp     bx,cs:w[IconAmount]      ; Have we done all icons?
                jb      GetInputa                ; No, so repeat
                xor     ax,ax                    ; Signal NO icons
                ret                              ; Return
GetInputa:      jmp     GetInputa_               ;
GetInputb:      push    bx                       ;
                add     bx,cs:w[IconAmount]      ; Next coordinate
                mov     ax,cs:w[MouseY]          ; Get Y coordinate of mouse
                cmp     ax,cs:[di+bx]            ; Is it in range?
                ja      GetInputc                ; Yes, so check next
                pop     bx                       ;
                add     bx,2                     ; Point to next icon
                cmp     bx,cs:w[IconAmount]      ; Have we done all icons?
                jb      GetInputa                ; No, so do again.
                xor     ax,ax                    ; Signal No icons
                ret                              ; Return
GetInputc:      add     bx,cs:w[IconAmount]      ; Next coordinate
                mov     ax,cs:w[MouseX]          ; Get X coordinate of mouse
                cmp     ax,cs:[di+bx]            ; Is it in range?
                jb      GetInputd                ; Yes, so check next
                pop     bx                       ;
                add     bx,2                     ; Point to next icon
                cmp     bx,cs:w[IconAmount]      ; Have we done them all?
                jb      GetInputa                ; No, so do again.
                xor     ax,ax                    ; Signal no icons
                ret                              ; Return
GetInputd:      add     bx,cs:w[IconAmount]      ; Point to next icon
                mov     ax,cs:w[MouseY]          ; Get Y coordinate of mouse
                cmp     ax,cs:[di+bx]            ; Is is in range?
                jb      GetInpute                ; Yes, so check next
                pop     bx                       ;
                add     bx,2                     ; Point to next icon
                cmp     bx,cs:w[IconAmount]      ; Have we done all icons?
                jb      GetInputa                ; No, so do again
                xor     ax,ax                    ; Signal no icons.
                ret                              ; Return
GetInpute:      pop     bx                       ; 
                cmp     cs:b[LButton],1          ; Check mouse button status
                je      GotInput                 ; Yes, its pressed.
                add     bx,2                     ; Point to next icon
                cmp     bx,cs:w[IconAmount]      ; Have we done all icons?
                jb      GetInputa                ; No, so do again
                xor     ax,ax                    ; Signal no icons
                ret                              ; Return
GotInput:       mov     al,cs:b[CurrentIcon]     ; Get icon that was selected
                mov     ah,0                     ;
                inc     al                       ; Make correct index
                mov     cs:b[LButton],0          ; Reset button
                ret                              ; Return
                                                 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; DiskMap Routines. The following routines control the use of the disk map.
; They are used within other routines to display graphically what is           
; happening to the disk. If an error occurs a red light appears in the
; appropiate part of the disk map. 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
MapStartX       dw      142                   
MapStartY       dw      114                   
CurrentX        dw      0                      
CurrentY        dw      0                     
MapSelect       db      0                      

DiskMap:        cmp     al,1  
		je      FillMap
		cmp     al,2
		je      FillMap
		cmp     al,3
		je      FillMap
		ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Fill the disk map.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
FillMap:        push    ax
		push    bx
		push    cx
		push    dx
		push    ds
		push    es
		push    di
		push    si
		pushf
		push    ax
		mov     ax,cs:w[MapStartX]
		mov     cs:w[CurrentX],ax
		mov     ax,cs:w[MapStartY]
		mov     cs:w[CurrentY],ax
		pop     ax
		mov     cx,8
FillLoop1:      push    cx
		mov     cx,10
FillLoop2:      push    cx
		call    DrawSignal
		add     cs:w[CurrentX],94
		call    DrawSignal
		sub     cs:w[CurrentX],94
		add     cs:w[CurrentX],8
		pop     cx
		loop    FillLoop2
		push    ax
		mov     ax,cs:w[MapStartX]
		mov     cs:w[CurrentX],ax
		pop     ax
		add     cs:w[CurrentY],8
		pop     cx                
		loop    FillLoop1
		call    ResetMap
		popf
		pop     si
		pop     di
		pop     es
		pop     ds
		pop     dx
		pop     cx
		pop     bx
		pop     ax
		ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Place a signal in the disk map
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PlaceSignal:    PushIt
		xor     cs:b[MapSelect],1
		cmp     cs:b[ErrorFlag],0
		ja      ErrorFound
		mov     al,2                
		jmp     PlaceSignal2
ErrorFound:     mov     al,3
PlaceSignal2:   cmp     cs:b[MapSelect],1
		je      Head0
		add     cs:w[CurrentX],94
		call    DrawSignal
		sub     cs:w[CurrentX],94
		add     cs:w[CurrentX],8
		jmp     PlaceSignal3
Head0:          call    DrawSignal
PlaceSignal3:   cmp     cs:w[CurrentX],222    
		jae     ResetCurrentX
		PopIt
		ret
ResetCurrentX:  mov     ax,cs:w[MapStartX]
		mov     cs:w[CurrentX],ax
		add     cs:w[CurrentY],8
		PopIt
		ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Draws the coloured signal on the screen
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DrawSignal:     push    ax
		mov     ax,cs:w[CurrentY]
		mov     cx,320
		mul     cx
		add     ax,cs:w[CurrentX]
		mov     di,ax
		mov     es,cs:w[VideoBuffer]
		mov     ds,cs:w[ScreenSeg]
		pop     ax
		cmp     al,1
		je      BlueSignal
		cmp     al,2
		je      GreenSignal
		cmp     al,3
		je      RedSignal
		ret
BlueSignal:     mov     si,320*193+4
		jmp     DrawSignalb
GreenSignal:    mov     si,320*193+20
		jmp     DrawSignalb
RedSignal:      mov     si,320*193+12
		jmp     DrawSignalb
DrawSignalb:    mov     cx,4
DrawSignalc:    push    cx
		mov     cx,5
		repz    movsb
		sub     di,5
		sub     si,5
		add     di,320
		add     si,320
		pop     cx
		loop    DrawSignalc
		ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Clears the Disk Map and Resets the values
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ClearDiskMap:   mov     es,cs:w[VideoBuffer]
		mov     di,320*111+138
		mov     si,320*111+138
		mov     ds,cs:w[ScreenSeg]
		mov     cx,75
ClearMapLoop:   push    cx
		mov     cx,178
		repz    movsb
		sub     di,178
		sub     si,178
		add     di,320
		add     si,320
		pop     cx
		loop    ClearMapLoop
ResetMap:       mov     ax,cs:w[MapStartX]
		mov     cs:w[CurrentX],ax
		mov     ax,cs:w[MapStartY]
		mov     cs:w[CurrentY],ax
		ret


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; File functions.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
EraseTemp:      mov     ds,cs                   ; Initalise data segment
                cmp     cs:b[Copies],1          ; Have all copies been made?
                ja      SkipErase               ; No, so don't erase.
                mov     ah,41h                  ; Erase file.
                lea     dx,TempFile             ; DS:DX = filename
                int     21h                     ; Dos function.
SkipErase:      ret                             ; Return from procedure.

CreateTemp:     mov     ax,3c02h                ; Create file.
                mov     cx,0                    ; Set file attribute.
                mov     ds,cs                   ; Initalise data segment.
                lea     dx,TempFile             ; ds:dx = filename
                int     21h                     ; Dos function.
                mov     cs:w[Handle],ax         ; Save file handle.
                ret                             ; Return from procedure.

OpenTemp:       mov     ah,3dh                  ; Open file.
                mov     al,0                    ; Set read mode.
                mov     ds,cs                   ; Initalise data segment.
                lea     dx,TempFile             ; ds:dx = filename.
                int     21h                     ; Dos function.
                mov     cs:w[Handle],ax         ; Save file handle.
                ret                             ; Return from procedure.

ReadTemp:       mov     ah,3fh                  ; Read file.
                mov     ds,cs                   ; Initalise data segment.
                mov     bx,cs:w[Handle]         ; Get file handle.
                mov     cx,cs:w[BufferSize]     ; Get number of bytes to read.
                lea     dx,Buffer               ; ds:dx = buffer
                int     21h                     ; Dos function.
                ret                             ; Return from procedure.

WriteTemp:      mov     ds,cs                   ; Initalise data segment.
                mov     ax,4000h                ; Write file.
                mov     bx,cs:w[Handle]         ; Get file handle.
                mov     cx,cs:w[BufferSize]     ; Get number of bytes to write
                lea     dx,Buffer               ; ds:dx = buffer
                int     21h                     ; Dos function
                ret                             ; Return from procedure.

CloseTemp:      mov     ds,cs                   ; Initalise data segment
                mov     ah,3eh                  ; Close file.
                mov     bx,cs:w[Handle]         ; Get file handle.
                int     21h                     ; Dos function.
                ret                             ; Return from procedure.

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Disk functions
;
; Notes: These functions are the routines that handle the disk at a lower
;        level than DOS. They use the BIOS which allows you to read/write
;        etc individual sectors of the disk.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
GetDiskSize:    mov     ah,02h                  ; Read disk sector
                mov     al,1                    ; Starting sector
                mov     ch,0                    ; track
                mov     cl,1                    ;
                mov     dh,0                    ; head
                mov     dl,cs:b[Drive]          ; drive
                mov     es,cs                   ;
                mov     ds,cs                   ;
                lea     bx,Buffer               ; ES:BX buffer to hold data
                int     13h                     ; Disk service BIOS
                mov     cs:b[ErrorFlag],ah      ; Store error status
                mov     al,cs:b[bx+15h]         ; Get disk size from boot
                mov     cs:b[DiskType],al       ; sector
                ret                             ; Return from caller



ReadDrive:      mov     ds,cs                   ;
                mov     es,cs                   ;
                mov     ah,2                    ; Read disk sector
                mov     al,cs:b[Sectors]        ; Number of sectors
                mov     ch,cs:b[Track]          ; Track number
                mov     cl,1                    ; Starting sector
                xor     cs:b[Head],1            ; Head
                mov     dh,cs:b[Head]           ;
                mov     dl,cs:b[Drive]          ; Drive
                lea     bx,Buffer               ; ES:BX buffer
                add     bx,di                   ; Add Index into buffer
                int     13h                     ; Disk service, BIOS
                mov     cs:b[ErrorFlag],ah      ; Store error flag
                ret                             ; Return

WriteDrive:     mov     ds,cs                   ;
                mov     es,cs                   ;
                mov     ah,3                    ; Write disk sector
                mov     al,cs:b[Sectors]        ; Number of sectors
                mov     ch,cs:b[Track]          ; Track number
                mov     cl,1                    ; Starting sector
                xor     cs:b[Head],1            ; Head
                mov     dh,cs:b[Head]           ;
                mov     dl,cs:b[Drive]          ; Drive
                lea     bx,Buffer               ; ES:BX buffer
                add     bx,di                   ; Add index into buffer
                int     13h                     ; Disk service, BIOS
                mov     cs:b[ErrorFlag],ah      ; Store error flag
                ret                             ; Return


ResetDrive:     mov     ah,02h                  ; Read disk sector
                mov     al,1                    ; Sector number
                mov     ch,0                    ; Track
                mov     cl,1                    ; Starting sector
                mov     dh,0                    ; Head
                mov     dl,cs:b[Drive]          ; Drive
                mov     es,cs                   ; ES:BX buffer
                mov     ds,cs                   ;
                lea     bx,Buffer               ;
                int     13h                     ; Disk service, BIOS
                mov     cs:b[ErrorFlag],ah      ; Store error flag
                mov     ah,0                    ; Reset drive
                mov     dl,cs:b[Drive]          ; Drive
                int     13h                     ; Disk service, BIOS
                ret                             ; Return


VerifyDrive:    mov     ds,cs                   ;
                mov     es,cs                   ;
                mov     ah,4                    ; Verify disk sector
                mov     al,cs:b[Sectors]        ; Number of sectors
                mov     ch,cs:b[Track]          ; Track
                mov     cl,1                    ; Starting sector
                xor     cs:b[Head],1            ; Head
                mov     dh,cs:b[Head]           ;
                mov     dl,cs:b[Drive]          ; Drive
                lea     bx,Buffer               ; ES:BX buffer
                add     bx,di                   ; Add index into buffer
                int     13h                     ; Disk services, BIOS
                mov     cs:b[ErrorFlag],ah      ; Store error flag.
                ret                             ; Return
		
ResetBuffer:    mov     ds,cs                   ;
                mov     es,cs                   ; ES:DI, DS:SI point to buffer
                lea     di,Buffer               ;
                lea     si,Buffer               ;
                mov     ax,0                    ; Data to store
                mov     cx,18*512*2             ; Size of buffer
                repz    stosb                   ; Block store
                ret                             ; Return
		

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure Menu, Start of main program where all menu bar choices are made.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
MenuIcons       dw      301,270,13,56,99,142,185,228,12,43,89
		dw      47,85,85,85,85,85,85,85,135,135,135                
		dw      310,310,52,95,138,181,224,267,36,67,120
		dw      55,93,93,93,93,93,93,93,160,160,160


Menu:           call    MouseOff                ; Turn mouse off.          
                call    ClearWindow             ; Clear message window.
                mov     ds,cs                   ; Initalise data segment.
                lea     dx,Ready                ; ds:dx = Message to print.
                mov     ax,80                   ; X
                mov     bx,65                   ; Y
                mov     cl,16                   ; Colour
                call    Print                   ; Print string.
                call    MouseOn                 ; Turn mouse on.
Menu_B:         mov     b[ErrorFlag],0          ; Reset ErrorFlag.
                mov     b[ErrorStatus],0        ; Reset ErrorStatus.
                call    Retrace                 ; Screen Retrace.
MenuLoop:       call    ShowTime                ; Display time.
                mov     ds,cs                   ; Initalise data segment.
                lea     dx,MenuIcons            ; ds:dx = MenuIcons
                mov     bx,11                   ; Number of icons.
                call    GetInput                ; Get mouse status.
                cmp     ax,0                    ; Was mouse clicked on icon? 
                je      MenuLoop                ; No, so start again. 
                mov     bx,ax                   ; BX = Option number. 
                dec     bx                      ;  
                shl     bx,1                    ; Make BX a word value.
                push    ax                      ; Save AX
                call    cs:w[OptionRoutines+bx] ; Call menu option in jump
                                                ; table.
                pop     ax                      ; Restore AX
                cmp     ax,9                    ; Check for restore mode.
                jae     Menu_B                  ; ..
                cmp     ax,5                    ; ..
                je      Menu_B                  ; ..
                cmp     ax,8                    ; ..
                je      Menu_B                  ; ..
                cmp     ax,7                    ; ..
                je      Menu_B                  ; ..
                jmp     Menu                    ; Do again.
                ret                             ;  

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure Initalise, Initalises varibles and checks for hardware errors.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Initalise:      mov     ds,cs                   ; Initalise data segment.
                mov     ah,19h                  ; Get current drive.
                int     21h                     ; Dos function.
                cmp     al,2                    ; Is it a hard drive (C:)
                jb      BadDrive                ; No, so exit with error.
                                                ;
                mov     ah,1ah                  ; Check for VGA card.
                int     10h                     ; Video function.
                cmp     al,1ah                  ; Is a VGA card present?
                je      NoVGA                   ; No, so exit with error.
                                                ;
                mov     ah,33h                  ; Check DOS version.
                mov     al,6                    ; 
                int     21h                     ; Dos function.
                cmp     bl,3                    ; Is DOS version =>3
                jb      BadDOS                  ; No, so exit with error.
                                                ;
                xor     ax,ax                   ; Get mouse driver status.
                int     33h                     ; Mouse function.
                cmp     ax,0000                 ; Is mouse installed?
                je      NoMouse                 ; No, so exit with error.
                jmp     Continue                ; Continue initalise.
                                                ;
BadDrive:       lea     dx,StartupError1        ; ds:dx = Error message.
                mov     ah,9                    ; Print string.
                int     21h                     ; Dos function.
                mov     ah,4ch                  ; Exit to DOS
                int     21h                     ;
NoVGA:          lea     dx,StartupError2        ; ..
                mov     ah,9                    ; ..
                int     21h                     ; ..
                mov     ah,4ch                  ; ..
                int     21h                     ; ..
BadDOS:         lea     dx,StartupError3        ; ..
                mov     ah,9                    ; ..
                int     21h                     ; ..
                mov     ah,4ch                  ; ..
                int     21h                     ; ..
NoMouse:        lea     dx,StartupError4        ; ..
                mov     ah,9                    ; ..
                int     21h                     ; ..
                mov     ah,4ch                  ; ..
                int     21h                     ; ..
                                                ;
Continue:       mov     ax,13h                  ; Set video mode to 320x200
                int     10h                     ; Video service.
                call    SetPalette              ; Set VGA colour palette.
                call    Display                 ; Display screen.
                ret                             ; Return from procedure.



;
; *** Menu option routines ***
;


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure VerifySwitch, Selects if data whould be verifed after writting.
;           
; Notes: It is safer to verify the data after a write operation. The reason
;        is the data might have been copied onto a bad sector or track. The
;        only drawback is it takes longer to copy a disk. 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
VerifySwitch:   call    MousePause
		xor     cs:b[Verify],1
		cmp     cs:b[Verify],1
		je      TurnVerifyOn
		mov     es,cs:w[VideoBuffer]
		mov     ds,cs:w[ScreenSeg]
		mov     si,320*111+44
		mov     di,320*111+92
		call    VerifyLight
		ret
TurnVerifyOn:   mov     es,cs:w[VideoBuffer]
		mov     ds,cs:w[ScreenSeg]
		mov     si,320*111+16
		mov     di,320*111+95
		call    VerifyLight
		ret
VerifyLight:    mov     cx,20
VerifyLight2:   push    cx
		mov     cx,20
		repz    movsb
		sub     di,20
		sub     si,20
		add     di,320
		add     si,320
		pop     cx
		loop    VerifyLight2
		ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure SelectA, Selects if disk is in A:
;           
; Notes: 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SelectA:        mov     cs:b[Drive],0 
		mov     es,cs:w[VideoBuffer]
		mov     ds,cs:w[ScreenSeg]
		mov     si,320*111+16
		mov     di,320*111+16
		mov     cx,20
SelectALight:   push    cx
		mov     cx,20
		repz    movsb
		sub     di,20
		sub     si,20
		add     di,320
		add     si,320
		pop     cx
		loop    SelectALight
		mov     es,cs:w[VideoBuffer]
		mov     ds,cs:w[ScreenSeg]
		mov     si,320*111+47
		mov     di,320*111+47
		mov     cx,20
SelectALight2:  push    cx
		mov     cx,20
		repz    movsb
		sub     di,20
		sub     si,20
		add     di,320
		add     si,320
		pop     cx
		loop    SelectALight2
		call    MousePause
		ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure SelectB, Selects if disk is in B:
;           
; Notes: 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SelectB:        mov     cs:b[Drive],1
		mov     es,cs:w[VideoBuffer]
		mov     ds,cs:w[ScreenSeg]
		mov     si,320*111+16
		mov     di,320*111+47
		mov     cx,20
SelectBLight:   push    cx
		mov     cx,20
		repz    movsb
		sub     di,20
		sub     si,20
		add     di,320
		add     si,320
		pop     cx
		loop    SelectBLight
		mov     es,cs:w[VideoBuffer]
		mov     ds,cs:w[ScreenSeg]
		mov     si,320*111+47
		mov     di,320*111+16
		mov     cx,20
SelectBLight2:  push    cx
		mov     cx,20
		repz    movsb
		sub     di,20
		sub     si,20
		add     di,320
		add     si,320
		pop     cx
		loop    SelectBLight2
		call    MousePause
		ret
;
;  Below are the individual routines for each menu option.
;
;

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure HelpMode, Interactive help mode option.
;           
; Notes: 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
HelpText        dw      HelpMsg1,HelpMsg2,HelpMsg3,HelpMsg4,HelpMsg5
		dw      HelpMsg6,HelpMsg7,HelpMsg8,HelpMsg9,HelpMsg10
		dw      HelpMsg11,HelpMsg12,HelpMsg13,HelpMsg14,HelpMsg14
		dw      HelpMsg15,HelpMsg16,HelpMsg17
DisplayClear    db      0
TextActive      db      0
HelpIcons       dw      6,69,263,13,56,99,141,186,228,271,11,43,89,141,233
		dw      158,252,1
		dw      47,58,58,85,85,85,85,85,85,85,134,134,134,113,113
		dw      178,178,1
		dw      65,315,315,52,95,138,181,224,267,304,36,66,116,220
		dw      314,219,313,318
		dw      83,82,65,93,93,93,93,93,93,93,160,160,160,177,177
		dw      183,183,42

HelpMode:       call    MouseOff
		mov     cs:b[MouseCursor],3
		call    ClearWindow
		mov     ds,cs
		lea     dx,HelpModeActive
		mov     ax,80
		mov     bx,60
		mov     cl,22
		call    Print
		call    MouseOn
		call    Delay
WaitLoop:       call    MousePos
		cmp     cs:b[LButton],1
		jne     WaitLoop
		call    ClearWindow
HelpLoop:       mov     ds,cs
		lea     dx,HelpIcons
		mov     bx,18
		mov     cs:b[CheckButton],0
		call    GetInput
		cmp     cs:b[RButton],1
		je      EndHelp
		cmp     ax,0
		je      ClearHelp
		dec     ax
		cmp     cs:b[TextActive],al
		je      HelpLoop
		push    ax
		call    MouseOff
		call    ClearWindow
		pop     ax
		mov     cs:b[TextActive],al
		shl     ax,1
		mov     bx,ax
		mov     ds,cs
		mov     dx,[HelpText+bx]
		mov     ax,70
		mov     bx,60
		mov     cl,22
		call    Print
		mov     cs:b[DisplayClear],0
		call    MouseOn
		call    Delay
		jmp     HelpLoop
ClearHelp:      cmp     cs:b[DisplayClear],1
		je      HelpLoop
		call    MouseOff
		call    ClearWindow
		mov     cs:b[DisplayClear],1
		call    MouseOn
		jmp     HelpLoop
EndHelp:        mov     cs:b[MouseCursor],1
		mov     cs:b[CheckButton],1
		ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure ReadDisk, Reads contents of disk ready for write operation
;           
; Notes: 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ReadDisk:       call    MouseOff
		call    ClearWindow
		mov     ds,cs
		lea     dx,CheckFAT
		mov     ax,80
		mov     bx,65
		mov     cl,9
		call    Print
		mov     al,1
		call    DiskMap

		; ERROR. Use first sector of disk to get media ID!
		call    ResetDrive
		mov     cs:b[ErrorFlag],0
		call    GetDiskSize
		call    Error
		cmp     cs:b[ErrorStatus],1
		je      FinishRead
		call    Delay
		call    ClearWindow
		cmp     cs:b[DiskType],0f0h
		je      ReadHD
		cmp     cs:b[DiskType],0f9h
		je      ReadDD
		mov     cs:b[ErrorFlag],22
		call    Error
		jmp     FinishRead

ReadHD:         mov     ds,cs
		lea     dx,Copy144
		mov     ax,80
		mov     bx,65
		mov     cl,9
		call    Print
		mov     cs:b[Track],1
		mov     cs:b[Sectors],18
		mov     cs:w[BufferSize],18432
		jmp     StartRead

ReadDD:         mov     ds,cs
		lea     dx,Copy720
		mov     ax,80
		mov     bx,65
		mov     cl,9
		call    Print
		mov     cs:b[Track],1
		mov     cs:b[Sectors],9
		mov     cs:w[BufferSize],9216
		jmp     StartRead

FinishRead:     call    ClearDiskMap
		cmp     cs:b[ErrorStatus],1
		je      DisplayReadResult
FinishRead2:    mov     cs:b[ErrorStatus],0
		mov     cs:b[ErrorFlag],0
		call    ClearDiskMap
		call    MouseOn
		mov     cs:b[DoWrite],1
		ret
DisplayReadResult:
		mov     ds,cs
		lea     dx,ReadError
		mov     ax,80
		mov     bx,65
		mov     cl,21
		call    Print
		jmp     FinishRead2
		
StartRead:      call    CreateTemp
		mov     cs:b[Track],0
		call    ResetBuffer     
		mov     cs:b[MouseCursor],2
		call    MouseOn

ReadLoop:       mov     di,0
		call    ReadDrive
		call    ReadErrors
		jc      ExitRead
		cmp     cs:b[Verify],1
		jne     SkipVerify1
		mov     di,0
		call    VerifyDrive
		call    ReadErrors
		jc      ExitRead
SkipVerify1:    call    MouseOff
		call    PlaceSignal
		call    MouseOn
		mov     di,18*512
		call    ReadDrive
		call    ReadErrors
		jc      ExitRead
		cmp     cs:b[Verify],1
		jne     SkipVerify2
		mov     di,18*512
		call    VerifyDrive
		call    ReadErrors
		jc      ExitRead
SkipVerify2:    call    MouseOff
		call    PlaceSignal
		call    MouseOn
		call    WriteTemp
		inc     cs:b[Track]
		cmp     cs:b[Track],80
		jb      ReadLoop
		call    CloseTemp
		jmp     FinishRead

ExitRead:       call    Error
		mov     cs:b[ErrorFlag],0
		mov     cs:b[ErrorStatus],0
		call    CloseTemp
		call    EraseTemp
		call    ClearDiskMap
		call    MouseOn
		ret

ReadErrors:     cmp     cs:b[ErrorFlag],0
		ja      RErrorsFound
		clc
		ret
RErrorsFound:   mov     cs:b[ErrorStatus],1
		cmp     cs:b[ErrorFlag],80h
		je      HaltRead
		clc
		ret
HaltRead:       stc
		ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure WriteDisk, 
;           
; Notes: 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
NoRead:         mov     ds,cs
		lea     dx,DoneNoRead
		mov     ax,80
		mov     bx,65
		mov     cl,9
		call    Print
		call    MouseOn
		call    Delay
		ret

WriteDisk:      call    MouseOff
		call    ClearWindow
		cmp     cs:b[DoWrite],1
		jne     NoRead
		mov     ds,cs
		lea     dx,CheckFAT
		mov     ax,80
		mov     bx,65
		mov     cl,9
		call    Print
		mov     al,1
		call    DiskMap

		call    ResetDrive
		mov     cs:b[ErrorFlag],0
		call    GetDiskSize
		call    Error
		cmp     cs:b[ErrorStatus],1
		je      FinishWrite
		call    Delay
		call    ClearWindow
		cmp     cs:b[DiskType],0f0h
		je      WriteHD
		cmp     cs:b[DiskType],0f9h
		je      WriteDD
		mov     cs:b[ErrorFlag],22
		call    Error
		jmp     FinishWrite

WriteHD:        mov     ds,cs
		lea     dx,Write144
		mov     ax,80
		mov     bx,65
		mov     cl,9
		call    Print
		mov     cs:b[Track],1
		mov     cs:b[Sectors],18
		mov     cs:w[BufferSize],18432
		jmp     StartWrite

WriteDD:        mov     ds,cs
		lea     dx,Write720
		mov     ax,80
		mov     bx,65
		mov     cl,9
		call    Print
		mov     cs:b[Track],1
		mov     cs:b[Sectors],9
		mov     cs:w[BufferSize],9216
		jmp     StartWrite

FinishWrite:    call    ClearDiskMap
		cmp     cs:b[ErrorStatus],1
		je      DisplayWriteResult
FinishWrite2:   mov     cs:b[ErrorStatus],0
		mov     cs:b[ErrorFlag],0
		call    ClearDiskMap
		call    MouseOn
		mov     cs:b[DoWrite],0         
		ret
DisplayWriteResult:
		mov     ds,cs
		lea     dx,WriteError
		mov     ax,80
		mov     bx,65
		mov     cl,21
		call    Print
		jmp     FinishWrite2
		
StartWrite:     call    OpenTemp
		mov     cs:b[Track],0
		call    ResetBuffer

WriteLoop:      call    ReadTemp
		mov     di,0
		call    WriteDrive
		call    WriteErrors
		jc      ExitWrite
		call    PlaceSignal

		mov     di,18*512
		call    WriteDrive
		call    WriteErrors
		jc      ExitWrite
		call    PlaceSignal

		inc     cs:b[Track]
		cmp     cs:b[Track],80
		jb      WriteLoop
		call    CloseTemp
		call    EraseTemp
		jmp     FinishWrite

ExitWrite:      call    Error
		mov     cs:b[ErrorFlag],0
		mov     cs:b[ErrorStatus],0
		call    CloseTemp
		call    ClearDiskMap
		call    MouseOn
		ret

WriteErrors:    cmp     cs:b[ErrorFlag],0
		ja      WErrorsFound
		clc
		ret
WErrorsFound:   mov     cs:b[ErrorStatus],1
		cmp     cs:b[ErrorFlag],80h
		je      HaltWrite
		cmp     cs:b[ErrorFlag],3
		je      HaltWrite
		clc
		ret
HaltWrite:      stc
		ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure CopiesSelect, Selects number of copies required from master disk
;           
; Notes: 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CopyIcons       dw      146,162,178
		dw      63,63,63
		dw      156,173,188
		dw      67,68,67
CopiesSelect:   mov     es,cs:w[VideoBuffer]
		mov     di,320*40+130
		mov     ds,cs:w[MenuSeg]
		mov     si,0*320+0
		mov     cx,33
DisplayCopyBox: push    cx
		mov     cx,73
		repz    movsb
		sub     si,73
		sub     di,73
		add     di,320
		add     si,320
		pop     cx
		loop    DisplayCopyBox
		call    DisplayCopies           
CopyLoop:       call    ShowTime
		mov     ds,cs
		lea     dx,CopyIcons
		mov     bx,3
		call    GetInput
		push    ax
		call    MousePause
		pop     ax
		cmp     ax,1
		je      IncreaseCopies
		cmp     ax,3
		je      DecreaseCopies
		cmp     ax,2
		jne     CopyLoop
		call    MouseOff
		mov     si,320*40+130
		mov     ds,cs:w[ScreenSeg]
		mov     di,si
		mov     cx,33
RestoreCopyBox: push    cx
		mov     cx,73
		repz    movsb
		sub     di,73
		sub     si,73
		add     di,320
		add     si,320
		pop     cx
		loop    RestoreCopyBox
		call    MouseOn
		ret

IncreaseCopies: cmp     cs:b[Copies],99
		je      MinCopies
		inc     cs:b[Copies]
		mov     ax,cs:w[CopyAmount]
		cmp     al,9
		je      ResetCopies1
		inc     al
IncCopies:      mov     cs:w[CopyAmount],ax
		call    DisplayCopies
		jmp     CopyLoop

ResetCopies1:   mov     al,0
		inc     ah
		jmp     IncCopies

DecreaseCopies: cmp     cs:b[Copies],1
		je      MaxCopies
		dec     cs:b[Copies]
		mov     ax,cs:w[CopyAmount]
		cmp     al,0
		je      ResetCopies2
		dec     al
decCopies:      mov     cs:w[CopyAmount],ax
		call    DisplayCopies
		jmp     CopyLoop

ResetCopies2:   mov     al,9
		dec     ah
		jmp     decCopies

MaxCopies:      mov     cs:b[Copies],99
		mov     ax,cs:w[CopyAmount]
		mov     al,9
		mov     ah,9
		mov     cs:w[CopyAmount],ax
		call    DisplayCopies
		jmp     CopyLoop
MinCopies:      mov     cs:b[Copies],1
		mov     ax,cs:w[CopyAmount]
		mov     al,1
		mov     ah,0
		mov     cs:w[CopyAmount],ax
		call    DisplayCopies
		jmp     CopyLoop

CopyString      db      '  ',0
DisplayCopies:  mov     ax,cs:w[CopyAmount]
		add     ah,48
		mov     ds,cs
		lea     di,CopyString
		mov     [di],ah
		add     al,48
		mov     ds,cs
		lea     di,CopyString
		mov     [di+1],al
		mov     ax,163
		mov     bx,51
		mov     cl,10
		mov     ds,cs
		lea     dx,CopyString
		call    Print
		ret                             

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure DiskInfo, Shows information about the disk
;           
; Notes: 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
InfoIcons       dw      121
		dw      41
		dw      132
		dw      49
DiskInfo:       call    MouseOff
;               call    GetDiskInfo
;               jc      EndDiskInfo
		mov     es,cs:w[VideoBuffer]
		mov     di,320*40+120
		mov     ds,cs:w[MenuSeg]
		mov     si,0*320+75
		mov     cx,60
DisplayInfoBox: push    cx
		mov     cx,116
		repz    movsb
		sub     si,116
		sub     di,116
		add     di,320
		add     si,320
		pop     cx
		loop    DisplayInfoBox
;               call    OutputDiskInfo
		call    MouseOn
InfoLoop:       call    ShowTime
		mov     ds,cs
		lea     dx,InfoIcons
		mov     bx,1
		call    GetInput
		cmp     ax,1
		jne     InfoLoop
		call    MouseOff
		mov     si,320*40+120
		mov     ds,cs:w[ScreenSeg]
		mov     di,si
		mov     cx,60
RestoreInfoBox: push    cx
		mov     cx,116
		repz    movsb
		sub     di,116
		sub     si,116
		add     di,320
		add     si,320
		pop     cx
		loop    RestoreInfoBox
		call    MouseOn
EndDiskInfo:    ret



;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure VerifyDisk, checks disks for erros
;           
; Notes: 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
VerifyDisk:     call    MouseOff
		call    ClearWindow
		mov     ds,cs
		lea     dx,CheckFAT
		mov     ax,80
		mov     bx,65
		mov     cl,9
		call    Print
		mov     al,1
		call    DiskMap

		call    ResetDrive
		mov     cs:b[ErrorFlag],0
		call    GetDiskSize
		call    Error
		cmp     cs:b[ErrorStatus],1
		je      FinishVerify
		call    Delay
		call    ClearWindow
		cmp     cs:b[DiskType],0f0h
		je      VerifyHD
		cmp     cs:b[DiskType],0f9h
		je      VerifyDD
		mov     cs:b[ErrorFlag],22
		call    Error
		jmp     FinishVerify

VerifyHD:       mov     ds,cs
		lea     dx,Verify144
		mov     ax,80
		mov     bx,65
		mov     cl,9
		call    Print
		mov     cs:b[Track],1
		mov     cs:b[Sectors],18
		mov     cs:w[BufferSize],18432
		jmp     StartVerify

VerifyDD:       mov     ds,cs
		lea     dx,Verify720
		mov     ax,80
		mov     bx,65
		mov     cl,9
		call    Print
		mov     cs:b[Track],1
		mov     cs:b[Sectors],9
		mov     cs:w[BufferSize],9216
		jmp     StartVerify

FinishVerify:   call    ClearDiskMap
		cmp     cs:b[ErrorStatus],1
		je      DisplayVerifyResult
FinishVerify2:  mov     cs:b[ErrorStatus],0
		mov     cs:b[ErrorFlag],0
		call    ClearDiskMap
		call    MouseOn
		mov     cs:b[DoWrite],1
		ret
DisplayVerifyResult:
		mov     ds,cs
		lea     dx,VerifyError
		mov     ax,80
		mov     bx,65
		mov     cl,21
		call    Print
		jmp     FinishVerify2
		
StartVerify:    mov     cs:b[Track],0
		call    InitCounters
		call    ResetBuffer

VerifyLoop:     mov     di,0
		call    DiskCounter
		call    VerifyDrive
		call    VerifyErrors
		jc      ExitVerify
		call    PlaceSignal
		mov     di,18*512
		call    DiskCounter
		call    VerifyDrive
		call    VerifyErrors
		jc      ExitVerify
		call    PlaceSignal
		inc     cs:b[Track]
		cmp     cs:b[Track],80
		jb      VerifyLoop
		jmp     FinishVerify

ExitVerify:     call    Error
		mov     cs:b[ErrorFlag],0
		mov     cs:b[ErrorStatus],0
		call    ClearDiskMap
		call    MouseOn
		ret

VerifyErrors:   cmp     cs:b[ErrorFlag],0
		ja      VErrorsFound
		clc
		ret
VErrorsFound:   mov     cs:b[ErrorStatus],1
		cmp     cs:b[ErrorFlag],80h
		je      HaltVerify
		clc
		ret
HaltVerify:     stc
		ret



;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure Format 
;           
; Notes: This procedure will handle formatting of the disks. It will display
;        a menu to give the user a choice to which disk format they
;        require.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
FormatIcons     dw      121,207,207             ;
                dw      41,54,81                ;
                dw      132,231,231             ;
                dw      49,79,106               ;
Format:         PushIt                          ; Save all registers MACRO!
                call    MousePause              ; Clean up mouse status.
                call    MouseOff                ; Switch mouse cursor off.
                mov     es,cs:w[VideoBuffer]    ; ES = Screen segment
                mov     di,320*40+120           ; DI = Screen position
                mov     ds,cs:w[MenuSeg]        ; DS = Menu data
                mov     si,0*320+193            ;
                mov     cx,72                   ; Height of window.
DisplayFormBox: push    cx                      ;
                mov     cx,116                  ; Width of window
                repz    movsb                   ; block move ds:si -> es:di
                sub     si,116                  ; Reset index
                sub     di,116                  ; ..
                add     di,320                  ; ..
                add     si,320                  ; ..
                pop     cx                      ;
                loop    DisplayFormBox          ;
                call    MouseOn                 ; Turn mouse on
FormatMenuLoop: call    ShowTime                ; Show time 
                mov     ds,cs                   ;
                lea     dx,FormatIcons          ;
                mov     bx,3                    ;
                call    GetInput                ; Check for mouse selection
                cmp     ax,1                    ; Did user cancel box?
                je      EndFormat               ; Yes, so end format.
                cmp     ax,2                    ; Did user select format?
                jae     StartFormat             ; Yes, so start format.
                jmp     FormatMenuLoop          ; Repeat
ClearFormatBox: call    MouseOff                ; Turn mouse off.
                mov     si,320*40+120           ;
                mov     ds,cs:w[ScreenSeg]      ;
                mov     di,si                   ;
                mov     cx,72                   ;
RestoreFormBox: push    cx                      ;
                mov     cx,116                  ;
                repz    movsb                   ; block move
                sub     di,116                  ;
                sub     si,116                  ;
                add     di,320                  ;
                add     si,320                  ;
                pop     cx                      ;
                loop    RestoreFormBox          ;
                call    MouseOn                 ; Turn mouse on.
                ret                             ; Return 
EndFormat:      call    ClearFormatBox          ; Remove window
                PopIt                           ; Restore all registers
                ret                             ; Return

StartFormat:    push    ax                      ;
                call    ClearFormatBox          ;
                call    ClearWindow             ;
                mov     ax,1                    ;
                call    FillMap                 ;
                pop     ax                      ;
                cmp     ax,2                    ;
                je      FormatHD                ;
                jmp     FormatDD                ;
FormatHD:       mov     ds,cs                   ;
                mov     ax,80                   ;
                mov     bx,65                   ;
                mov     cl,21                   ;
                lea     dx,Format144            ;
                call    Print                   ;
                mov     al,2                    ;
                jmp     StartOfForm             ;
FormatDD:       mov     ds,cs                   ;
                mov     ax,80                   ;
                mov     bx,65                   ;
                mov     cl,21                   ;
                lea     dx,Format720            ;
                call    Print                   ;
                mov     al,1                    ;
StartOfForm:    mov     cs:b[FormatSize],al     ;
                PopIt                           ;
                call    MouseOff                ;
                call    ResetDrive              ;
                call    ResetBuffer             ;
                cmp     cs:b[ErrorFlag],80h     ;
                je      EndFormatOption         ;
                mov     cs:b[ErrorFlag],0       ;
                mov     al,cs:b[FormatSize]     ;
                call    DoFormat                ;
                cmp     cs:b[ErrorStatus],1     ;
                je      ErrorsFound             ;
                call    ClearDiskMap            ;
                call    MouseOn                 ;
                ret                             ;
ErrorsFound:    call    ClearWindow             ;
                mov     ds,cs                   ;
                mov     ax,80                   ;
                mov     bx,65                   ;
                mov     cl,21                   ;
                lea     dx,FormatError          ;
                call    Print                   ;
                mov     ax,0                    ;
                int     16h                     ;
                call    ClearDiskMap            ;
                call    MouseOn                 ;
                ret                             ;
EndFormatOption:call    ClearDiskMap            ;
                call    Error                   ;
                ret                             ;
DoFormat:       dec     al                      ;
                xor     ah,ah                   ;
                mov     bx,ax                   ;
                shl     bx,1                    ;
                mov     es,cs                   ;
                mov     ds,cs                   ;
                mov     si,cs:w[ConfigTable+bx] ;
                lea     di,FmtType              ;
                mov     ds,cs                   ;
                mov     es,cs                   ;
                mov     cx,9                    ;
                rep     movsb                   ;
                                                ;
                                                ;
DF1:            mov     cs:b[CurTrack],1        ;
                mov     cs:b[CurHead],1         ;
                                                ;
                mov     ax,1818h                ;
                mov     ch,cs:b[TtlTracks]      ;
                dec     ch                      ;
                mov     cl,cs:b[TtlSectors]     ;
                mov     dx,0                    ;
                mov     dl,cs:b[Drive]          ;
                int     13h                     ;
                                                ;
                call    ChangeBPB               ;
		call    InitCounters
		mov     cs:b[MouseCursor],2
		call    MouseOn
FmtLoop:        call    DiskCounter
		call    FmtTrack

		mov     ah,03h
		mov     al,cs:b[TtlSectors]
		mov     ch,cs:b[CurTrack]       
		dec     ch
		mov     cl,1
		mov     dh,0
		mov     dl,cs:b[Drive]
		mov     ds,cs
		mov     es,cs
		lea     bx,Buffer
		int     13h
		mov     cs:b[ErrorFlag],ah

		call    MouseOff
		call    PlaceSignal
		call    DiskCounter
		call    MouseOn
		mov     ah,03h
		mov     al,cs:b[TtlSectors]
		mov     ch,cs:b[CurTrack]       
		dec     ch
		mov     cl,1
		mov     dh,1
		mov     dl,cs:b[Drive]
		mov     ds,cs
		mov     es,cs
		lea     bx,Buffer
		int     13h
		mov     cs:b[ErrorFlag],ah
		call    MouseOff
		call    PlaceSignal
		call    MouseOn
		call    AnyErrors
		jc      StopFormat

		inc     cs:b[CurTrack]
		mov     al,cs:b[CurTrack]
		cmp     al,cs:b[TtlTracks]
		jle     FmtLoop

		call    ResetBPB
		call    WriteFAT
		mov     ds,cs
		lea     di,VolumeName
		mov     cx,11
		call    InputBox
		call    WriteBoot
		call    WriteVolume
		call    MouseOff
		mov     cs:b[MouseCursor],1
		ret     

StopFormat:     call    ClearDiskMap
		call    Error
		mov     cs:b[ErrorStatus],0
		ret

FmtTrack:       mov     al,cs:b[CurTrack]
		dec     al
		mov     ah,cs:b[CurHead]                
FD_A:           mov     ds,cs
		mov     es,cs
		mov     cl,cs:b[TtlSectors]
		xor     ch,ch
		lea     bx,AddrField
FD_B:           mov     [bx],ax
		add     bx,4
		loop    FD_B

FD_C:           mov     ds,cs
		mov     es,cs
		lea     bx,AddrField
		mov     dx,[bx]
		mov     dl,cs:b[Drive] ; disk
		mov     ch,cs:b[CurTrack]
		dec     ch
		mov     cl,1
		mov     al,cs:b[TtlSectors]
		mov     ah,5
		int     13h
		mov     cs:b[ErrorFlag],ah
		
		mov     ds,cs
		xor     cs:b[CurHead],1
		cmp     cs:b[CurHead],0
		jz      FmtTrack
		ret




ChangeBPB:      mov     ax,351eh
		int     21h
		mov     cs:w[OldDBT+2],es
		mov     cs:w[OldDBT],bx
		mov     ds,cs
		lea     dx,NewDBT
		mov     ax,251eh
		int     21h
		mov     al,cs:b[TtlSectors]
		mov     cs:b[NewDBT+4],al
		mov     ah,0
		mov     dl,cs:b[Drive]
		int     13h
		ret
ResetBPB:       mov     ds,cs:w[OldDBT+2]
		mov     dx,cs:w[OldDBT]
		mov     ax,251eh
		int     21h
		mov     ah,0
		mov     dl,cs:b[Drive]
		int     13h
		ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; Write boot sector to disk
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
WriteBoot:      call    ResetBuffer
		xor     ah,ah
		mov     al,cs:b[SecPerClust]
		mov     cs:b[SecClust],al
		mov     al,cs:b[FATid]
		mov     cs:b[MediaId],al
		mov     al,cs:b[FATSectors]
		mov     cs:w[SecPerFAT],ax
		mov     al,cs:b[TtlSectors]
		mov     cs:w[SecPerTrack],ax
		mov     al,cs:b[DirEntries]
		mov     cs:w[RDEntries],ax
		xor     ah,ah
		xor     ch,ch
		mov     al,cs:b[TtlSectors]
		mov     cl,cs:b[TtlTracks]
		mul     cx
		xor     cx,cx
		mov     cl,cs:b[TtlHeads]
		mul     cx
		mov     cs:w[TotalSectors],ax
		mov     es,cs
		mov     ds,cs
		lea     di,Buffer
		lea     si,BootSector
		mov     cx,cs:w[EndBootSector]
		repz    movsb
		lea     di,Buffer
		add     di,510
		mov     al,55h
		mov     es:[di],al
		mov     al,0aah
		mov     es:[di+1],al
		lea     bx,Buffer
		mov     ah,3
		mov     al,1
		mov     ch,0
		mov     cl,1
		mov     dh,0
		mov     dl,cs:b[Drive]
		mov     ah,3
		int     13h
		mov     cs:b[ErrorFlag],ah
		ret
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; Write FAT
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
WriteFAT:       call    ResetBuffer
		mov     ds,cs
		lea     di,Buffer
		mov     al,cs:b[FATid]
		mov     dx,0ffffh
		mov     ds:[di],al
		mov     ds:[di+1],dx

		mov     es,cs
		lea     bx,Buffer
		mov     ah,3
		mov     al,cs:b[FATSectors]
		mov     ch,0
		mov     cl,2
		mov     dh,0
		mov     dl,cs:b[Drive]
		mov     ah,3
		int     13h
		mov     cs:b[ErrorFlag],ah

		mov     es,cs
		lea     bx,Buffer
		mov     ah,3
		mov     al,cs:b[FATSectors]
		mov     ch,0
		mov     cl,2
		mov     dh,1
		mov     dl,cs:b[Drive]
		mov     ah,3
		int     13h
		mov     cs:b[ErrorFlag],ah

		ret


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; Write volume name
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
WriteVolume:    call    ResetBuffer
		mov     ds,cs
		mov     es,cs
		lea     si,VolumeName
		lea     di,Buffer
		mov     cx,11
		repz    movsb
		lea     bx,Buffer
		mov     ah,3
		mov     al,1
		mov     ch,1
		mov     cl,2
		mov     dh,0
		mov     dl,cs:b[Drive]
		mov     ah,3
		int     13h
		mov     cs:b[ErrorFlag],ah
		ret

AnyErrors:      cmp     cs:b[ErrorFlag],0
		ja      FoundFErrors
		clc
		ret
FoundFErrors:   cmp     cs:b[ErrorFlag],80h
		je      HaltFormat
		cmp     cs:b[ErrorFlag],3
		je      HaltFormat
		mov     cs:b[ErrorStatus],1
		clc
		ret
HaltFormat:     stc
		ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; Boot Sector Structure
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
BootSector:     jmp     SHORT BootCode
                nop                             ;3 bytes normally for jump statement
                db      'XCOPY PC'              ;Format Program used        
                dw      512                     ;Bytes per sector
SecClust        db      01                      ;Sectors per cluster
ReservSect      dw      0001                    ;Reserved sectors
FatCopies       db      02                      ;Number of FAT copies
RDEntries       dw      00e0h                   ;Root directory entries
TotalSectors    dw      0b40h                   ;Total number of sectors
MediaId         db      0f0h                    ;DOS Media ID
SecPerFat       dw      0009                    ;Sectors per FAT
SecPerTrack     dw      0012h                   ;Sectors per track
TotalHeads      dw      0002                    ;Total number of heads
HiddenSectors   dd      00000000                ;Number of hidden sectors
                dd      00000000                ;Not used
                dw      0000                    ;Not used
                db      29h                     ;Boot record signiture
SerialID        dd      12345678                ;Disk serial number
VolumeName      db      11 dup(' ')             ;Volume label
                db      'FAT12   '              ;FAT type
BootCode:       mov     ax,7c0h                 ;Start of boot code
		mov     ds,ax
		mov     es,ax
		mov     ah,0fh
		int     10h
		push    ds
		mov     ds,cs
		lea     si,BootMsg
		pop     ds
		sub     si,279eh
MsgLoop:        mov     al,[si]
		cmp     al,0
		je      MsgDone
		mov     ah,0eh
		int     10h
		inc     si
		jmp     MsgLoop
MsgDone:        mov     ah,0
		int     16h
		mov     al,13
		mov     ah,0eh
		mov     al,10
		mov     ah,0eh
		int     10h
		mov     ax,3
		int     10h
		int     19h
BootMsg         db      13,10,13,10,13,10,13,10,13,10,13,10
		db      '                      Disk formated by X-COPY PC V3.01',13,10
		db      '                            (c)1995 Matrix Design',13,10
		db      '                       A-LEVEL Project by Paul Adams',13,10,13,10
		db      '      This is not a system disk. Please remove this disk and press a key',13,10,13,10,13,10
		db      '',0                         
		db      39 dup(' '),0
		;db     055h
		;db     0aah

EndBootSector   dw      $-BootSector

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Procedure Start, This is the main body of the program. Execution starts here
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Start:          call    Initalise                ; Initalise 
                mov     ax,80                    ; X
                mov     bx,60                    ; Y
                mov     cl,10                    ; Colour
                lea     dx,CopyrightMsg          ; dx=offset of message.
                call    Print                    ; Display message.
                call    Delay                    ; Delay.
                call    Delay                    ; Delay.
                call    Delay                    ; Delay.
                call    SetupMouse               ; Setup Mouse Driver.
                call    ClearWindow              ; Clear message window.
                call    ClearDiskMap             ; Clear disk map.
                call    DisableKBD               ; Disable the keyboard.
                call    Menu                     ; Load Menu
                call    ShutDown                 ; Shutdown program.
