#version: 1.0
#author: chris murray

sync_libver=1.0


function check_user {
	local user=${1}
	local current_user=`whoami`

	if [ "${current_user}" == "${user}" ]; then
		exitcode=0
	else
		exitcode=1
	fi

	echo ${exitcode} 
}

function check_variable {
	local variable=${1}
	if [ -z ${variable} ]; then
		exitcode=1
	else
		exitcode=0
	fi
	echo ${exitcode}
}

function check_version {
	local a=${1}
	local b=${2}
	local exitcode=-1

	if [ "${a}" ==  "${b}" ]; then
		local exitcode=0
	else
		local exitcode=1
	fi

	echo ${exitcode}
}

function clean_images {
	local host=${1}

	if [ -z ${host} ]; then
		rm -rf ${gns_path}/images
		mkdir -p ${gns_path}/images
	else
		ssh ${host} rm -rf ${gns_path}/images
		ssh ${host} mkdir -p ${gns_path}/images
	fi
	case $? in
		0) local exitcode=0 ;;
		*) local exitcode=1 ;;
	esac

	echo ${exitcode}
}

function clean_projects {
	local host=${1}

	if [ -z ${host} ]; then
		rm -rf ${gns_path}/projects
		mkdir -p ${gns_path}/projects
		case $? in
			0) local exitcode=0 ;;
			*) local exitcode=1 ;;
		esac
	else
		ssh ${host} rm -rf ${gns_path}/projects
		ssh ${host} mkdir -p ${gns_path}/projects
		case $? in
			0) local exitcode=0 ;;
			*) local exitcode=1 ;;
		esac
	fi  

	echo ${exitcode}
}	


function get_project_name {
	local guid=${1}

	if [ -f ${gns_path}/projects/${guid}/*.gns3 ]; then 
		local name=`cat ${gns_path}/projects/${guid}/*.gns3 | jq .name | sed 's/ /_/g'`
	else
		local name="Empty"
	fi

	echo "${name}"
}

function list_projects {
	local exitstring=

	for guid in `ls ${gns_path}/projects`; do
		local name=`get_project_name ${guid}`
		exitstring=${exitstring} ${name},${guid}
	done

	echo ${exitstring}
}

function list_tests {
	while IFS="," read -r name guid; do
		table 2 ${guid} ${name}
	done < ${sync_etc}/tests.cfg
}

function parse_exitcode {
	local exitcode=${1}

	case ${exitcode} in
		0 ) echo Success ;;
		1 ) echo Failure ;;
		-1) echo Syntax_Error ;;
		* ) echo Critical_Failure ;;
	esac
}

function pull_images {
	local host=${1}

	#scp images from remote host to local gns path
	#scp -r ${host}:${gns_path}/images ${gns_path}/ > /dev/null

	#rsync images from remote host to local gns path
	scp -r ${host}:${gns_path}/images ${gns_path}/ > /dev/null

	case $? in
		0) local exitcode=0 ;;
		*) local exitcode=1 ;;
	esac

	echo ${exitcode}
}

function pull_projects {
	local host=${1}
	
	#scp projects from remote host to local gns path
	#scp -r ${host}:${gns_path}/projects ${gns_path}/ > /dev/null

	#rsync projects from remote host to local gns path
	rsync -az -e ${host}:${gns_path}/projects ${gns_path}/ > /dev/null

	case ${?} in
		0) local exitcode=0 ;;
		*) local exitcode=1 ;;
	esac

	echo ${exitcode}
}

function pull_test {
	local host=${1}
	local name=${2}

        local count_name=`grep -c ${name} ${sync_etc}/tests.cfg`

        case ${count_name} in
                1)
                        local guid=`grep ${name} ${sync_etc}/tests.cfg | awk -F"," '{print $2}'`
                        ssh ${host} rm -rf ${gns_path}/projects/${guid} > /dev/null
                        case $? in
                                0) exitcode=0 ;;
                                *) exitcode=1 ;;
                        esac
                ;;
                *)
                        exitcode=-1
                ;;
        esac

	echo ${exitcode}
}

function push_images {
	local host=${1}
	local guid=${2}

 	scp -r ${gns_path}/images/* ${host}:${gns_path}/images > /dev/null
	case $? in
		0) local exitcode=0 ;;
		*) local exitcode=1 ;;
	esac

	echo ${exitcode}
}

function push_project {
	local host=${1}
	local guid=${2}

 	scp -r ${gns_path}/projects/${guid} ${host}:${gns_path}/projects > /dev/null
	case $? in
		0) local exitcode=0 ;;
		*) local exitcode=1 ;;
	esac

	echo ${exitcode} 
}

function push_test {
	local host=${1}
	local name=${2}

        local count_name=`grep -c ${name} ${sync_etc}/tests.cfg`

        case ${count_name} in
                1)
                        local guid=`grep ${name} ${sync_etc}/tests.cfg | awk -F"," '{print $2}'`
                        scp -r ${gns_path}/projects/${guid} ${host}:${gns_path}/projects/${guid} > /dev/null
                        case $? in
                                0) exitcode=0 ;;
                                *) exitcode=1 ;;
                        esac
                ;;
                *)
                        exitcode=-1
                ;;
        esac

	echo ${exitcode}
}

function table {
	local column_count=${1}
	local column1=${2}
	local column2=${3}
	local column3=${4}
	local column4=${5}

	case ${column_count} in
		1) printf "%-2s %-84s %-2s \n" \| ${column1} \| ;;
		2) printf "%-2s %-40s %-2s %-40s %-2s\n" \| ${column1} \| ${column2} \| ;;
		3) printf "%-2s %-40s %-2s %-40s %-2s %-40s %-2s\n" \| ${column1} \| ${column2} \| ${column3} \| ;;
		4) printf "%-2s %-40s %-2s %-40s %-2s %-40s %-2s %-40s %-2s\n" \| ${column1} \| ${column2} \| ${column3} \| ${column4} \| ;;
	esac
}

function test {
	echo test
}
