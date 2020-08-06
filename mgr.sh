#!/bin/bash

# set project name
PROJECT_NAME="readme.md"


#mgr version
VERSION="1.0"
# rootFile
rootFile=~

function printHelp() {
  echo "Usage: "
  echo "  mgr.sh <arg>"
  echo "    <arg> - one of 'start', 'upgrade', 'stop', 'restart', 'version', 'help'"
  echo "      - 'help'       - echo help information "
  echo "      - 'start'      - run start project "
  echo "      - 'upgrade'    - run upgrade project "
  echo "      - 'stop'       - run stop project "
  echo "Taking all defaults:"
  echo "  mgr.sh help"
}


function start() {
 nohup ./$PROJECT_NAME &
}

function stop() {
  ps -ef | grep $PROJECT_NAME | awk '{print $2}' | xargs kill
}

function upgrade() {
  stop
  mv $PROJECT_NAME $PROJECT_NAME"_bak"
  cp ~/$PROJECT_NAME ./
}

function restart() {
  stop
  start
}

# run befor start command check
function beforStart() {
  if [ "${PROJECT_NAME}" == "" ]; then
    echo "please set 'PROJECT_NAME'"
    exit 1
  fi
  if [ ! -f  "./${PROJECT_NAME}" ]; then
    echo "not find file ${PROJECT_NAME}"
    exit
  fi
}

# run befor upgrade command check
function beforUpgrade() {
  beforStart
  if [ ! -f "${rootFile}/${PROJECT_NAME}" ]; then
    echo "not find file ${PROJECT_NAME} in '${rootFile}' dir"
    exit
  fi
}

arg=$1

# run main
if [ "${arg}" == "start" ]; then
  beforStart
  start
elif [ "${arg}" == "upgrade" ]; then
  beforUpgrade
  upgrade
elif [ "${arg}" == "stop" ]; then
  stop
elif [ "${arg}" == "restart" ]; then
  restart
elif [ "${arg}" == "version" ] || [ "${arg}" == "-v" ] || [ "${arg}" == "-version" ]; then
  echo $VERSION
elif [ "${arg}" == "hepl" ]  || [ "${arg}" == "-h" ]; then
  printHelp
else
  printHelp
  exit 1
fi
