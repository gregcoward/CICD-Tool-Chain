#!/bin/bash
###########################################################################
##       ffff55555                                                       ##
##     ffffffff555555                                                    ##
##   fff      f5    55         Utility Script Version 0.0.1              ##
##  ff    fffff     555                                                  ##
##  ff    fffff f555555                                                  ##
## fff       f  f5555555             Written By: EIS Consulting          ##
## f        ff  f5555555                                                 ##
## fff   ffff       f555             Date Created: 03/023/2018           ##
## fff    fff5555    555             Last Updated: 03/23/2018            ##
##  ff    fff 55555  55                                                  ##
##   f    fff  555   5       This script destroys F5 WAF deployment      ##
##   f    fff       55                                                   ##
##    ffffffff5555555                                                    ##
##       fffffff55                                                       ##
###########################################################################
###########################################################################
##                              Change Log                               ##
###########################################################################
## Version #     Name       #                    NOTES                   ##
###########################################################################
## 01/08/18#  Thomas Stanley#    Created base functionality              ##
###########################################################################

### Parameter Legend  ###

#trap "set +x; sleep 1; set -x" DEBUG
#export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin/"
#IP_REGEX='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'

# Functions

usage() { 
    echo "Usage: $0 [-u Azure Service Principle Username] [-p Azure Service Principle Password] [-t Azure Tenant ID] [-f Path to JSON Params file]" 1>&2
    exit 1
}

spinner(){
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

urlencode() {
    # urlencode <string>
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C
    local length="${#1}"

    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
    LC_COLLATE=$old_lc_collate
}


urldecode() {
    # urldecode <string>
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}

while getopts "u:p:t:f:" option; do	
    case "$option" in
        u) user=$OPTARG;;
        p) pass=$OPTARG;;
        t) tenant=$OPTARG;;
        f) file=$OPTARG;;
    esac
done
shift $((OPTIND-1))
if [ -z "$user" ] || [ -z "$pass" ] || [ -z "$tenant" ] || [ -z "$file" ]; then
    usage
fi

### Begin Code
az login --service-principal -u $user -p $pass --tenant $tenant

configFile=$(cat "$file")

##  Grab resource group name
rgroupName=$(echo $configFile | jq -r .rgroupName)

## Destroy the Resource Group
az group delete --resource-group $rgroupName


