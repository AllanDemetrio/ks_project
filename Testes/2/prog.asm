;start
nop
nop
load r0 11
load r1 12
load r2 13
load r3 14
add r0 r0 r1	;Result R0 = 15
sub r1 r1 r2	;Result R1 = 2
and r2 r2 r3	;Result R2 = 2
or r3 r0 r3	;Result R3 = 10
halt
mem 10
mem 5
mem 3
mem 2
;end program