; Standard 8051 Blink Program for sdas8051
; Target: AT89S52, Crystal: 11.0592 MHz
; LED wiring: "Sinking" (VCC → LED → Pin)

            .area   ABS (ABS,CON)   ; Define absolute memory area
            .org    0x0000          ; Reset vector
            ljmp    START           ; Jump to start

            .org    0x0030          ; Main program start
START:
            clr     p1.0            ; Set P1.0 = 0: LED ON
            mov     r7, #0x01       ; Outer loop
            acall   DELAY           ; Wait
            setb    p1.0            ; Set P1.0 = 1: LED OFF
            mov     r7, #0x01       ; Outer loop
            acall   DELAY           ; Wait

            clr     p0.7            ; Set P0.7 = 0: Buzzer ON
            mov     r7, #0x01       ; Outer loop
            acall   DELAY           ; Wait
            setb    p0.7            ; Set P0.0 = 1: Buzzer OFF
            mov     r7, #0x06       ; Outer loop
            acall   DELAY           ; Wait


            sjmp    START           ; Loop forever

; Delay Routine
DELAY:
;           mov     r7, #0x08       ; ~500ms delay at 11.0592MHz
D1:         mov     r6, #0xFF       ; Middle loop
D2:         mov     r5, #0xFF       ; Inner loop
D3:         djnz    r5, D3          ; Decrement and jump if not 0
            djnz    r6, D2
            djnz    r7, D1
            ret

