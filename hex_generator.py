#coding: UTF-8

#pip install IntelHexとしてから

# make 10 byte hex file
from intelhex import IntelHex
import struct
import sys

args = sys.argv

uid = [0, 0, 0, 0, 0, 0]

if (len(args) != 2):
    print("Error: the number of argument should be one")
    sys.exit()

if (len(args[1]) < 2) or (len(args[1]) > 12):
    print("Error: invalid argument")
    sys.exit()

s = args[1]
# Split string data into list each 2 char (e.g. "AABB" -> ["AA", "BB"])
strid = [(i+j) for (i,j) in zip(s[::2],s[1::2])]

uidlen = len(strid)

for index in range(6):
    if(index >= (6 - uidlen)):
        uid[index] = int(strid[index  - (6 - uidlen)], 16)

'''
# for debug
for index, item in enumerate(uid):
    print("index:" + str(index) + ", value:" + str(item))
'''

ih = IntelHex()
fmt = "4c6B" #4 char, 6 unsigned char
endadd = 1024 # End Address of EEPROM

ih.puts(endadd - 10, struct.pack(fmt, 'M'.encode('ascii'), 'A'.encode('ascii'), 'C'.encode('ascii'), ':'.encode('ascii'), uid[0], uid[1], uid[2], uid[3], uid[4], uid[5])) #.encode()がないとpython 3.xでError

ih.dump()
ih.write_hex_file("eeprom.hex")
