#!/usr/bin/env bash
#
# Airframes Installer - Decoder installer - acarsdec by TLeconte (ACARS)
# https://github.com/airframesio/scripts/installer/decoders/compile/install/acarsdec.sh
#

STEPS=4
TITLE="acarsdec"

source $(dirname -- "$0")/../../../utils/common.sh

prepare() {
  mkdir -p /tmp/airframes-installer/src
  mkdir -p /tmp/airframes-installer/logs
  rm -rf /tmp/airframes-installer/src/acarsdec
  rm -rf /tmp/airframes-installer/src/libacars
}

dependencies() {
  apt-get update
  apt-get install -y git build-essential librtlsdr-dev libusb-1.0-0-dev libairspy-dev cmake zlib1g-dev libxml2-dev libsndfile-dev
}

checkout() {
  git clone https://github.com/TLeconte/acarsdec.git /tmp/airframes-installer/src/acarsdec
  git clone https://github.com/szpajder/libacars.git /tmp/airframes-installer/src/libacars
}

build() {
  cd /tmp/airframes-installer/src/libacars
  mkdir build
  cd build
  cmake ..
  make install
  ldconfig

  cd /tmp/airframes-installer/src/acarsdec
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
