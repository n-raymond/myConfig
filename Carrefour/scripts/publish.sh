#!/bin/bash

set -e


usage() {
    echo "publish.sh -e [uat|pilot] -p <program>"
    exit 1
}


while getopts ":e:p" option; do
    case "${option}" in
        e)
            e=${OPTARG}
            [[ "$e" == "uat"  ]] || [[ "$e" == "pilot" ]] || usage
            ;;
        p)
            p=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))
if [ -z "${e}" ]; then
    usage
fi

echo "The program $p will be deployed on $e"

# TODO: Confirmation

carrefour-sbt $p/publishLocal

