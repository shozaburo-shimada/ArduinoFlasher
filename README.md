# What's this

ArduinoFlasher makes below 4 processes into one process via command line (not Arduino IDE).

- Set fuse bits
- Write EEPROM
- Burn Bootloader
- Flash arduino sketch


# Test Environment
- Windows 10
- python 2.7/3.3
- Mac OSX High Sierra

# How to Use

## Preparation

### Hardware
Prepare(or make) Arduino ISP and Connect following diagram.

[PC]---USB(Virtual COM)---[Arduino ISP]---ISP---[Arduino(Target)]

### Python Library For Win
- install "intelhex" via pip

```
$ pip install intelhex
```

### Python Library For Mac
- install pip https://pip.pypa.io/en/stable/installing/
```
$ curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
$ sudo python get-pip.py
```
- install "intelhex" via pip

```
$ sudo pip install intelhex
```

### Folder Struction

ParentFolder<br>
&emsp; |-ArduinoFlasher<br>
&emsp;&emsp; |-hex_generator.py<br>
&emsp;&emsp;  |-flasher_mac.sh<br>
&emsp;&emsp;  |-flasher_win.sh<br>
&emsp; |-SketchA<br>
&emsp;&emsp;  |- SketchA.ino<br>
&emsp; |-SketchB<br>
&emsp;&emsp;  |- SketchB.ino<br>

## Command
- Option
-p option must be required
```
  -h                         Help
  -p <port number or name>   Port number or name to Arduino ISP
  -b                         Set fuse bit
  -u <max 6byte, hex>        Write 6byte unique id to EEPROM
  -f <sketch name>           Flash firmware w/ arduino bootloader
  -r                         Force recompile (also require -f option)
  -m <mcu_name>              Specify the target MCU 328p or 328pb
  -F                         Force flash in avrdude even if device signature is invalid
```

- For example, move flasher folder using "cd" and then...

### For Windows
```
# Move flasher folder
$ cd <xxx>/ArduinoFlasher

# Execute flasher script
$ sh flasher_win.sh -p 4 -b -u AA11BB22CC33 -f SketchA
```

### For Mac OSX
```
# Move flasher folder
$ cd <xxx>/ArduinoFlasher

# Execute flasher script
$ sh flasher_mac.sh -p cu.wchusbserial1430 -b -u AA11BB22CC33 -f SketchA
```
