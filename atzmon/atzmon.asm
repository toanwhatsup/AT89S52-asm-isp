; =============================================================================
; ATZMON - 8051 Monitor Program (v1.0)
; A tribute to WOZMON on AT89S52
; Hardware: AT89S52, PCF8574 I2C Backpack, 1602A LCD
; Port Config: P0.0 = SCL, P0.1 = SDA (Requires external 4.7k pull-ups)
; Current Features: LED (P1.0), Buzzer (P0.7), I2C LCD (P0.0, P0.1)
; =============================================================================

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
    ; --- 0. System Warm-up ---
    acall LCD_INIT

    ; --- 1. TRUE Clear (0x01) ---
    mov   a, #0x01
    acall LCD_CMD
    
    ; --- 2. CRITICAL: Clear takes 1.52ms to 3ms ---
    mov   r7, #10
CLEAR_DELAY:
    acall LCD_DELAY_MS
    djnz  r7, CLEAR_DELAY

    ; --- 3. Force Home (0x02) - Reset cursor to index 0 ---
    mov   a, #0x02
    acall LCD_CMD
    acall LCD_DELAY_MS

    ; --- 4. Send 'A6' ---
    mov   a, #0x41      ; A
    acall LCD_DATA

    mov   a, #0x42      ; B
    acall LCD_DATA

    mov   a, #0x43
    acall LCD_DATA

    mov   a, #0x44
    acall LCD_DATA

    mov   a, #0x45
    acall LCD_DATA

    mov   a, #0x46
    acall LCD_DATA

    mov   a, #0x47
    acall LCD_DATA

    mov   a, #0x48
    acall LCD_DATA

    mov   a, #0x49
    acall LCD_DATA

    mov   a, #0x50
    acall LCD_DATA

    mov   a, #0x41
    acall LCD_DATA

    mov   a, #0x42
    acall LCD_DATA

    mov   a, #0x43
    acall LCD_DATA

    mov   a, #0x44
    acall LCD_DATA

    mov   a, #0x45
    acall LCD_DATA

    mov   a, #0x46
    acall LCD_DATA

    mov   a, #0x47
    acall LCD_DATA

    acall LCD_DELAY_MS

    ; --- 5. Move cursor to the start of the second line ---
;    mov   a, #0xB0      ; Command: 0x80 (Set DDRAM) + 0x40 (Line 2 offset)
    mov   a, #0xC0      ; Command: 0x80 (Set DDRAM) + 0x40 (Line 2 offset)
    acall LCD_CMD
    acall LCD_DELAY_MS

    ; --- Send 'B' to the second line ---
    mov   a, #0x42
    acall LCD_DATA
    
    clr   p1.0          ; Success LED
HERE:
    sjmp  HERE

; Bring in the I2C logic
.include "i2c_driver.asm"
.include "pcf8574_lcd.asm"
.include "utils.asm"

