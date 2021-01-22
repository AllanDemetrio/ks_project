;start
nop
nop
load r0 13 ;R0 = 5
load r1 12 ;R1 = 10
sub r2 r0 r1	;R2 = R0 - R1	Levanta Flag de Negativo
bneg 10		;Salta para o laço que vai dar zero
halt
add r0 r0 r2;	;Levanta Flag de Zero
bzero 10	;Salta para Store
halt
store 16 r0	;Dá um Store só para verificarmos se ele salta no bzero
halt
mem 10
mem 5
mem 3
mem 2
;end program