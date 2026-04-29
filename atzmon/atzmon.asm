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
    
    ; If initialization worked, send 'A'
    mov   a, #'A'
    acall LCD_DATA
    
    clr   p1.0          ; Success LED
HERE:
    sjmp  HERE

; Bring in the I2C logic
.include "i2c_driver.asm"
.include "pcf8574_lcd.asm"
.include "utils.asm"

