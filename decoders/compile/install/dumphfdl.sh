#!/usr/bin/env bash
#
# Airframes Installer - Decoder installer - dumphfdl by szpajder (HFDL)
# https://github.com/airframesio/installer/decoders/compile/install/dumphfdl.sh
#

STEPS=4
TITLE="dumphfdl"

source $(dirname -- "$0")/../../../utils/common.sh

prepare() {
  mkdir -p /tmp/airframes-installer/src
  rm -rf /tmp/airframes-installer/src/dumphfdl
  rm -rf /tmp/airframes-installer/src/libacars
}

dependencies() {
  apt-get update
  apt-get install -y git build-essential cmake pkg-config libglib2.0-dev libconfig++-dev libliquid-dev libfftw3-dev libsoapysdr-dev libzmq3-dev librtlsdr-dev libairspy-dev libusb-1.0-0-dev

  # Necessary because existence breaks build, and manual overrides to cmake don't seem to work
  apt-get remove -y libmirisdr-dev
}

checkout() {
  git clone https://github.com/szpajder/dumphfdl.git /tmp/airframes-installer/src/dumphfdl
  git clone https://github.com/szpajder/libacars.git /tmp/airframes-installer/src/libacars
}

build() {
  cd /tmp/airframes-installer/src/libacars
  mkdir build
  cd build
  cmake ..
  make install
  ldconfig

  cd /tmp/airframes-installer/src/dumphfdl
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
