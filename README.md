# What's this

ArduinoFlasher makes below 4 processes into one process via command line (not Arduino IDE).

- Set fuse bits
- Write EEPROM
- Burn Bootloader
- Flash arduino sketch


# Test Environment
Windows 10
python 2.7/3.3

# Folder Structure

ParentFolder
|-ArduinoFlasher
  |-hex_generator.py
  |-flasher_win.sh
|-SketchA
  |- SketchA.ino
|-SketchB
  |- SketchB.ino

# How to Use

## Prepare

- install "intelhex" via pip
$ pip install intelhex

## Command
Option
- b : set fuse bit
- u <max 6byte, hex>: write 6byte unique id to EEPROM
- f <sketch name>: flash sketch

For example

$ sh flasher_win.sh -b -u AA11BB22CC33 -f SketchA
