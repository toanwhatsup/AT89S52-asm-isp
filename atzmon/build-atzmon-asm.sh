#!/bin/bash -x

PROJECT="atzmon"

set -e

echo "Assembling..."
# Assemble the main file (which includes i2c_driver.asm and pcf8574_lcd.asm)
sdas8051 -losg $PROJECT.asm

echo "Linking..."
# -i: Intel Hex output
# -m: Map file
# -v: Verbose
# We only link atzmon.rel because the others are "included" inside it.
#sdld8051 -imv $PROJECT.rel
sdld -imv $PROJECT.rel

echo "Build successful! Created ${PROJECT}.ihx"

