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
    orl   a, #0x04      ; Set EN (P2) High
    acall LCD_RAW_WRITE
    ; The EN pulse needs to be at least 450ns. 
    ; I2C_DELAY is perfect here.
    acall I2C_DELAY
    anl   a, #0xFB      ; Set EN (P2) Low
    acall LCD_RAW_WRITE
    ret

; --- LCD Initialization (The "Magic" Sequence) ---
LCD_INIT:
    ; 1. Power-on Wait (>15ms)
    mov   r7, #20
INIT_D1: acall LCD_DELAY_MS
    djnz  r7, INIT_D1

    ; 2. Force 8-bit mode (Pulse 1)
    mov   a, #0x38      ; D5,D4 high + Backlight
    acall LCD_RAW_WRITE
    acall LCD_PULSE_EN
    mov   r7, #5
INIT_D2: acall LCD_DELAY_MS
    djnz  r7, INIT_D2

    ; 3. Force 8-bit mode (Pulse 2)
    acall LCD_PULSE_EN
    acall LCD_DELAY_MS

    ; 4. Switch to 4-bit mode (The 0x02 command)
    mov   a, #0x28      ; D5 high + Backlight
    acall LCD_RAW_WRITE
    acall LCD_PULSE_EN
    acall LCD_DELAY_MS

    ; 5. Now in 4-bit mode, send standard commands
    mov   a, #0x28      ; 4-bit, 2 lines, 5x8 font
    acall LCD_CMD
    mov   a, #0x0C      ; Display ON, Cursor OFF
    acall LCD_CMD
    mov   a, #0x06      ; Entry mode: Auto-increment
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
    orl   a, #0x09      ; RS=1 (P0), RW=0, Backlight=1
    acall LCD_RAW_WRITE
    acall LCD_PULSE_EN
    
    ; Low Nibble
    pop   acc
    swap  a
    anl   a, #0xF0
    orl   a, #0x09      ; RS=1 (P0), RW=0, Backlight=1
    acall LCD_RAW_WRITE
    acall LCD_PULSE_EN
    acall I2C_DELAY     ; Data writes are faster than commands
    ret

; --- Medium Delay for LCD Setup (~2ms) ---
LCD_DELAY_MS:
    push b
    mov  b, #2
LD_L1:
    mov  r6, #250
    djnz r6, .          ; Tiny internal loop
    djnz b, LD_L1
    pop  b
    ret

