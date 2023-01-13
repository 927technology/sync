#!/bin/bash


for line in `cat passwords`; do
	#get range name
	range=`echo ${line} | awk -F "," '{print $1}' | awk -F "_" '{print $1}'`
	id=`echo ${range} | sed 's/cs//g'`

	#get device name
	device=`echo ${line} | awk -F "," '{print $1}' | awk -F "_" '{print $2}'`

	#get password
	pass=`echo ${line} | awk -F "," '{print $2}'`

	echo $range
	echo $id
	echo $device
	echo $pass

	if [ ! -d cyfun_${range} ]; then
		mkdir -p cyfun_${range}
	fi

	cp -R cyfun_cs00/router.cfg cyfun_${range}/
	cp -R cyfun_cs00/switch-left.cfg cyfun_${range}/
	cp -R cyfun_cs00/switch-right.cfg cyfun_${range}/
	cp -R cyfun_cs00/rescue.cfg cyfun_${range}/
	cp -R cyfun_cs00/tshoot*.cfg cyfun_${range}/
	cp -R cyfun_cs00/host.address cyfun_${range}/
	cp -R cyfun_cs00/host.login cyfun_${range}/
	cp -R cyfun_cs00/host.pass cyfun_${range}/
	cp -R cyfun_cs00/kadmin.pass cyfun_${range}/
	cp -R cyfun_cs00/instructor.pass cyfun_${range}/

	sed -i 's/cs01/'${range}'/g' cyfun_${range}/router.cfg
	sed -i 's/cs01/'${range}'/g' cyfun_${range}/switch-left.cfg
	sed -i 's/cs01/'${range}'/g' cyfun_${range}/switch-right.cfg
	sed -i 's/.101/.1'${id}'/g' cyfun_${range}/host.address

	echo ${pass} > cyfun_${range}/${device}.pass
echo ------

	echo cyfun_${range}/${device}.pass
	cat cyfun_${range}/${device}.pass


done
