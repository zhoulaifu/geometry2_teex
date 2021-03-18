SHELL := /bin/bash

IMAGE?=test04
MOUNT?=/mnt/local

TOKEN?=not_working


SOURCE=/opt/ros_ws/src/geometry2/test_tf2/test/buffer_core_test.cpp

#PACKAGE_buffer_core_test=test_tf2
#BINARY_buffer_core_test=/opt/ros_ws/build/test_tf2/buffer_core_test



WORKDIR=./artifacts_teex/$(dirname ${SOURCE})

git:
	git commit -a -m ".."
	git push

build_docker:
	docker build --build-arg GIT_ACCESS_TOKEN=${TOKEN} -t "${IMAGE}" .

shaping:
	echo "here"
	echo ${SOURCE}
	echo $(shell dirname ${SOURCE})
	echo ./artifacts_teex/$(dirname ${SOURCE})
#bash -c "echo WORKDIR=${WORKDIR}"

#mkdir -p ${WORKDIR}

#docker run --mount type=bind,source=${PWD},target=${MOUNT} -it "${IMAGE}"\
	#	cp ${SOURCE} artifacts_teex/${SOURCE} # #

#docker run --mount type=bind,source=${PWD},target=${MOUNT} -it "${IMAGE}" \
	#bash -c "GSL='' LANG_LEX='' /opt/teex/shaping/main_tool < ${SOURCE} > artifacts_teex/${SOURCE}/${basename ${SOURCE} .cpp}_shaping.cpp" # #


#docker run --mount type=bind,source=${PWD},target=${MOUNT} -it "${IMAGE}" \
	#bash -c "mkdir -p in/ out/ && tail -n +2 shape_parameters.txt > in/init.txt && rm -f shape_parameters.txt" # # #

#docker run --mount type=bind,source=${PWD},target=${MOUNT} -it "${IMAGE}" \
	#bash -c "sed -i 's/return RUN_ALL_TESTS();/RUN_ALL_TESTS();\n  return 0;/' $(basename $@)/$(basename $@)_shape.cpp" # # #
\
debug:
	docker run --privileged -it "${IMAGE}" \
	cat /proc/sys/kernel/core_pattern

sanitizing:
	docker run --mount type=bind,source=${PWD},target=${MOUNT} -it "${IMAGE}" \
	afl-gcc hello_shape.c

fuzzing:

	docker run --privileged --mount type=bind,source=${PWD},target=${MOUNT} -it "${IMAGE}" \
	bash -c "echo core > /proc/sys/kernel/core_pattern"


	docker run --privileged --mount type=bind,source=${PWD},target=${MOUNT} -it "${IMAGE}" \
	timeout 10s bash -c "afl-fuzz -i in -o out -- ./a.out" || true

	#docker run --privileged --mount type=bind,source=${PWD},target=${MOUNT} -it "${IMAGE}" \
	#chmod -R +rx out/ && echo "DEBUGGING"

	#pwd

	#whoami



	sudo chmod -R +rx out/
	sudo rm core
	ls -l

run_docker:
	docker run \
	--mount type=bind,source=${PWD},target=${MOUNT} \
	-it "${IMAGE}" /bin/bash



clean_docker:
	docker rm  $$(docker ps -q -a)
	docker image prune -a
