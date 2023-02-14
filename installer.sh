#!/usr/bin/env bash
#
# Airframes Installer
# https://github.com/airframesio/installer/installer.sh
#
# This script installs the Airframes-related decoder clients & sets up the feeds.
#
# Usage:
#
#   Quick and easy
#
#   $ curl -s https://raw.githubusercontent.com/airframesio/installer/master/installer.sh | sudo bash
#
#   Or, if you prefer to download the script first
#
#   $ curl -s -o install.sh https://raw.githubusercontent.com/airframesio/installer/master/installer.sh
#   $ sudo ./install.sh
#
#   Or, if you prefer to clone the repo first
#
#   $ git clone https://github.com/airframesio/installer.git
#   $ cd installer
#   $ sudo ./installer.sh
#

# Exit if anything goes wrong
set -euo pipefail

### Variables

: ${AIRFRAMES_INSTALLER_GIT_REPO:="https://github.com/airframesio/installer.git"}

AIRFRAMES_INSTALLER_TMP_PATH="/tmp/airframes-installer"
AIRFRAMES_INSTALLER_PATH="${AIRFRAMES_INSTALLER_TMP_PATH}/installer"

AIRFRAMES_PATH="/opt/airframes"
AIRFRAMES_BIN_PATH="${AIRFRAMES_PATH}/bin"
AIRFRAMES_CONFIG_PATH="${AIRFRAMES_PATH}/config"
AIRFRAMES_LOG_PATH="${AIRFRAMES_PATH}/logs"
AIRFRAMES_SRC_PATH="${AIRFRAMES_PATH}/src"
AIRFRAMES_TMP_PATH="${AIRFRAMES_PATH}/tmp"

AIRFRAMES_CONFIG_FILE="${AIRFRAMES_CONFIG_PATH}/config.json"
AIRFRAMES_FEEDS_FILE="${AIRFRAMES_CONFIG_PATH}/feeds.json"
AIRFRAMES_SDRS_FILE="${AIRFRAMES_CONFIG_PATH}/sdrs.json"

version="0.1.0"
title="Airframes Installer ${version}"

### Functions: System

function checkoutInstaller() {
  git clone "${AIRFRAMES_INSTALLER_GIT_REPO}" "${AIRFRAMES_INSTALLER_PATH}"
}

function ensureRoot() {
  if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root. Rerun with sudo!" 1>&2
    exit 1
  fi
}

function initializePaths() {
  mkdir -p "${AIRFRAMES_BIN_PATH}"
  mkdir -p "${AIRFRAMES_CONFIG_PATH}"
  mkdir -p "${AIRFRAMES_LOG_PATH}"
  mkdir -p "${AIRFRAMES_SRC_PATH}"
  mkdir -p "${AIRFRAMES_TMP_PATH}"

  rm -rf "${AIRFRAMES_INSTALLER_TMP_PATH}"
  mkdir -p "${AIRFRAMES_INSTALLER_TMP_PATH}/logs"

  # descriptor 3 is used to capture the result from dialog whilst stdout
  # is used to display the dialog UI
  exec 3>&1
  exec 4>"${AIRFRAMES_INSTALLER_TMP_PATH}/logs/install.log"
}

function platform() {
  local platform=$(uname -s)
  echo "$platform"
}

function platformSupported() {
  local platform=$(platform)
  if [ "$platform" == "Linux" ]; then
    return 0
  elif [ "$platform" == "Darwin" ]; then
    return 0
  else
    return 1
  fi
}

### Functions: Support

function installPlatformDependencies() {
  local platform=$(platform)
  if [ "$platform" == "Linux" ]; then
    apt-get update
    apt-get install -y git dialog jq
  elif [ "$platform" == "Darwin" ]; then
    brew install git dialog lsusb jq
  fi
}

function showPlatformNotSupported() {
  local platform=$(platform)
  dialog --title "$title" \
    --msgbox "Your platform ($platform) is not supported." 10 50
}

### Functions: Menus

function dialog_wrapper() {
  local choice status
  set +e
  choice=$(dialog "$@" 2>&1 1>&3)
  status=$?
  set -e
  if [ ${status} -gt 0 ]; then
      echo "$(($status+10000))"
      return 0
  fi
  echo "${choice}"
  return ${status}
}

function showMenuMain() {
  dialog_wrapper --title "$title" \
    --cancel-label "Exit" \
    --menu "Choose an option:" 15 50 6 \
    1 "Install" \
    2 "Detect SDRs" \
    3 "Assign SDRs to decoders" \
    4 "Configure feeds" \
    5 "Health check"
}

