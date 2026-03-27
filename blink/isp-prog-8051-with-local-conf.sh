#!/bin/bash -x

BAUD="19200"
CHIP="89s52"
PORT="ttyACM0"
PORT="ttyUSB0"
PROJECT="blink_v2"
avrdude -C /home/robert/Projects/AT89S52-asm-isp/blink/89s52.conf -c avrisp -p ${CHIP} -P /dev/${PORT} -b ${BAUD} -U flash:w:${PROJECT}.ihx:i

