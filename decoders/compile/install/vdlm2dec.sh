#!/usr/bin/env bash
#
# Airframes Installer - Decoder installer - vdlm2dec by TLeconte (VDL)
# https://github.com/airframesio/scripts/installer/decoders/compile/install/vdlm2dec.sh
#

STEPS=4
TITLE="vdlm2dec"

source $(dirname -- "$0")/../../../utils/common.sh

prepare() {
  mkdir -p /tmp/airframes-installer/src
  mkdir -p /tmp/airframes-installer/logs
  rm -rf /tmp/airframes-installer/src/vdlm2dec
  rm -rf /tmp/airframes-installer/src/libacars
}

dependencies() {
  apt-get update
  apt-get install -y git build-essential librtlsdr-dev libusb-1.0-0-dev libairspy-dev cmake zlib1g-dev libxml2-dev libsndfile-dev
}

checkout() {
  git clone https://github.com/TLeconte/vdlm2dec.git /tmp/airframes-installer/src/vdlm2dec
  git clone https://github.com/szpajder/libacars.git /tmp/airframes-installer/src/libacars
}

build() {
  cd /tmp/airframes-installer/src/libacars
  mkdir build
  cd build
  cmake ..
  make install
  ldconfig

  cd /tmp/airframes-installer/src/vdlm2dec
  mkdir build
  cd build
  cmake .. -Drtl=ON
  make install
}

doStep "$TITLE" "prepare" "Preparing"
doStep "$TITLE" "dependencies" "Installing dependencies"
doStep "$TITLE" "checkout" "Checking out source code"
doStep "$TITLE" "build" "Building"
doStep "$TITLE" "done" "Done"
