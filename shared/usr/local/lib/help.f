sync_helpver=1.0

function sync_help {
	echo -e " \n"
	echo -e "  Chris has written a very amazing tool to help sync projects.  Please Enjoy!"
	echo -e "  It's Dangerous to go alone!  Take this."

	echo -e "\t-e  | --engine          Engine used to rerversion (scp/expect)"
	echo -e "\t-ep | --editproduction  Opens the PRODUCTION list for editing"
	echo -e "\t-et | --edittests       Opens the TEST list for editing"
	echo -e "\t-g  | --group           Specifies PRODUCTION group to push projects to."
	echo -e "\t                        Must be used in conjunction with a PUSH operation."
	echo -e "\t-H  | --host            Specifies PRODUCTION system to push projects to."
	echo -e "\t                        Must be used in conjunction with a PUSH operation."
	echo -e "\t-h  | --help            Displays help message."
	echo -e "\t-l  | --list            Lists Projects on this system"
	echo -e "\t-lt | --listtests       Lists Tests on this system"
	echo -e "\t-r  | --reload          Reloads the GNS3 Service on PRODUCTION systems"
	echo -e "\t-p  | --pull            Pulls all projects from the DEV system"
	echo -e "\t-P  | --push            Pushes projects to PRODUCTION systems"
#	echo -e "\t-Pp | --pushproject     Pushes project to PRODUCTION systems"
	echo -e "\t-pt | --pulltest        Pulls test from PRODUCTION systems"
	echo -e "\t-Pt | --pushtest        Pushes test to PRODUCTION systems"
	echo -e "\t-v  | --version         Displays version information"
}
