#!/bin/bash -x

PROJECT="blink_v2"
avrdude -C /home/robert/Projects/AT89S52-asm-isp/blink/89s52.conf -c avrisp -p 89s52 -P /dev/ttyACM0 -b 19200 -U flash:w:${PROJECT}.ihx:i

