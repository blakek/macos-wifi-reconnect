#!/usr/bin/env bash

##
# Reconnects to a Wi-Fi network if the connection is lost
##

set -eu -o pipefail
# Set TRACE to show all commands that are executed
[[ "${TRACE:-}" ]] && set -x

# The directory of the currently running file
__dirname="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The filename of the currently running file
__filename="$(basename "${BASH_SOURCE[0]}")"
# The script's version
__version='1.0.0'

verbose='false'

showUsage() {
	cat <<-END
		Trys to reconnect to Wi-Fi network if the connection is lost.
		NOTE: This script requires running as root.

		Usage:
		    ${__filename} [options]

		Options:
		    -h, --help                Show usage information and exit
		    -i, --interval <seconds>  The interval in seconds to check the connection (default: 180)
		    -v, --verbose             Print more information
		    -V, --version             Show the version number and exit
	END
}

debugLog() {
	if [[ ${verbose} == 'true' ]]; then
		echo "[$(timestamp)]: $*"
	fi
}

errorLog() {
	echo "$@" >&2
}

panic() {
	errorLog "$@"
	exit 1
}

airport() { /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport "$@"; }
timestamp() { date '+%Y-%m-%dT%H:%M:%S'; }

getCurrentSSID() {
	airport --getinfo | awk -F': ' '/^[[:space:]]*SSID/ { print $2 }'
}

reconnect() {
	networksetup -setairportpower en0 off
	sleep 5 # Sleeping is probably unnecessary
	networksetup -setairportpower en0 on
}

main() {
	local interval=180

	# Parse arguments
	while (($# > 0)); do
		arg="$1"

		case "$arg" in
			-h | --help | help)
				showUsage
				exit
				;;
			-i | --interval)
				interval="$2"
				shift
				;;
			-v | --verbose)
				verbose='true'
				;;
			-V | --version)
				echo "${__version}"
				exit
				;;
			-*)
				panic "Error: unknown option: $arg"
				;;
		esac

		shift
	done

	# Ensure running as root
	[[ $EUID -eq 0 ]] || panic 'This script must be run as root.'

	debugLog "Checking Wi-Fi connection every ${interval} seconds…"

	# Main loop
	while true; do
		sleep "$interval"
		ssid="$(getCurrentSSID)"

		if [[ $ssid != "" ]]; then
			debugLog "Connected to '$ssid'."
			continue
		fi

		debugLog "Not connected to a Wi-Fi network. Reconnecting…"
		reconnect || errorLog "Failed to connect."
	done
}

main "$@"
