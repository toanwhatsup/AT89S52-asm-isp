#!/bin/bash -x

BAUD="19200"
CHIP="89s52"
PORT="/dev/ttyACM0"
PORT="/dev/ttyUSB0"
PROJECT="atzmon"

avrdude -c avrisp -p ${CHIP} -P ${PORT} -b ${BAUD} -U flash:w:${PROJECT}.ihx:i

