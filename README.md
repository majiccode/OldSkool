#OldSkool

Dumping ground for some oldskool demoscene related stuff and things I did a long long time ago now dating from 1995 onwards I imagine. 
Most of these things of mine I found lying around on an old backup CD and so I thought I'd place them here in case they ever become interesting to someone in the future. You will notice my name or alias (frenzy) splattered around the code. In the 90's onwards I used that alias when coding BBS intros, cracks and so forth.

Most of it is for MSDOS and is written using Watcom C and Assembly language where I used A86 and Tasm. The source code is in keeping with a demoscene/hacking mentality.. Not clean, not ideal just works. A fine approach to self teaching you the skills of the hardcore hacker. I hope you understand the term hacker is used in the correct context :)

You'll find cracktros, bbs adverts, 3D engines with 3D Studio keyframing support (software), fake hicolour modes, vesa 2 stuff, protected mode stuff, 2D effects, and a load of misc routines that may or may not work. Fast maths functions like 1/sqrt using a 1k lookup table and plenty other gems. These tricks and so on are still handy today on different types of hardware! You would be surprised! Concepts like self modifying code, anti-debugging and so on litter the code so enjoy the trip down memory lane :-)

Where I can I include all exe's and resources so they can be run in DOSBOX. They do run as I captured screenshots for them.

Alot of them do run in DOSBOX just make sure you increase your clock cycle count to alter their run speed.. And make sure you put DOS4GW.EXE in the same directory. Not everything used that. Some used PMODE/W by TRAN!! Now that is a name from the past!

Note: Some of this stuff was targetted to 386 machines, some 486 and of course pentium so use the CTRL-F12 and CTRL-F11 keys to increase/decrease clock cycles otherwise some will run slow and others will run so fast you may not see anything!


###1kIntro
Intro under 1k featuring 2d bump map, fractal and tunnel effect. source in .ASM file, executable in .COM and readme in the .NFO

###BBS
Old BBS advert intros.. source in ASM and executables are .COM

###Exes
Old effects using an old 3D engine

###Fake Hicolour
Old plasma effect using XMODE to create a fake hicolour mode. source is in ASM but also in Pascal (.PAS) and executable!

###Intros
Some more old cractro style intros. lots of ASM source and exes to run.

###L3D
3d engine written in C with 3DS (3d studio) reader, keyframer, etc. Run the 'runme.bat' file with the name of the .3DS file to render and animate... only has a sub-pixel flat filler for debugging.. hence the multi-coloured triangles..

###LIBS
Some general interesting code

###Old Tutorials
Old html tutors I wrote about certain things relating to 3D graphics and algorithms

###Raytrace Tunnel
A realtime raytraced tunnel and infinite plane. used a grid and interpolation between grid points. Handy for lots of interesting things, not just raytracing.. interpolating grid points is a good speedup for lots of things :)
I couldnt find it but could for example at each point on the grid not just have a texel coordinate but you could also add some velocity vector and perform calculations on neighbourhood grid points with some curl noise to create a smoke effect perhaps? *hint*

###UART
Very early ASM code I wrote to talk to UART (serial port) back in the days when transferring files between computers was done via floppy disk and serial/parallel cables using tools like laplink!

###X-Copy
Based on the popular amiga X-Copy program (google it!) its a graphical disk copyier that I did a long long time ago for my A-Level computer science project. Its here because I actually found it on an old backup CD and its exactly 20 years old as of writing this document!!! Wow.. time flys when your coding assembler :)

![ALT_TEXT](/xcopy-pc.png?raw=true "XCOPY-PC screenshot")

##Screenshots:

![ALT_TEXT](/bbs-intro.png?raw=true "tesko.com")
![ALT_TEXT](/bbs-intro-2.png?raw=true "intro2.com")
![ALT_TEXT](/hack-intro.png?raw=true "intro.com")
![ALT_TEXT](/plasma.png?raw=true "plasma.com")
![ALT_TEXT](/2d-bumpmapping.png?raw=true "tesko.com")
![ALT_TEXT](/clothsim.png?raw=true "clothsim")
![ALT_TEXT](/dolphin-swim.png?raw=true "phong animated dolphin")
![ALT_TEXT](/water-duck.png?raw=true "water effect + gouraud shaded duck")
![ALT_TEXT](/rock-phong.png?raw=true "moprhing rock object + phong shaded texture mapping")
![ALT_TEXT](/l3d-1.png?raw=true "L3D engine")
![ALT_TEXT](/l3d-2.png?raw=true "L3D engine")
![ALT_TEXT](/l3d-3.png?raw=true "L3D engine")
![ALT_TEXT](/raytrace-tube.png?raw=true "Realtime raytracing")
![ALT_TEXT](/raytrace-plane.png?raw=true "Realtime raytracing")

Cheers,
paul .. aka frenzy

