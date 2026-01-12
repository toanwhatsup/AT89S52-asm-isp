; Standard 8051 Blink Program for sdas8051
; Target: AT89S52, Crystal: 11.0592 MHz

            .area   ABS (ABS,CON)   ; Define absolute memory area
            .org    0x0000          ; Reset vector
            ljmp    START           ; Jump to start

            .org    0x0030          ; Main program start
START:
            cpl     p1.0            ; Toggle LED on P1.0
            acall   DELAY           ; Wait
            sjmp    START           ; Loop forever

; Delay Routine
DELAY:
            mov     r7, #0x08       ; Outer loop
D1:         mov     r6, #0xFF       ; Middle loop
D2:         mov     r5, #0xFF       ; Inner loop
D3:         djnz    r5, D3          ; Decrement and jump
            djnz    r6, D2
            djnz    r7, D1
            ret

