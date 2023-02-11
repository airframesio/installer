#!/usr/bin/env bash
#
# Generates a JSON object of detected SDR devices
#

# Array of SDR USB VID:PID pairs
# Add additional pairs to this list for any supported SDR
SDR_DEVICES=(
  "0x0bda:0x2832" # RealTek 2832
  "0x0bda:0x2838" # RTL-SDR.com RTL2838U
)

function detectSDRs() {
  local -a srdinfo

  for sdrdev in "${SDR_DEVICES[@]}"; do
    IFS=':' read -r -a sdr <<< "$sdrdev"
    local devlist=$(lsusb -d ${sdr[0]}:${sdr[1]})

    if [[ -z "$devlist" ]]; then
      continue;
    fi

    while read dev; do
      read -r -a deventry <<< "$dev"
      local devinfo=$(lsusb -s ${deventry[1]}:${deventry[3]} -v 2>/dev/null)

      local busid=${deventry[1]}
      local deviceid=${deventry[3]::-1}
      local vendor=$(grep iManufacturer <<< "$devinfo" | awk '{print $3}')
      local product=$(grep iProduct <<< "$devinfo" | awk '{print $3}')
      local serial=$(grep iSerial <<< "$devinfo" | awk '{print $3}')
      local version=$(grep bcdDevice <<< "$devinfo" | awk '{print $2}')

      local jusbinfo=$(jq --null-input \
        --arg busid "$busid" \
        --arg deviceid "$deviceid" \
        '{"busid": $busid, "deviceid": $deviceid }')

      local jsdrinfo=$(jq --null-input \
        --arg vendor "$vendor" \
        --arg product "$product" \
        --arg serial "$serial" \
        --arg version "$version" \
        --argjson usb "$jusbinfo" \
        '{"vendor": $vendor, "product": $product, "serial": $serial, "version": $version, "usb": $usb }')

      sdrinfo+=($jsdrinfo)
    done <<< "$devlist"
  done

  sdrjson=$(jq -n '.detected |= [inputs]' <<< "${sdrinfo[@]}")
  echo "$sdrjson"
}
