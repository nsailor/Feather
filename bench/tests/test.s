mov r1, #5
mov r2, #5
add r1, r1, r2 @ r1 should be equal to 10 (A)
add r1, r1, r2 @ r1 should be equal to 15 (F)
sub r1, r1, #3 @ r1 should be equal to 12 (C)
mov pc, #8
