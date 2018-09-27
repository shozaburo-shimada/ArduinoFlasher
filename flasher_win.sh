#!/bin/bash

PROGNAME=$(basename $0)
VERSION="${PROGNAME} v1.0"
BASEDIR=$(dirname $0)
#echo ${BASEDIR}

DIR_ARDUINO="C:\PROGRA~2\Arduino"
DIR_USER=${USERPROFILE}\\Documents\\Arduino
DIR_USER2=${USERPROFILE}\\AppData\\Local\\Arduino15\\packages
DIR_CURRENT=${PWD}
DIR_ARDUINO_BIN=${DIR_ARDUINO}\\hardware\\tools\\avr\\bin

DIR_HARDWARE1=${DIR_ARDUINO}\\hardware
DIR_HARDWARE2=${DIR_USER}\\hardware
DIR_HARDWARE3=${DIR_USER2}

DIR_TOOLS1=${DIR_ARDUINO}\\tools-builder
DIR_TOOLS2=${DIR_ARDUINO}\\hardware\\tools\\avr
DIR_TOOLS3=${DIR_USER2}

DIR_BUILTIN_LIB=${DIR_ARDUINO}\\libraries
DIR_LIB=${DIR_USER}\\libraries

DIR_CONF=${DIR_USER2}/arduino/tools/avrdude/6.3.0-arduino9/etc
DIR_INO_ROOT=..
DIR_BUILD=build

FW_HEX_SUFFIX="ino.with_bootloader.hex"
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

export PATH="${DIR_ARDUINO_BIN}:${DIR_ARDUINO}:$PATH"



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
              echo "${uid}"
              exit
            fi
            shift
            break
            ;;
          'b')
            #Fuse bit, Lock bit etc.
            flg_fuse=1
            ;;
          'r')
            #Recompile
            flg_recompile=1
            ;;
          'f')
            #firmware
            FW_ARG=("$2")
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

