#!/bin/bash
#version: 1.0
#author: chris murray

ver=1.0

sync_cfg=/usr/local/etc/sync/sync.cfg

echo ####################################################
echo -e "  Starting Sync"
echo ====================================================

#parse command line arguments
while [ ${#} -gt 0 ]; do
	case ${1} in
		-H  | --host)
			shift
			hostname=${1}
		;;
		-p  | --push)
			verb=push
			shift
			project=${1}
		;;
		-pp | --pushproject)
			verb=pushproject
			shift
			project=${1}
		;;
	esac
	shift
done

#test sync_cfg exists
if [ -f ${sync_cfg} ]; then
	. ${sync_cfg}
	echo -e "  Bootstrap:  Config Read"
	logger -n ${sync_loghost} $hostname: ${sync_cfg} read
else
	echo -e "  Bootstrap:  Config Missing"
	exit
fi



#test libraries exists
for library in `echo $libraries | sed 's/,/\ /g'`; do
	if [ -f ${sync_lib}/${library} ]; then
		. ${sync_lib}/${library}
		echo -e "  Bootstrap:  Library ${library} Read"

		#test versioning
		if [ "${ver}" == "${sync_libver}" ]; then
			echo -e "  Bootstrap:  Library ${library} Version Accepted"
			logger -n ${sync_loghost} $hostname: ${library} loaded
		else
			echo -e "  Bootstrap:  Library ${library} Version Incorrect"
			logger -n ${sync_loghost} $hostname: ${library} version incorrect
			exit
		fi #end test versioning

	else
		echo -e "  Bootstrap:  Functions ${library} Missing"
		logger -n ${sync_loghost} $hostname: ${library} missing
		exit
	fi
done

case ${verb} in
	pushproject)
		if [ `check_variable ${project}` -eq 0 ]; then
			logger -n ${sync_loghost} $hostname: project - ${project}
		else
			logger -n ${sync_loghost} $hostname: project - not provided
		fi
	;;
esac
