#!/bin/bash -x

BAUD="19200"
CHIP="89s52"
PORT="/dev/ttyACM0"
PORT="/dev/ttyUSB0"
PROJECT="atzmon"
CONF_8051="/home/robert/Projects/AT89S52-asm-isp/89s52.conf"

avrdude -C ${CONF_8051} -c avrisp -p ${CHIP} -P ${PORT} -b ${BAUD} -U flash:w:${PROJECT}.ihx:i

