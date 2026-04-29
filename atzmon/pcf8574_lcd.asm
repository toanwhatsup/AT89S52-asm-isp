; --- Write to PCF8574 pins ---
; Input: A = Byte to send to the PCF8574 pins
LCD_RAW_WRITE:
    push acc
    acall I2C_START
    mov   a, #LCD_ADDR  ; Device Address
    acall I2C_SEND
    pop   acc           ; Restore the data byte
    acall I2C_SEND      ; Update the PCF8574 output
    acall I2C_STOP
    ret

; --- Toggle Enable Pin (Strobe) ---
; Input: A = Current data on PCF pins
; This "strobes" the EN pin (P2) to lock in data
LCD_PULSE_EN:
push acc
    orl   a, #0x04      ; EN=1
    acall LCD_RAW_WRITE
    acall I2C_DELAY
    pop   acc
    push acc
    anl   a, #0xFB      ; EN=0
    acall LCD_RAW_WRITE
    pop   acc
    ret

; --- LCD Initialization (The "Magic" Sequence) ---
LCD_INIT:
    ; 1. Long wait for LCD internal reset (>40ms)
    mov   r7, #50
INIT_DELAY:
    acall LCD_DELAY_MS
    djnz  r7, INIT_DELAY

    ; 2. Force 8-bit mode (The "Shake Awake" sequense)
    ; We send 0x30 three times to reset the LCD controller
    mov   a, #0x38      ; D5,D4 high + Backlight
    acall LCD_RAW_WRITE
    acall LCD_PULSE_EN  ; Pulse 1
    mov   r7, #10
    djnz  r7, .         ; Small delay

    acall LCD_PULSE_EN  ; Pulse 2
    mov   r7, #10
    djnz  r7, .

    acall LCD_PULSE_EN  ; Pulse 3
    acall LCD_DELAY_MS

    ; 3. Switch to 4-bit mode (The 0x02 command)
    mov   a, #0x28      ; D5 high + Backlight
    acall LCD_RAW_WRITE
    acall LCD_PULSE_EN
    acall LCD_DELAY_MS

    ; 4. Final configuration (LCD_CMD for nibbles)
    mov   a, #0x28      ; 4-bit, 2 lines, 5x8 font
    acall LCD_CMD
    mov   a, #0x0C      ; Display ON, Cursor OFF
    acall LCD_CMD
    mov   a, #0x01      ; Clear display
    acall LCD_CMD
    ret

; --- Send Command (split into 2 nibbles) ---
LCD_CMD:
    push acc
    ; High Nibble
    anl   a, #0xF0
    orl   a, #0x08      ; RS=0, RW=0, Backlight=1
    acall LCD_RAW_WRITE
    acall LCD_PULSE_EN
    
    ; Low Nibble
    pop   acc
    swap  a
    anl   a, #0xF0
    orl   a, #0x08      ; RS=0, RW=0, Backlight=1
    acall LCD_RAW_WRITE
    acall LCD_PULSE_EN
    acall LCD_DELAY_MS
    ret

; --- Send Data (split into 2 nibbles) ---
LCD_DATA:
    push acc
    ; High Nibble
    anl   a, #0xF0
    orl   a, #0x09      ; Backlight=1, EN=1(start low), RS=1
;    acall LCD_RAW_WRITE
    acall LCD_PULSE_EN
    
    ; Low Nibble
    pop   acc
    swap  a
    anl   a, #0xF0
    orl   a, #0x09      ; Backlight=1, EN=1(start low), RS=1
;    acall LCD_RAW_WRITE
    acall LCD_PULSE_EN
    acall LCD_DELAY_MS
    ret

; --- Medium Delay for LCD Setup ---
LCD_DELAY_MS:
    push 0x06           ; Push address of R6 (Bank 0)
    push b
    mov  b, #2          ; Outer loop
LD_L1:
    mov  r6, #250       ; Inner loop (~500us at 12MHz)
    djnz r6, .          ; Jump to self until R6 is 0
    djnz b, LD_L1
    pop  b
    pop  0x06           ; Restore R6
    ret

