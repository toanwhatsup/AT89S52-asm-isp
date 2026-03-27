# AT89S52 Assembly & ISP Development
> **"Dive into the mystical world of 8-bit microcontroller with Assembly and ISP"**

This project demonstrates how to set up a professional 8051 development environment using an **Arduino Mega 2560** as an ISP programmer, an **AT89S52** as the target, and **Arch Linux** as the host OS.

## 🛠 Hardware Setup

### 1. The AT89S52 Minimum System
To "wake up" the 8051, the following connections are mandatory:
* **VCC (Pin 40):** +5V
* **GND (Pin 20):** Common Ground with Arduino.
* **EA/VPP (Pin 31):** Must be tied to **+5V** to execute internal flash code.
* **Clock:** 11.0592 MHz crystal across Pins 18 & 19, with two 33pF ceramic capacitors closest to GND. Pin 19 (XTAL1) capacitor should take the shortest path to Pin 20 (GND). Local GND plane and Guard ring around oscillator should also be considered while designing the PCB.
* **Reset (Pin 9):** 10µF capacitor to +5V and 10kΩ pull-down resistor to GND (during runtime).

### 2. ISP Wiring
#### Arduino Mega to AT89S52
| Function  | Arduino Mega Pin | AT89S52 Pin |
| :---      | :---             | :---        |
| **MOSI**  | 51               | 6 (P1.5)    |
| **MISO**  | 50               | 7 (P1.6)    |
| **SCK**   | 52               | 8 (P1.7)    |
| **Reset** | 10               | 9 (RST)     |

#### Arduino Nano to AT89S52
| Function  | Arduino Nano Pin | AT89S52 Pin |
| :---      | :---             | :---        |
| **MOSI**  | 11               | 6 (P1.5)    |
| **MISO**  | 12               | 7 (P1.6)    |
| **SCK**   | 13               | 8 (P1.7)    |
| **Reset** | 10               | 9 (RST)     |

### 3. Preventing Auto-Reset
Connect a **10µF capacitor** between the Arduino Mega's **RESET** and **GND** pins *after* uploading the ArduinoISP sketch.
This prevents the Mega from rebooting when `avrdude` opens the serial port.

---

## 💻 Software Setup (Arch Linux)

### 1. Install Toolchain
```bash
sudo pacman -S sdcc avrdude
```

### 2. Permission
Add your user to the `uucp` and `lock` groups to access `/dev/ttyACM0`:
```
sudo usermod -aG uucp,lock $USER
# Log out and log back in for changes to take effect
```

### 3. Programmer Setup
1. Open the Arduino IDE.
2. Load the ArduinoISP example sketch.
3. Upload it to your Arduino Mega 2560.
4. The Mega is now an AVRISP-compatible programmer running at 19200 baud.

---

## 🚀 Build & Flash Workflow

### Assembly Syntax (SDAS8051)
Note that `sdas8051` requires specific directives:

* Directives start with a dot (e.g., `.org`, `.area`).
* Code must be placed in an absolute area: `.area ABS (ABS,CON)`.

### Commands
**To build and flash in one go:**
```
./run.sh
```

**Manual Build Steps:**
```
# Assemble (generates .rel)
sdas8051 -los blink_v2.asm

# Link (generates .ihx)
sdld -i blink_v2.rel

# Flash
avrdude -c avrisp -p 89s52 -P /dev/ttyACM0 -b 19200 -U flash:w:blink_v2.ihx:i
```
---

## 💡 Troubleshooting

* **FF FF FF Signature:** Check your crystal connection and ensure Pin 31 (EA) is at 5V.
* **Programmer not responding:** Ensure the 10µF capacitor is on the Arduino's Reset pin.
* **Dim LED:** 8051 ports are weak at sourcing current. Connect the LED Cathode to the Pin and the Anode to a 10k resistor to 5V (Sinking mode).

