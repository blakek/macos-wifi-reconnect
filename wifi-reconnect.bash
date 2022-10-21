#!/usr/bin/env bash

##
# Reconncts to a certain Wi-Fi network if the connection is lost
##

set -eu -o pipefail
# Set TRACE to show all commands that are executed
[[ "${TRACE:-}" ]] && set -x

declare -Ar globals=(
	# The directory of the currently running file
	['cwd']="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	# The filename of the currently running file
	['filename']="$(basename "${BASH_SOURCE[0]}")"
	# The script's version
	['version']='1.0.0'
)

showUsage() {
	cat <<-END
		Reconncts to a certain Wi-Fi network if the connection is lost.
		NOTE: This script requires running as root.

		Usage:
		    ${globals[filename]} [options]

		Options:
		    -h, --help                Show usage information and exit
		    -i, --interval <seconds>  The interval in seconds to check the connection (default: 10)
			-s, --ssid <ssid>         The SSID (i.e. name) of the Wi-Fi network to reconnect to
			-v, --verbose             Print more information
		    -V, --version             Show the version number and exit

		Positional arguments:
		    ssid           the SSID of the Wi-Fi network to reconnect to
	END
}

airport() { /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport "$@"; }
airportd() { /usr/libexec/airportd "$@"; }
timestamp() { date '+%Y-%m-%dT%H:%M:%S'; }

getCurrentSSID() {
	airport --getinfo | awk -F': ' '/^[[:space:]]*SSID/ { print $2 }'
}

reconnect() {
	airportd assoc --ssid "$1"
}

main() {
	local interval=10
	local ssid
	local verbose='false'

	debugLog() {
		[[ ${verbose} == 'true' ]] && echo "[$(timestamp)]: $*"
	}

	errorLog() {
		echo "$@" >&2
	}

	panic() {
		errorLog "$@"
		exit 1
	}

	# Parse arguments
	for arg in "$@"; do
		case "$arg" in
			-h | --help | help)
				showUsage
				exit
				;;
			-i | --interval)
				interval="$2"
				shift 2
				;;
			-s | --ssid)
				ssid="$2"
				shift 2
				;;
			-v | --verbose)
				verbose='true'
				shift
				;;
			-V | --version)
				echo "${globals['version']}"
				exit
				;;
			-*)
				panic "Error: unknown option: $arg"
				;;
		esac
	done

	# Ensure running as root
	[[ $EUID -eq 0 ]] || panic 'This script must be run as root.'

	# Set SSID to current SSID if not set
	if [[ -z ${ssid:-} ]]; then
		ssid="$(getCurrentSSID)"
	fi

	# Ensure that the SSID is set
	[[ -n ${ssid:-} ]] || panic 'SSID not set.'

	debugLog "Checking connection to '$ssid' every $interval seconds…"

	# Main loop
	while true; do
		sleep "$interval"
		currentSSID="$(getCurrentSSID)"

		if [[ $currentSSID == "$ssid" ]]; then
			debugLog "Connected to '$ssid'."
			continue
		fi

		debugLog "Not connected to '$ssid' (currently connected to '$currentSSID'). Reconnecting…"

		reconnect "$ssid" || errorLog "Failed to reconnect to '$ssid'"
	done

}

main "$@"
