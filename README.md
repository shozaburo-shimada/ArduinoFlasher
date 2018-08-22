# What's this

ArduinoFlasher makes below 4 processes into one process via command line (not Arduino IDE).

- Set fuse bits
- Write EEPROM
- Burn Bootloader
- Flash arduino sketch


# Test Environment
- Windows 10
- python 2.7/3.3

# Folder Structure


# How to Use

## Preparation

### Hardware
Prepare(or make) Arduino ISP and Connect following diagram.

[PC]---USB(Virtual COM)---[Arduino ISP]---ISP---[Arduino(Target)]

### Python Library
- install "intelhex" via pip

$ pip install intelhex

### Folder Struction

ParentFolder<br>
&emsp; |-ArduinoFlasher<br>
&emsp;&emsp; |-hex_generator.py<br>
&emsp;&emsp;  |-flasher_win.sh<br>
&emsp; |-SketchA<br>
&emsp;&emsp;  |- SketchA.ino<br>
&emsp; |-SketchB<br>
&emsp;&emsp;  |- SketchB.ino<br>

## Command
- Option

-p : COM port number to Arduino ISP
-b : set fuse bit<br>
-u <max 6byte, hex>: write 6byte unique id to EEPROM<br>
-f <sketch name>: flash sketch<br>

- For example

$ sh flasher_win.sh -p 4 -b -u AA11BB22CC33 -f SketchA
