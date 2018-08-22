#!/bin/bash

DIR_ARDUINO="C:\PROGRA~2\Arduino"
DIR_USER=${USERPROFILE}\\Documents\\Arduino
DIR_USER2=${USERPROFILE}\\AppData\\Local\\Arduino15\\packages
DIR_CURRENT=${PWD}

DIR_HARDWARE1=${DIR_ARDUINO}\\hardware
DIR_HARDWARE2=${DIR_USER}\\hardware
DIR_HARDWARE3=${DIR_USER2}

DIR_TOOLS1=${DIR_ARDUINO}\\tools-builder
DIR_TOOLS2=${DIR_ARDUINO}\\hardware\\tools\\avr
DIR_TOOLS3=${DIR_USER2}

DIR_BUILTIN_LIB=${DIR_ARDUINO}\\libraries
DIR_LIB=${DIR_USER}\\libraries

BOARD_NAME="arduino:avr:vivi:cpu=8MHzatmega328"

HARDWARE="-hardware "${DIR_HARDWARE1}

if [ -e "${DIR_HARDWARE2}" ]; then
    HARDWARE=${HARDWARE}" -hardware "${DIR_HARDWARE2}
fi

if [ -e "${DIR_HARDWARE3}" ]; then
    HARDWARE=${HARDWARE}" -hardware "${DIR_HARDWARE3}
fi

TOOLS="-tools "${DIR_TOOLS1}

if [ -e "${DIR_TOOLS2}" ]; then
    TOOLS=${TOOLS}" -tools "${DIR_TOOLS2}
fi

if [ -e "${DIR_TOOLS3}" ]; then
    TOOLS=${TOOLS}" -tools "${DIR_TOOLS3}
fi




while(( $# > 0 )); do
  case "$1" in
    - | --)
      #オプション終端、以降すべて引数扱い
      shift
      #argc+=$#
      #argv+=("$@")
      break
      ;;
    --*)
      #ロングオプション
      ;;
    -*)
      #ショートオプション
      for (( i=1; i < ${#1}; i++));do # ${#1}は$1の文字数
        opt_name="${1:$i:1}"; # ${変数:offset:length}
        case "$opt_name" in
          'h')
            #help
            ;;
          'p')
            #com port number
            com=($2)
            shift
            ;;
          'u')
            #unique id
            uid=("$2")
            if [ ${#uid} -lt 2 ] || [ ${#uid} -gt 12 ]; then
              echo "-u: Invalid argument"
              exit
            fi
            shift
            break
            ;;
          'b')
            #Fuse bit, Lock bit etc.
            flg_fuse=1
            ;;
          'f')
            #firmware
            fw_file=("$2")
            shift
            break
            ;;
          esac
        done
      ;;

    * ) echo "$1"
  esac
  shift
done

(IFS="/"; cat <<_EOS_

-----------------------------
COM     : $com
UID     : $uid
FIRMWARE: $fw_file
FUSE    : $flg_fuse
-----------------------------

_EOS_
)


if [ -z "$com" ]; then
  echo "Error: -p option must be required"
  exit
fi

if [ -n "$flg_fuse" ]; then
  echo "Write Fuse bit etc."
  avrdude -C ${DIR_USER2}/arduino/tools/avrdude/6.3.0-arduino9/etc/avrdude.conf -v -p atmega328p -c stk500v1 -P COM${com} -b 19200 -e -Ulock:w:0x3F:m -Uefuse:w:0xFD:m -Uhfuse:w:0xDA:m -Ulfuse:w:0xFF:m

fi

if [ -n "$uid" ]; then
  echo "Write UNIQUE ID to EEPROM."
  # Generate Hex file
  python hex_generator.py $uid
  # Flash unique id to EEPROM
  avrdude -C ${DIR_USER2}/arduino/tools/avrdude/6.3.0-arduino9/etc/avrdude.conf -v -p atmega328p -c stk500v1 -P COM${com} -b 19200 -U eeprom:w:eeprom.hex:i
  # Verify
  #avrdude -C ${DIR_USER2}/arduino/tools/avrdude/6.3.0-arduino9/etc/avrdude.conf -v -p atmega328p -c stk500v1 -P COM${com} -b 19200 -U eeprom:r:verify.hex:i
fi

if [ -n "$fw_file" ]; then
  echo "Flash firmware w/bootloader."

  DIR_REL_BUILD_PATH=../${fw_file}/build
  mkdir ${DIR_REL_BUILD_PATH}
  DIR_ABS_BUILD_PATH=$(cd $DIR_REL_BUILD_PATH && pwd)

  # Comilpe
  arduino-builder -dump-prefs ${HARDWARE} ${TOOLS} -built-in-libraries "${DIR_BUILTIN_LIB}" -libraries "${DIR_LIB}" -fqbn="${BOARD_NAME}" -build-path "${DIR_ABS_BUILD_PATH}" -verbose ../${fw_file}/${fw_file}.ino
  arduino-builder -compile ${HARDWARE} ${TOOLS} -built-in-libraries "${DIR_BUILTIN_LIB}" -libraries "${DIR_LIB}" -fqbn="${BOARD_NAME}" -build-path "${DIR_ABS_BUILD_PATH}" -verbose ../${fw_file}/${fw_file}.ino

  # Flash
  avrdude -C ${DIR_USER2}/arduino/tools/avrdude/6.3.0-arduino9/etc/avrdude.conf -v -p atmega328p -c stk500v1 -P COM${com} -b 19200 -Uflash:w:${DIR_REL_BUILD_PATH}/${fw_file}.ino.with_bootloader.hex:i

fi
