#!/bin/bash
#version: 1.0
#author: chris murray

ver=1.0

sync_cfg=/usr/local/etc/sync/sync.cfg

echo ####################################################
echo -e "  Starting Sync"
echo ====================================================

#test sync_cfg exists
if [ -f ${sync_cfg} ]; then
	. ${sync_cfg}
	echo -e "  Bootstrap:  Config Read"
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
		else
			echo -e "  Bootstrap:  Library ${library} Version Incorrect"
			exit
		fi #end test versioning

	else
		echo -e "  Bootstrap:  Functions ${library} Missing"
		exit
	fi
done

#test user
case `check_user ${sync_user}` in
	0) echo -e "  Auth     :  Success" ;;
	*)
		echo -e "  Auth     :  Failure"
		exit
	;;
esac #end test user

#parse command line arguments
while [ ${#} -gt 0 ]; do
	case ${1} in
		-e | --enginine)
			shift
			engine=${1}
		;;
		-ep| --editproduction)
			verb=editproduction
			break
		;;
		-et| --edittests)
			verb=edittests
			break
		;;
		-h | --help)
			verb=help
			break
		;;
		-H | --host)
			shift
			host=${1}
		;;
		-g  | --group)
			shift
			group=${1}
		;;
		-l | --list)
			verb=list
			break
		;;
		-lt | --listprojects)
			verb=listprojects
			break
		;;
		-lt | --listtests)
			verb=listtests
			break
		;;
		-p | --pull)
			verb=pull
			break
		;;
		-P | --push)
			verb=push
		;;
		-Pp | --pushproject)
			verb=pushproject
			shift
			guid=${1}
		;;
		-pt | --pulltest)
			verb=pulltest
			shift
			test_name=${1}
		;;
		-Pt | --pushtest)
			task=pushtest
			shift
			test_name=${1}
		;;
		-r | --reload)
			verb=reload
		;;
		-v | --version)
			verb=version
			break
		;;
		*)
			verb=help
			break
		;;
	esac
	shift
done



#validate host or group
if [ ! -z ${host} ]; then
	echo -e "  Host     :  ${host}"
	group=
else
	if [ ! -z ${group} ]; then
		echo -e "  Group    :  ${group}"
		host=
	else
		echo -e "  Host     :  Host or group is not specified"
		sync_help
		exit
	fi
fi


#process verbs
echo ----------------------------------------------------



case ${verb} in
	editproduction)
		echo edit production
	;;
	edittests)
		echo edit tests
	;;
	help)
		sync_help
	;;
	list)
		echo list projects
	;;
	listprojects)
		list_projects
	;;
	listtests)
		echo list tests
	;;
	pull)
		#clean gns3 images and copy new files from dev
		case `clean_images` in
			0) 
				echo -e "  Clean Images:    Success"
				case `pull_projects dev` in
					0) echo -e "  Pull Images:    Success" ;;
					*) echo -e "  Pull Images:    Failure" ;;
				esac
			;;
			*) echo -e "  Clean Images:    Failure" ;;
		esac

		#clean gns3 projects and copy new files from dev
		case `clean_projects` in
			0) 
				echo -e "  Clean Projects:    Success"
				case `pull_projects dev` in
					0) echo -e "  Pull Projects:    Success" ;;
					*) echo -e "  Pull Projects:    Failure" ;;
				esac
			;;
			*) echo -e "  Clean Projects:    Failure" ;;
		esac
	;;
	push)
		#host push
		if [ ! -z ${host} ]; then
			#ensure remote host is available
			ping -c 1 -W 1 ${host} > /dev/null
			case ${?} in
				0)
					echo -e "  Host:       Contacted"
					#clean gns3 images and copy new files to production
					case `clean_images ${host}` in
						0)
							echo -e "  Clean Images:    Success"
							case `push_images ${host}` in
								0) echo -e "  Push Images:    Success" ;;
								*) echo -e "  Push Images:    Failure" ;;
							esac
						;;
						*) echo -e "  Clean Images:    Failure" ;;
					esac

					#clean gns3 projects and copy new files to production
					case `clean_projects ${host}` in
						0)
							echo -e "  Clean Projects:    Success"
							case `push_projects ${host}` in
								0) echo -e "  Push Projects:    Success" ;;
								*) echo -e "  Push Projects:    Failure" ;;
							esac
						;;
						*) echo -e "  Clean Projects:    Failure" ;;
					esac
				;;
				*)  echo -e "  Host:       Not Available" ;;
			esac #end ensure host is available
		fi #end host push

		#group push
		if [ ! -z ${group} ]; then
			#ensure the group has at least 1 member in the groups.cfg file
			if [ `grep -c ^${group}, ${sync_etc}/groups.cfg` -gt 0 ]; then

				#parse groups.cfg and push images and projects
				for host in `grep ^${group}, | awk -F"," '{print $2}'`; do

					#ensure remote host is available
					ping -c 1 -W 1 ${host} > /dev/null
					case ${?} in
						0)
							#clean gns3 images and copy new files to production
							case `clean_images ${host}` in
								0)
									echo -e "  Clean Images:    Success"
									case `push_images ${host}` in
										0) echo -e "  Push Images:    Success" ;;
										*) echo -e "  Push Images:    Failure" ;;
									esac
								;;
								*) echo -e "  Clean Images:    Failure" ;;
							esac

							#clean gns3 projects and copy new files to production
							case `clean_projects ${host}` in
								0)
									echo -e "  Clean Projects:    Success"
									case `push_projects ${host}` in
										0) echo -e "  Push Projects:    Success" ;;
										*) echo -e "  Push Projects:    Failure" ;;
									esac
								;;
								*) echo -e "  Clean Projects:    Failure" ;;
							esac
						;;
						*)  echo -e "  Host:       Not Available" ;;
					esac #end ensure remote host is available
				done # end parse groups.cfg and copy new files to production
			else #if there are no members of supplied group
				echo -e "  Push Images:  Group \"${group}\" does not exist"
			fi #end ensure the group has at least 1 member in the groups.cfg file
		fi #end group push
	;;
	pulltest)
		echo pull test from production
	;;
	pushtest)
		echo push test to production
	;;
	reload)
		echo reload gns service
	;;
	version)
		echo show versioning
	;;
esac



