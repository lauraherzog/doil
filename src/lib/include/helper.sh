#!/bin/bash

# doil is a tool that creates and manages multiple docker container
# with ILIAS and comes with several tools to help manage everything.
# It is able to download ILIAS and other ILIAS related software
# like cate.
#
# Copyright (C) 2020 - 2021 Laura Herzog (laura.herzog@concepts-and-training.de)
# Permission to copy and modify is granted under the AGPL license
#
# Contribute: https://github.com/conceptsandtraining/doil
#
# /ᐠ｡‸｡ᐟ\
# Thanks to Concepts and Training for supporting doil

# get the environment
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${SCRIPT_DIR}/env.sh

function doil_get_hash() {
  if [ -z "$1" ]
  then
    echo "No name of instance given, aborting"
    exit
  fi

  DCPROC=$(docker ps | grep $1 -w)
  DCPROCHASH=${DCPROC:0:12}
  echo $DCPROCHASH
}

doil_get_data() {
  if [ -z "$1" ]
  then
    echo "No hash given, aborting"
    exit
  fi

  if [ -z "$2" ]
  then
    echo "No datatype given, aborting"
    exit
  fi

  case $2 in
    "ip")
      echo $(docker inspect --format "{{ .NetworkSettings.Networks.doil_proxy.IPAddress }}" $1)
      ;;
    "hostname")
      echo $(docker inspect -f '{{.Config.Hostname}}' $1)
      ;;
    "domainname")
      echo $(docker inspect -f '{{.Config.Domainname}}' $1)
      ;;
  esac
}

doil_get_command() {
  # get the command
  CMD=""
  oIFS=$IFS
  IFS=":"
  declare -a COMMANDS=(${1})
  if [ ! -z ${COMMANDS[1]} ]
  then
    CMD=${COMMANDS[1]}
  fi
  IFS=$oIFS
  unset $oIFS
  echo ${CMD}
}

doil_maybe_display_help() {
  SECTION=${1}
  COMMAND=${2}

  # check if command is just plain help
  # if we don't have any command we load the help
  if [ -z "${COMMAND}" ] \
    || [ "${COMMAND}" == "help" ] \
    || [ "${COMMAND}" == "--help" ] \
    || [ "${COMMAND}" == "-h" ]
  then
    eval "${DOILLIBPATH}/lib/${SECTION}/help.sh"
    exit
  fi
}

doil_eval_command() {
  SECTION=${1}
  COMMAND=${2}
  shift # past section
  shift # past command
  PARAMS=${@}

  # check if the command exists
  if [ ! -f "/usr/local/lib/doil/lib/${SECTION}/${COMMAND}/${COMMAND}.sh" ]
  then
    echo -e "\033[1mERROR:\033[0m"
    echo -e "\tCan't find a suitable command."
    echo -e "\tUse \033[1mdoil ${SECTION}:help\033[0m for more information"
    exit 255
  fi

  eval "/usr/local/lib/doil/lib/${SECTION}/${COMMAND}/${COMMAND}.sh" ${PARAMS}
}

doil_send_log() {
  NOW=$(date +'%d.%m.%Y %I:%M:%S')
  echo "[$NOW] ${1}"
}

doil_get_conf() {
  CONFIG=${1}
  VALUE=$(cat /etc/doil/doil.conf | grep ${CONFIG} | cut -d '=' -f 2-)
  echo ${VALUE}
}

doil_version_compare() {
  if [[ $1 == $2 ]]
  then
    return 0
  fi
  local IFS=.
  local i ver1=($1) ver2=($2)
  # fill empty fields in ver1 with zeros
  for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
  do
    ver1[i]=0
  done
  for ((i=0; i<${#ver1[@]}; i++))
  do
    if [[ -z ${ver2[i]} ]]
    then
      # fill empty fields in ver2 with zeros
      ver2[i]=0
    fi
    if ((10#${ver1[i]} > 10#${ver2[i]}))
    then
      return 1
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]}))
    then
      return 2
    fi
  done
  return 0
}

doil_test_version_compare() {
  doil_version_compare $1 $2
  case $? in
    0) op='=';;
    1) op='>';;
    2) op='<';;
  esac
  if [[ $op != $3 ]]
  then
    return 255
  fi
  return 0
}

function doil_get_doil_version() {
  VERSION=$(/usr/local/bin/doil --version | cut -d ' ' -f 3)
  echo ${VERSION}
}

function doil_perform_update() {
  declare -a UPDATES

  # if we are on a version somewhere around 1.4 we need
  # to apply all of the updates
  # elsewise we only apply the updates we need
  DOIL_VERSION=$(doil_get_doil_version)
  DOIL_VERSION_SIZE=${#DOIL_VERSION}
  doil_test_version_compare "8" ${DOIL_VERSION_SIZE} "="
  if [ $? -ne 0 ]
  then
    DOIL_VERSION_TYPE="old"
  else
    DOIL_VERSION_TYPE="new"
  fi

  UPDATE_FILES=$(find ./src/updates/ -type f -name "update-*")
  for UPDATE_FILE in ${UPDATE_FILES[@]}
  do
    source ${UPDATE_FILE}
    for UPDATE in $(set | grep  -E '^doil_update.* \(\)' | sed -e 's: .*::')
    do
      if [[ ! " ${UPDATES[@]} " =~ " ${UPDATE} " ]]
      then
        UPDATES=("${UPDATES[@]}" ${UPDATE})
        UPDATE_NAME=$(echo ${UPDATE} | cut -d "_" -f 3)

        if [[ ${DOIL_VERSION_TYPE} == "new" ]]
        then
          doil_test_version_compare ${DOIL_VERSION} ${UPDATE_NAME} "<"
          if [ $? -ne 0 ]
          then
            continue
          fi
        fi

        doil_status_send_message "Apply patch ${UPDATE_NAME}"
        doil_perform_single_update ${UPDATE}
        if [ $? -ne 0 ]
        then
          doil_status_failed
        else
          doil_status_okay
        fi
      fi
    done
  done
}

doil_perform_single_update() {
  "${1}"
}