#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR" || exit

debug='false'
pull='false'
reload='false'
while getopts 'dprs' flag; do
    case "${flag}" in
        d) debug='true';;
		p) pull='true';;
		r) reload='true';;
		*) printf '\nUsage: %s: [-d]ebug [-p]ull [-r]eload\n' "$0"; exit 2 ;;
    esac
done

if [ ! -f ./secret.txt ]
then
    touch ./secret.txt
	base64 /dev/urandom | head -c 8192 > ./secret.txt
fi

if [ ! -f ./config.yml ]
then
    wget https://raw.githubusercontent.com/AI-Wars-Soc/common/main/default_config.yml
	mv -f ./default_config.yml ./config.yml
fi

if $debug
then
	docker_file_attr='debug'
	
	repos=( "matchmaker" "web-api" "web-app" "web-server" "submission-runner" "common" "sandbox" "chess-ai" )
	for n in "${repos[@]}"
	do
		if [ ! -d ./"$n" ]
		then
			git clone https://github.com/AI-Wars-Soc/"$n"
		fi
	done

	(cd "$SCRIPT_DIR/web-app" || exit; ./build-debug.sh)
	
	docker-compose -f docker-compose.yml -f "docker-compose.${docker_file_attr}.yml" build
else
	docker_file_attr='release'
fi

if $pull
then
	docker-compose -f docker-compose.yml -f "docker-compose.${docker_file_attr}.yml" pull
fi

if $reload
then
	docker-compose -f docker-compose.yml -f "docker-compose.${docker_file_attr}.yml" restart
else
	docker-compose -f docker-compose.yml -f "docker-compose.${docker_file_attr}.yml" up -d
fi