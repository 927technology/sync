#!/bin/bash

case ${DEVICE} in
	server)
		/usr/bin/pwsh -Command /usr/local/bin/sync.ps1 -vm ${RANGE} -snap Baseline
	;;
	*)
		/usr/local/bin/juniper.exp ${RANGE} ${DEVICE}
	;;
esac

