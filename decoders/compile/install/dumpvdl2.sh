#!/usr/bin/env bash
#
# Airframes Installer - Decoder installer - dumpvdl2 by szpajder (VDL)
# https://github.com/airframesio/scripts/installer/decoders/compile/install/dumpvdl2.sh
#

STEPS=4
TITLE="dumpvdl2"

source $(dirname -- "$0")/../../../utils/common.sh

prepare() {
  mkdir -p /tmp/airframes-installer/src
  mkdir -p /tmp/airframes-installer/logs
  rm -rf /tmp/airframes-installer/src/dumpvdl2
  rm -rf /tmp/airframes-installer/src/libacars
}

dependencies() {
  apt-get update
  apt-get install -y git build-essential librtlsdr-dev libusb-1.0-0-dev libairspy-dev cmake libzmq3-dev libglib2.0-dev libsoapysdr-dev

  # Necessary because existence breaks build, and manual overrides to cmake don't seem to work
  apt-get remove -y libmirisdr-dev
}

checkout() {
  git clone https://github.com/szpajder/dumpvdl2.git /tmp/airframes-installer/src/dumpvdl2
  git clone https://github.com/szpajder/libacars.git /tmp/airframes-installer/src/libacars
}

build() {
  cd /tmp/airframes-installer/src/libacars
  mkdir build
  cd build
  cmake ..
  make install
  ldconfig

  cd /tmp/airframes-installer/src/dumpvdl2
  mkdir build
  cd build
  cmake ..
  make install
}

doStep "$TITLE" "prepare" "Preparing"
doStep "$TITLE" "dependencies" "Installing dependencies"
doStep "$TITLE" "checkout" "Checking out source code"
doStep "$TITLE" "build" "Building"
doStep "$TITLE" "done" "Done"
