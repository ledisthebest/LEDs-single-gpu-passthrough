#!/bin/bash

useColors=true
usePager=true

usage() {
	echo "\
Usage: $(basename $0) [OPTIONS]
Shows information about IOMMU groups relevant for working with PCI-passthrough

  -c -C 	enables/disables colored output, respectively
  -p -P 	enables/disables pager (less), respectively

  -h 		display this help message"
}

color() {
	if ! $useColors; then
		cat
		return
	fi

	rset=$'\E[0m'
	case "$1" in
		black) colr=$'\E[22;30m' ;;
		red) colr=$'\E[22;31m' ;;
		green) colr=$'\E[22;32m' ;;
		yellow) colr=$'\E[22;33m' ;;
		blue) colr=$'\E[22;34m' ;;
		magenta) colr=$'\E[22;35m' ;;
		cyan) colr=$'\E[22;36m' ;;
		white) colr=$'\E[22;37m' ;;
		intenseBlack) colr=$'\E[01;30m' ;;
		intenseRed) colr=$'\E[01;31m' ;;
		intenseGreen) colr=$'\E[01;32m' ;;
		intenseYellow) colr=$'\E[01;33m' ;;
		intenseBlue) colr=$'\E[01;34m' ;;
		intenseMagenta) colr=$'\E[01;35m' ;;
		intenseCyan) colr=$'\E[01;36m' ;;
		intenseWhite) colr=$'\E[01;37m' ;;
	esac

	sed "s/^/$colr/;s/\$/$rset/"
}

indent() {
	sed 's/^/\t/'
}

pager() {
	if $usePager; then
		less -SR
	else
		cat
	fi
}

while getopts cCpPh opt; do
	case $opt in
		c)
			useColors=true
			;;
		C)
			useColors=false
			;;
		p)
			usePager=true
			;;
		P)
			usePager=false
			;;
		h)
			usage
			exit
			;;
	esac
done

iommuGroups=$(find '/sys/kernel/iommu_groups/' -maxdepth 1 -mindepth 1 -type d)

if [ -z "$iommuGroups" ]; then
	echo "No IOMMU groups found. Are you sure IOMMU is enabled?"
	exit
fi

for iommuGroup in $iommuGroups; do
	echo "IOMMU group $(basename "$iommuGroup")" | color red

	for device in $(ls -1 "$iommuGroup/devices/"); do
		devicePath="$iommuGroup/devices/$device/"

		# Print pci device
		lspci -nns "$device" | color blue

		# Print drivers
		driverPath=$(readlink "$devicePath/driver")
		if [ -z "$driverPath" ]; then
			echo "Driver: none"
		else
			echo "Driver: $(basename $driverPath)"
		fi | indent | color cyan

		# Print usb devices
		usbBuses=$(find $devicePath -maxdepth 2 -path '*usb*/busnum')
		for usb in $usbBuses; do
			echo 'Usb bus:' | color cyan
			lsusb -s $(cat "$usb"): | indent | color green
		done | indent

		# Print block devices
		blockDevices=$(find $devicePath -mindepth 5 -maxdepth 5 -name 'block')
		for blockDevice in $blockDevices; do
			echo 'Block device:' | color cyan
			echo "Model: $(cat "$blockDevice/../model")" | indent | color green
			lsblk -no NAME,SIZE,MOUNTPOINT "/dev/$(ls -1 $blockDevice)" | indent | color green
		done | indent
	done | indent
done | pager