# Analysis ${FW_ARG} and create ${INO_DIR_NAME}, ${REL_HEX_FILE} and ${REL_INO_FILE}
if [ -n "${FW_ARG}" ]; then
  if [ -e "${FW_ARG}" ]; then
    if [ -f "${FW_ARG}" ] && [ ${FW_ARG##*.} = ino ]; then
      # If ${FW_ARG} is ino file full path
      INO_FILE_NAME=${FW_ARG##*/}
      INO_DIR_NAME=${INO_FILE_NAME%.*}
      REL_HEX_FILE="${FW_ARG%/*.ino}/${DIR_BUILD}/${INO_DIR_NAME}.${FW_HEX_SUFFIX}"
      REL_INO_FILE="${FW_ARG}"
      #echo "${FW_ARG} = ino file full path"
    elif [ -f "${FW_ARG}" ] && [ ${FW_ARG#*.} = ${FW_HEX_SUFFIX} ]; then
      # If ${FW_ARG} is hex file full path
      INO_FILE_NAME=${FW_ARG##*/}
      INO_DIR_NAME=${INO_FILE_NAME%%.*}
      REL_HEX_FILE="${FW_ARG}"
      REL_BUILD_DIR="${FW_ARG%/*}"
      REL_INO_FILE="${REL_BUILD_DIR%/${DIR_BUILD}}/${INO_DIR_NAME}.ino"
      #echo "${FW_ARG} = hex file full path"
    else
      # If ${FW_ARG} is ino directory full path
      INO_DIR_NAME=`basename ${FW_ARG}`
      REL_HEX_FILE="${FW_ARG}/${DIR_BUILD}/${INO_DIR_NAME}.${FW_HEX_SUFFIX}"
      REL_INO_FILE="${FW_ARG}/${INO_DIR_NAME}.ino"
      #echo "${FW_ARG} = ino directory path"
    fi
  elif [ -d "${DIR_INO_ROOT}/${FW_ARG}" ]; then
    # If ${FW_ARG} is ino directory name
    INO_DIR_NAME=${FW_ARG}
    REL_HEX_FILE="${DIR_INO_ROOT}/${INO_DIR_NAME}/${DIR_BUILD}/${INO_DIR_NAME}.${FW_HEX_SUFFIX}"
    REL_INO_FILE="${DIR_INO_ROOT}/${INO_DIR_NAME}/${INO_DIR_NAME}.ino"
    #echo "${FW_ARG} = ino directory name"
  fi
  #echo "INO_DIR_NAME=${INO_DIR_NAME}"
  #echo "REL_HEX_FILE=${REL_HEX_FILE}"
  #echo "REL_INO_FILE=${REL_INO_FILE}"
fi

(IFS="/"; cat <<_EOS_

-----------------------------
COM     : $com
UID     : $uid
FIRMWARE: $INO_DIR_NAME
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
  avrdude -C ${DIR_CONF}/avrdude.conf -F -v -p atmega328p -c stk500v1 -P COM${com} -b 19200 -e -Ulock:w:0x3F:m -Uefuse:w:0xFD:m -Uhfuse:w:0xD2:m -Ulfuse:w:0xFF:m

fi

if [ -n "$uid" ]; then
  echo "Write UNIQUE ID to EEPROM."
  # Generate Hex file
  python ${BASEDIR}/hex_generator.py $uid
  # Flash unique id to EEPROM
  avrdude -C ${DIR_CONF}/avrdude.conf -F -v -p atmega328p -c stk500v1 -P COM${com} -b 19200 -U eeprom:w:${BASEDIR}/eeprom.hex:i
  # Verify
  #echo "Verify the UNIQUE ID."
  #avrdude -C ${DIR_CONF}/avrdude.conf -v -p atmega328p -c stk500v1 -P COM${com} -b 19200 -U eeprom:r:verify.hex:i
fi

DIR_INO_PATH=${DIR_INO_ROOT}/${INO_DIR_NAME}
DIR_REL_BUILD_PATH=${DIR_INO_PATH}/${DIR_BUILD}
if [ ! -e "${DIR_REL_BUILD_PATH}" ]; then
  mkdir "${DIR_REL_BUILD_PATH}"
fi

if [ -n "${FW_ARG}" ]; then
  if [ -n "$flg_recompile" ] || [ ! -e "${REL_HEX_FILE}" ]; then
    echo "Compile firmware w/bootloader."

    if [ -e "${DIR_REL_BUILD_PATH}/libraries" ]; then
      rm -r "${DIR_REL_BUILD_PATH}/libraries"
    fi
    if [ -e "${DIR_REL_BUILD_PATH}/core" ]; then
      rm -r "${DIR_REL_BUILD_PATH}/core"
    fi
    DIR_ABS_BUILD_PATH=$(cd $DIR_REL_BUILD_PATH && pwd)

    # Compile
    arduino-builder -dump-prefs ${HARDWARE} ${TOOLS} -built-in-libraries "${DIR_BUILTIN_LIB}" -libraries "${DIR_LIB}" -fqbn="${BOARD_NAME}" -build-path "${DIR_ABS_BUILD_PATH}" -verbose ${DIR_INO_PATH}/${INO_DIR_NAME}.ino
    arduino-builder -compile ${HARDWARE} ${TOOLS} -built-in-libraries "${DIR_BUILTIN_LIB}" -libraries "${DIR_LIB}" -fqbn="${BOARD_NAME}" -build-path "${DIR_ABS_BUILD_PATH}" -verbose ${DIR_INO_PATH}/${INO_DIR_NAME}.ino
  else
    echo "Skip firmware compilation."
  fi

  echo "Flash firmware w/bootloader."

  # Preserve EEPROM
  if [ ! -n "$flg_fuse" ]; then
    avrdude -C ${DIR_CONF}/avrdude.conf -F -v -p atmega328p -c stk500v1 -P COM${com} -b 19200 -e -Uhfuse:w:0xD2:m
  fi
  # Flash
  avrdude -C ${DIR_CONF}/avrdude.conf -F -v -p atmega328p -c stk500v1 -P COM${com} -b 19200 -Uflash:w:${DIR_REL_BUILD_PATH}/${INO_DIR_NAME}.${FW_HEX_SUFFIX}:i

fi
