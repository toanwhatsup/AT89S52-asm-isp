#!/bin/bash

# Configuration
PROJECT="blink_v2"
PORT="/dev/ttyACM0"
BAUD="19200"
CHIP="89s52"

# 1. Clean previous builds
echo "--- Cleaning up ---"
rm -f ${PROJECT}.ihx ${PROJECT}.rel ${PROJECT}.lst ${PROJECT}.sym ${PROJECT}.map ${PROJECT}.mem

# 2. Assemble
echo "--- Assembling ${PROJECT}.asm ---"
if ! sdas8051 -los ${PROJECT}.asm; then
    echo "ERROR: Assembly failed!"
    exit 1
fi

# 3. Link
echo "--- Linking ---"
if ! sdld -i ${PROJECT}.rel; then
    echo "ERROR: Linking failed!"
    exit 1
fi

# 4. Flash
echo "--- Flashing to AT89S52 ---"
if avrdude -c avrisp -p ${CHIP} -P ${PORT} -b ${BAUD} -U flash:w:${PROJECT}.ihx:i; then
    echo "--- SUCCESS! ---"
    # Optional: Remove temp files after successful flash
    rm -f ${PROJECT}.rel ${PROJECT}.lst ${PROJECT}.sym ${PROJECT}.map
else
    echo "ERROR: Flashing failed!"
    exit 1
fi

