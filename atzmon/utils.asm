; --- Utilities ---

; Delay Routine
DELAY:
;    mov     r7, #0x08       ; ~500ms delay at 11.0592MHz
D1: mov     r6, #0xFF       ; Middle loop
D2: mov     r5, #0xFF       ; Inner loop
D3: djnz    r5, D3          ; Decrement and jump if not 0
    djnz    r6, D2
    djnz    r7, D1
    ret

