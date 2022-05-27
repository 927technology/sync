#!/bin/bash



for i in 01 02 03 04 05; do 
	for device in server router switch-left switch-right; do 
		hostname=`date '+%H.%M.%s'`_cyfun_cs${i}-${device}
		docker 						\
			run 					\
			--name ${hostname} 			\
			-d 					\
			-e RANGE=cyfun_cs${i} 			\
			-e DEVICE=${device}			\
			-v /home/chris/docker/sync/shared/usr/local/bin:/usr/local/bin 	\
			-v /home/chris/docker/sync/shared/usr/local/etc:/usr/local/etc 	\
			-v /home/chris/docker/sync/shared/usr/local/lib:/usr/local/lib 	\
			sync:1.31
	done
done
