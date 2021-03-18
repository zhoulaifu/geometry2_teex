#!/bin/bash

# stop on first error
set -e

echo "Starting program $0 at $(date)" # Date will be substituted

IMAGE=test04
MOUNT=/mnt/local
SOURCE=/opt/ros_ws/src/geometry2/test_tf2/test/buffer_core_test.cpp
BINARY=/opt/ros_ws/build/test_tf2/buffer_core_test
BUILD_INSTRUCTION="VERBOSE=1 colcon build --packages-select test_tf2 --event-handlers console_direct+"
TIMEOUT=60s
TIMEOUT2=3000



if [ "$#" != 1 ]; then
    echo
    echo "================Hello, here is the usage for $0=================="
    $0 hello
fi

hello(){

    echo "run TOKEN=<my-github-token> $0 build_docker to build the
    docker according to Dockerfile. As of today 18/03, the dockerfile
    will include the ROS system, the geometry2 metapackage, and teex
    from 21_teex "
    echo
    echo "run  $0 run_docker to run the docker in a terminal"
    echo
    echo "run  $0 shape to run the shaping process"
    echo
    echo "only run  $0 _shape inside the docker to run the shaping process, for debugging"
    echo
    echo "run $0 fuzzing and $0 _fuzzing outside and inside the docker respectively"
}

build_docker(){
    if [ -z "$TOKEN" ]; then echo "ERROR: TOKEN is set to '$TOKEN'"; exit 1; fi

    docker build --build-arg GIT_ACCESS_TOKEN=${TOKEN} -t "${IMAGE}" .

}

run_docker(){

    docker run --mount type=bind,source=$PWD,target=$MOUNT -it "$IMAGE" /bin/bash
}


_exit_if_not_in_docker(){
    if ! grep -q docker /proc/1/cgroup; then
        exit 1
    fi

}
_shape(){
    _exit_if_not_in_docker

    mkdir -p $MOUNT/$SOURCE
    cp $SOURCE $MOUNT/$SOURCE/source.cpp
    GSL='' LANG_LEX='' /opt/teex/shaping/main_tool < $SOURCE > $MOUNT/$SOURCE/shape.cpp
    mkdir -p $MOUNT/$SOURCE/{in,out}
    tail -n +2 shape_parameters.txt > $MOUNT/$SOURCE/in/init.txt
    rm -f shape_parameters.txt

}


shape(){

    docker run --mount type=bind,source=$PWD,target=$MOUNT -it "$IMAGE" $0  _shape

}


_fuzz(){
    _exit_if_not_in_docker

    cp $MOUNT/$SOURCE/shape.cpp $SOURCE

    source /opt/ros/foxy/setup.bash

    cd /opt/ros_ws && CXX="afl-g++" eval $BUILD_INSTRUCTION && cd -

    cd $MOUNT/$SOURCE && rm -rf out/* \
                && timeout ${TIMEOUT} bash -c "afl-fuzz -m none -t ${TIMEOUT2} -i in/ -o out/ -- $BINARY "|| true
}

fuzz(){
    docker run --mount type=bind,source=${PWD},target=${MOUNT} -it "$IMAGE" $0  _fuzz

}
$1
