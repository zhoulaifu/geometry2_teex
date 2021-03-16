IMAGE?=test01
MOUNT?=/mnt/local

TOKEN?=not_working


SOURCE_buffer_core_test=/opt/ros/src/geometry2/test_tf2/test/buffer_core_test.cpp
PACKAGE_buffer_core_test=test_tf2
BINARY_buffer_core_test=/opt/ros/build/test_tf2/buffer_core_test



git:
	git commit -a -m ".."
	git push

build_docker:
	docker build --build-arg GIT_ACCESS_TOKEN=${TOKEN} -t "${IMAGE}" .

shaping:
	docker run --mount type=bind,source=${PWD},target=${MOUNT} -it "${IMAGE}" \
	bash -c "GSL='' LANG_LEX='' /opt/teex/shaping/main_tool < hello.c > hello_shape.c"

	docker run --mount type=bind,source=${PWD},target=${MOUNT} -it "${IMAGE}" \
	bash -c "mkdir -p in/ out/ && tail -n +2 shape_parameters.txt > in/init.txt && rm -f shape_parameters.txt"

%.shaping:
	docker run --mount type=bind,source=${PWD},target=${MOUNT} -it "${IMAGE}" \
	mkdir -p $(basename $@)

	docker run --mount type=bind,source=${PWD},target=${MOUNT} -it "${IMAGE}" \
	bash -c "GSL='' LANG_LEX='' /opt/teex/shaping/main_tool < $(SOURCE_$(basename $@)) > $(basename $@)/$(basename $@)_shape.cpp"


	docker run --mount type=bind,source=${PWD},target=${MOUNT} -it "${IMAGE}" \
	bash -c "mkdir -p in/ out/ && tail -n +2 shape_parameters.txt > in/init.txt && rm -f shape_parameters.txt"

	docker run --mount type=bind,source=${PWD},target=${MOUNT} -it "${IMAGE}" \
	bash -c "sed -i 's/return RUN_ALL_TESTS();/RUN_ALL_TESTS();\n  return 0;/' $(basename $@)/$(basename $@)_shape.cpp"
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
