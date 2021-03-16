FROM ros:foxy
ARG GIT_ACCESS_TOKEN



RUN apt-get update \
         && apt-get install -y  lcov afl++ flex

ENV ROS_WS /opt/ros_ws
ENV TEEX /opt/teex

RUN mkdir -p $ROS_WS
RUN mkdir -p $TEEX

RUN git config --global url."https://${GIT_ACCESS_TOKEN}:@github.com/".insteadOf "https://github.com/"
RUN git clone https://github.com/zhoulaifu/21_teex $TEEX
RUN cd $TEEX/shaping && make main_tool

WORKDIR /mnt/local

# RUN cd $ROS_WS \
#         &&  git clone -b $ROS_DISTRO --depth 1 https://github.com/ros2/geometry2 $ROS_WS/src/geometry2 \
#         &&. /opt/ros/${ROS_DISTRO}/setup.sh \
#         && VERBOSE=1 CXX="afl-g++" CXXFLAGS="--coverage -g -fsanitize=address,undefined -fsanitize-undefined-trap-on-error" colcon build --event-handlers console_direct+
