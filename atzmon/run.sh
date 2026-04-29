# Configuration
BAUD="19200"
CHIP="89s52"
PORT="/dev/ttyUSB0"  # Set to your active serial port USB0/ACM0
PROJECT="atzmon"
CONF_8051="/home/robert/Projects/AT89S52-asm-isp/89s52.conf"

# 1. Clean previous builds
echo "--- Cleaning up ---"
rm -f *.ihx *.rel *.lst *.sym *.map *.rst

# 2. Assemble
echo "--- Assembling ${PROJECT}.asm ---"
# -g: make global symbols available to linker
if ! sdas8051 -losg ${PROJECT}.asm; then
    echo "ERROR: Assembly failed!"
    exit 1
fi

# 3. Link
echo "--- Linking ---"
# Using sdld8051 specifically for the 8051 target
if ! sdld -im ${PROJECT}.rel; then
    echo "ERROR: Linking failed!"
    exit 1
fi

# 4. Flash
echo "--- Flashing to AT89S52 ---"
# Flash default
# if avrdude -c avrisp -p ${CHIP} -P ${PORT} -b ${BAUD} -U flash:w:${PROJECT}.ihx:i; then

# Flash with local config
if avrdude -C ${CONF_8051} -c avrisp -p ${CHIP} -P ${PORT} -b ${BAUD} -U flash:w:${PROJECT}.ihx:i; then
    echo "--- SUCCESS! ---"
else
    echo "ERROR: Flashing failed!"
    exit 1
fi

