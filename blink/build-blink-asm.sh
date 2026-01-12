#!/bin/bash -x

#sdas8051 -o blink.asm

PROJECT="blink_v2"

set -e

echo "Assembling..."
sdas8051 -los $PROJECT.asm

echo "Linking..."
# -m: Generate a map file (useful for debugging)
# -i: Output Intel Hex (.ihx)
# -v: Verbose
sdld -i $PROJECT.rel

#sdld8051 -i $PROJECT.rel

echo "Build successful!"

