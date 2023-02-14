#!/usr/bin/env bash
#
# Airframes Installer - Decoder installer - readsb by wiedehopf (VDL)
# https://github.com/airframesio/scripts/installer/decoders/compile/install/readsb.sh
#

STEPS=4
TITLE="readsb"

source $(dirname -- "$0")/../../../utils/common.sh

prepare() {
  mkdir -p /tmp/airframes-installer/src
  rm -rf /tmp/airframes-installer/src/readsb
}

dependencies() {
  apt-get update
  apt-get install -y  git build-essential debhelper libusb-1.0-0-dev \
    librtlsdr-dev librtlsdr0 pkg-config \
    libncurses-dev zlib1g-dev zlib1g libzstd-dev libzstd1
}

checkout() {
  git clone https://github.com/wiedehopf/readsb.git /tmp/airframes-installer/src/readsb
}

build() {
  cd /tmp/airframes-installer/src/readsb
  make AIRCRAFT_HASH BITS=11 RTLSDR=yes OPTIMIZE="-I3 -march=native"
  make install
}

doStep "$TITLE" "prepare" "Preparing"
doStep "$TITLE" "dependencies" "Installing dependencies"
doStep "$TITLE" "checkout" "Checking out source code"
doStep "$TITLE" "build" "Building"
doStep "$TITLE" "done" "Done"
