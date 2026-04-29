#!/bin/bash

# Configuration
PROJECT="atzmon"
PORT="/dev/ttyACM0"
PORT="/dev/ttyUSB0"
BAUD="19200"
CHIP="89s52"
CONF_8051="/home/robert/Projects/AT89S52-asm-isp/89s52.conf"

# 1. Clean previous builds
echo "--- Cleaning up ---"
rm -f ${PROJECT}.ihx ${PROJECT}.rel ${PROJECT}.lst ${PROJECT}.sym ${PROJECT}.map ${PROJECT}.mem