function showMenuInstall() {
  dialog_wrapper --title "$title" \
    --cancel-label "Back" \
    --menu "Choose an option:" 15 50 4 \
    1 "Install by compiling" \
    2 "Install with Docker" \
    3 "Install with packages"
}

function showMenuInstallDockerApps() {
  dialog_wrapper --title "$title" \
  --ok-label "Install" \
  --cancel-label "Back" \
  --checklist "Select Docker apps to install:" 15 50 8 \
  1 "ACARS: acarsdec" "on" \
  2 "ACARS: acarshub" "on" \
  3 "dumphfdl" "off" \
  4 "dumpvdl2" "on" \
  5 "vdlm2dec" "off"
}

function showMenuInstallDecoders() {
  dialog_wrapper --title "$title" \
  --ok-label "Install" \
  --cancel-label "Back" \
  --checklist "Select decoders to install:" 15 50 8 \
  1 "ACARS: acarsdec" "on" \
  2 "ADSB: readsb" "off" \
  3 "HFDL: dumphfdl" "off" \
  4 "VDL: dumpvdl2" "on" \
  5 "VDL: vdlm2dec" "off"
}

function showMenuConfigureFeeds() {
  dialog_wrapper --title "$title" \
    --cancel-label "Back" \
    --menu "Choose an option:" 10 50 3 \
    1 "Configure with Docker" \
    2 "Configure with packages" \
    3 "Configure by compiling"
}


### Main

ensureRoot

platformSupported
if [ $? -ne 0 ]; then
  showPlatformNotSupported
  exit 1
fi

initializePaths
installPlatformDependencies
checkoutInstaller

while :; do
  result=$(showMenuMain)
  echo "main menu result is ${result}" >&4
  case "${result}" in
    10001)
      break
      ;;

    1)
      result=$(showMenuInstall)

      if [ "$result" = "1" ]; then
        selections=$(showMenuInstallDecoders)
	[ "${selections}" == "10001" ] && continue

        if [ "$selections" == "" ]; then
	  echo "No decoders selected to install" >&4
	  dialog --title "Warning" --msgbox "No decoders selected to install" 6 50
          continue
        fi

        echo "Installing decoders from source: $selections" >&4
        for selection in $selections
        do
          case $selection in
          1)
            echo "Installing acarsdec" >&4
            $AIRFRAMES_INSTALLER_PATH/decoders/compile/install/acarsdec.sh
            if [ $? -ne 0 ]; then
              dialog --title "Error" --msgbox "acarsdec failed to install" 6 50
            fi
            sleep 1
            ;;
          3)
            echo "Installing readsb" >&4
            # TODO
            ;;
          3)
            echo "Installing dumphfdl" >&4
            $AIRFRAMES_INSTALLER_PATH/decoders/compile/install/dumphfdl.sh
            if [ $? -ne 0 ]; then
              dialog --title "Error" --msgbox "dumphfdl failed to install" 6 50
            fi
            sleep 1
            ;;
          4)
            echo "Installing dumpvdl2" >&4
            $AIRFRAMES_INSTALLER_PATH/decoders/compile/install/dumpvdl2.sh
            if [ $? -ne 0 ]; then
              dialog --title "Error" --msgbox "dumpvdl2 failed to install" 6 50
            fi
            sleep 1
            ;;
          5)
            echo "Installing vdlm2dec" >&4
            $AIRFRAMES_INSTALLER_PATH/decoders/compile/install/vdlm2dec.sh
            if [ $? -ne 0 ]; then
              dialog --title "Error" --msgbox "vdlm2dec failed to install" 6 50
            fi
            sleep 1
            ;;
          esac
        done

        dialog --title "Success" --msgbox "Decoders installed" 6 50
      fi

      if [ "$result" = "2" ]; then
        selections=$(showMenuInstallDockerApps)
        echo "Installing decoders with docker: $selections" >&4
        # TODO
      fi

      if [ "$result" = "3" ]; then
        echo "Installing decoders as packages" >&4
        # TODO
      fi
      ;;

    2)
      source $AIRFRAMES_INSTALLER_PATH/utils/detect-sdrs.sh
      sdrs=$(detectSDRs)
      echo "Detected SDRs: ${sdrs}" >&4
      dialog --title "Detected SDRs" --msgbox "$sdrs" 10 50
      sleep 5
      ;;

  esac
done


echo " "
echo "Thank you for feeding!"

# Exit with success
exit 0
