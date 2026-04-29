; ATZMON - System Monitor for AT89S52
; A tribute to WOZMON on AT89S52
; Current Features: LED (P1.0), Buzzer (P0.7), I2C LCD (P0.0, P0.1)

; --- Hardware Mapping ---
LED     .equ P1.0
BUZZER  .equ P0.7

; --- Constant Definitions ---
LCD_ADDR .equ 0x4E   ; Change to 0x7E if your backpack uses a different address

; --- Includes ---
    .include "i2c_driver.inc"

; --- MAIN ---
    .area ABS (ABS,CON)
    .org  0x0000
    ljmp  START

    .org  0x0030
START:
    acall LCD_INIT

    mov   a, #0x02      ; Command: Clear Display
    acall LCD_CMD

    mov   r7, #5        ; Clear needs a long delay
    acall DELAY         ; Use your R7-based loop if needed

CLEAN_WAIT:
    acall LCD_DELAY_MS
    djnz  r7, CLEAN_WAIT

    mov   a, #0x80      ; Command: Force Cursor to Line 1, Pos 0
    acall LCD_CMD
    acall LCD_DELAY_MS

    mov   a, #0x41      ; ASCII for 'A'
    acall LCD_DATA

    clr   p1.0          ; Success LED
HERE:
    sjmp  HERE

; Bring in the I2C logic
.include "i2c_driver.asm"
.include "pcf8574_lcd.asm"
.include "utils.asm"

; i2c_driver.asm - I2C Bit-Banging Primitives

; --- Tiny Delay ---
I2C_DELAY:
    nop
    nop
    ret

; --- Start Condition ---
I2C_START:
    setb SDA
    setb SCL
    acall I2C_DELAY
    clr  SDA
    acall I2C_DELAY
    clr  SCL
    ret

; --- Stop Condition ---
I2C_STOP:
    clr  SDA
    acall I2C_DELAY
    setb SCL
    acall I2C_DELAY
    setb SDA
    acall I2C_DELAY
    ret

; --- Send Byte (Input: Acc) ---
I2C_SEND:
    push b
    mov  b, #8
I2C_BIT_LOOP:
    rlc  a              ; MSB first
    mov  SDA, c
    acall I2C_DELAY
    setb SCL
    acall I2C_DELAY
    clr  SCL
    djnz b, I2C_BIT_LOOP
    
    ; ACK Phase
    setb SDA            ; Release for Slave
    acall I2C_DELAY     ; Important to delay Clock pull
    setb SCL
    acall I2C_DELAY
    mov  c, SDA         ; Capture ACK in Carry bit
    clr  SCL
    pop  b
    ret

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

; --- Medium Delay for LCD Setup ---
LCD_DELAY_MS:
    push b
    push 06h            ; Save R6
    mov  b, #2          ; Outer loop
LD_L1:
    mov  r6, #250       ; Inner loop (~500us at 12MHz)
    djnz r6, .          ; Jump to self until R6 is 0
    djnz b, LD_L1
    pop  06h            ; Restore R6
    pop  b
    ret

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

