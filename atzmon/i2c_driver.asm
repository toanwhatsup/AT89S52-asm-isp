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

