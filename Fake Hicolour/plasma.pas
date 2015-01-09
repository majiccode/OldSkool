aPROGRAM hi_colour_plasma;

USES
  crt;

VAR
  a,b,c,i,j : integer;
  sintbl    : array[0..255] of integer;
  costbl    : array[0..255] of integer;
  x,y       : word;
  pos1,pos2 : integer;
  pos3,pos4 : integer;
  p1,p2,p3,p4 : integer;
  dir : integer;

procedure putpixel(x,y:word; r,g,b:byte); assembler; asm
  mov ax,0A000h; mov es,ax; mov bx,y; mov ax,bx; shl bx,6; shl ax,4;
  add bx,ax; add bx,x; mov al,r; mov es:[bx],al; mov al,g; add al,64;
  mov es:[bx+80],al; mov al,b; add al,128; mov es:[bx+80+80],al; end;

procedure dopal(c,r,g,b:byte); assembler; asm
  mov dx,3c8h; mov al,[c]; out dx,al; inc dx; mov al,[r]
  out dx,al; mov al,[g]; out dx,al; mov al,[b]; out dx,al; end;

procedure retrace; assembler; asm
  mov dx,3dah; @vert1: in al,dx; test al,8; jz @vert1 end;

procedure setmodex;assembler;
asm
  mov ax,0013h;
  int 10h;

  mov dx,3c4h;
  mov al,4;
  out dx,al;
  inc dx;
  in al,dx;
  and al,0f7h;
  or al,4h;
  out dx,al;
  dec dx;

  mov ax,0f02h;
  out dx,ax;
  mov ax,0a000h;
  mov es,ax;
  xor di,di;
  xor ax,ax;
  mov cx,0ffffh;
  cld;
  rep stosw;

  mov dx,3d4h;
  mov al,14h;
  out dx,al;
  inc dx;
  in al,dx;
  and al,0bfh;
  out dx,al;
  dec dx;
  mov al,17h;
  out dx,al;
  inc dx;
  in al,dx;
  or al,40h;
  out dx,al;

  mov dx,3d4h;
  mov al,9;
  out dx,al;
  inc dx;
  in al,dx;
  and al,01110000b;
  out dx,al;

  mov dx,03c4h;
  mov al,2;
  mov ah,00001111b; out dx,ax;
end;


begin
     for i := 0 to 255 do
     begin
      sintbl[i]:=round( sin(2*i*pi/128)*10 + sin(3*i*pi/128)*10 + sin(4*i*pi/128)*10 );
      costbl[i]:=round( cos(2*i*pi/128)*50 );
     end;

     setmodex;

     for c:=1 to 255 do begin
      dopal(c,0,0,0);
     end;

     for c:=1 to 31 do begin
         i:=0;
         j:=(c)*2;
         dopal(c+i,j,0,0);
         inc(i,31);
         dopal(c+i,63-j,0,0);
         inc(i,31);
         dopal(c+i,0,j,0);
         inc(i,31);
         dopal(c+i,0,63-j,0);
         inc(i,31);
         dopal(c+i,0,0,j);
         inc(i,31);
         dopal(c+i,0,0,63-j);
         inc(i,31);
         dopal(c+i,j,j,j);
         inc(i,31);
         dopal(c+i,63-j,63-j,63-j);
     end;


     i:=1; dir:=0; j:=0;

     repeat

     p1:=pos1;
     p2:=pos2;
     p3:=pos3;
     p4:=pos4;

     for y := 0 to 133 do begin
      for x := 0 to 79 do begin
        a:=costbl[byte(p1)] + costbl[byte(p2)] + costbl[byte(p3)] + costbl[byte(p4)];
        b:=sintbl[byte(a+p2)] + sintbl[byte(p1+p2)] + sintbl[byte(a+p3)] + sintbl[byte(p4-a)];
        c:=sintbl[byte(a+b)] + costbl[byte(a-b)] + sintbl[byte(x-y)] + costbl[byte(y+x)];
        putpixel(x,y*3,byte(a),byte(b),byte(c));
        p1:=p1+2;
        p2:=p2+1;
      end;

      p1:=pos3;
      p2:=pos4;
      p3:=p3+1;
      p4:=p4+1;


     end;

     pos1:=pos1+1;
     pos2:=pos3+2;
     pos3:=pos1+1;
     pos4:=pos2+1;


     retrace;

     until port[$60]=1;
     asm
        mov ax,3
        int 10h
     end;

 writeln('RUNTIME ERROR: (PASCAL SUX)');
 writeln;

 writeln('Woah. A 100% Pascal Pyscho Plasma.. Dont worry, I woz just testing sommat:)');
 writeln('(c)1996 Frenzy...');
 writeln('Flame me at:- p.adams@wlv.ac.uk');
 writeln;
end.
