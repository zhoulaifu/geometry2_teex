#!/bin/bash


set -e

echo "Starting program $0 at $(date)" # Date will be substituted

hello(){
    echo Hello, this is start scripts to build and run the docker image.

}
build_docker(){
    if [ -z "$TOKEN" ]; then echo "ERROR: TOKEN is set to '$TOKEN'"; exit 1; fi
    if [ -z "$IMAGE" ]; then echo "ERROR: IMAGE is set to '$IMAGE'"; exit 1; fi

    docker build --build-arg GIT_ACCESS_TOKEN=${TOKEN} -t "${IMAGE}" .

}

run_docker(){
    if [ -z "$IMAGE" ]; then echo "ERROR: IMAGE is set to '$IMAGE'"; exit 1; fi

    docker run --mount type=bind,source=$PWD,target=/mnt/local -it "$IMAGE" /bin/bash
}
$1
