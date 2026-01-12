#!/bin/bash -x

PROJECT="blink_v2"
avrdude -c avrisp -p 89s52 -P /dev/ttyACM0 -b 19200 -U flash:w:${PROJECT}.ihx:i

