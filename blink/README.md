# PROGRAMMING NOTES

## Program memory:
**EA pin (31) switch program memory**
* EA to GND:
- Program fetches are directed to external memory.

* EA to VCC:
- Fetches from 0000H to 1FFFH: internal memory
- Fetches from 2000H to FFFFH: external memory.

## GPIO configuration:
* The 8051 has "Quasi-Bidirectional" ports.
* There is a very weak internal pull-up resistor
(around 50kΩ to 100kΩ).

* "Sourcing" (Pin → LED → GND):
- The pin is trying to push current through that weak internal resistor.
- It can only provide about 50 μA (microamps), which is barely enough to make a modern LED glow.

* "Sinking" (VCC → LED → Pin):
- When the pin goes LOW, it turns on a strong transistor (FET) that connects the pin directly to Ground.
- This can handle about 10mA to 20mA, which is plenty for a bright LED.
- Pin = 0: LED ON.
- Pin = 1: LED OFF.
```
EG: Sinking LED with 1kΩ resistor

Iled = (VCC - Vled) / R
     = ( 5V - 2V  ) / 1000
     ≈ 3 mA
```

## Delay math:
Standard 8051 takes 12 clock cycles to execute
one "machine cycle"(MC).

* With 11.0592 MHz crystal:
```
MC Frequency: 11,059,200 / 12 = 921,600 Hz.
MC Period   : ≈1.085 microseconds.
```
In assembly, the DJNZ instruction takes 2 MCs.
By changing the values in R7, R6, and R5, we are simply multiplying that 1.085µs time.

## Assembly description:
- cpl: Compliment Accumulator - toggle bit value
- clr: Clear Accumulator - set bit value to 0
- setb: Set Bit - set bit value to 1
- djnz: Decrement and Jump if Not Zero
- ljmp: Long Jump
- sjmp: Short Jump
- acall: Absolute Call
- mov: Move byte variable

