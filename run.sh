#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR" || exit

debug='false'
pull='false'
while getopts 'ds' flag; do
    case "${flag}" in
        d) debug='true';;
		s) pull='true';;
		*) printf '\nUsage: %s: [-d]ebug [-p]ull\n' "$0"; exit 2 ;;
    esac
done

if [ ! -f ./secret.txt ]
then
    touch ./secret.txt
	base64 /dev/urandom | head -c 8192 > ./secret.txt
fi

if $debug
then
	docker_file_attr='debug'
	
	repos=( "matchmaker" "web-api" "web-app" "web-server" "submission-runner" )
	for n in "${repos[@]}"
	do
		if [ ! -d ./"$n" ]
		then
			git clone https://github.com/AI-Wars-Soc/"$n"
		fi
	done

	(cd "$SCRIPT_DIR/web-app" || exit; pwd; ./build-debug.sh)
	
	docker-compose -f docker-compose.yml -f "docker-compose.${docker_file_attr}.yml" build
else
	docker_file_attr='release'
fi

if $pull
then
	docker-compose -f docker-compose.yml -f "docker-compose.${docker_file_attr}.yml" pull
fi

docker-compose -f docker-compose.yml -f "docker-compose.${docker_file_attr}.yml" up -d
