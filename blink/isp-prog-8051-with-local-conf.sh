#!/bin/bash -x

BAUD="19200"
CHIP="89s52"
PORT="/dev/ttyACM0"
PORT="/dev/ttyUSB0"
PROJECT="blink_v2"
avrdude -C /home/robert/Projects/AT89S52-asm-isp/blink/89s52.conf -c avrisp -p ${CHIP} -P ${PORT} -b ${BAUD} -U flash:w:${PROJECT}.ihx:i

