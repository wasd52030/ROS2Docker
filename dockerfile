ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE}

ARG ROS_PKG=ros_base
ENV ROS_DISTRO=humble
ENV ROS_ROOT=/opt/ros/${ROS_DISTRO}

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace


# add the ROS deb repo to the apt sources list
RUN apt update && \
    apt install -y --no-install-recommends \
        git \
		cmake \
		build-essential \
		curl \
		wget \ 
		gnupg2 \
		lsb-release \
    && rm -rf /var/lib/apt/lists/*
    
RUN wget --no-check-certificate https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc && apt-key add ros.asc
RUN sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'

# install ROS packages
RUN apt update && \
    apt install -y --no-install-recommends \
		ros-humble-ros-base \
		ros-humble-launch-xml \
		ros-humble-launch-yaml \
		ros-humble-vision-msgs \
        ros-humble-image-tools \
        python3-pip \
		libpython3-dev \
		python3-colcon-common-extensions \
		python3-rosdep \
        colcon-clean \
		ros-humble-cv-bridge \
        tree \
    && rm -rf /var/lib/apt/lists/*


# set setuptool to specified version
# reference -> https://answers.ros.org/question/396439/setuptoolsdeprecationwarning-setuppy-install-is-deprecated-use-build-and-pip-and-other-standards-based-tools/
RUN pip3 install setuptools==58.2.0

# ros webcam module
RUN apt install ros-humble-usb-cam
  
# init/update rosdep
RUN apt update && \
    cd ${ROS_ROOT} && \
    rosdep init && \
    rosdep update && \
    rm -rf /var/lib/apt/lists/*
    
# compile yaml-cpp-0.6, which some ROS packages may use
RUN git clone --branch yaml-cpp-0.6.0 https://github.com/jbeder/yaml-cpp yaml-cpp-0.6 && \
    cd yaml-cpp-0.6 && \
    mkdir build && \
    cd build && \
    cmake -DBUILD_SHARED_LIBS=ON .. && \
    make -j$(nproc) && \
    mkdir /usr/lib/aarch64-linux-gnu/ && \
    cp libyaml-cpp.so.0.6.0 /usr/lib/aarch64-linux-gnu/ && \
    ln -s /usr/lib/aarch64-linux-gnu/libyaml-cpp.so.0.6.0 /usr/lib/aarch64-linux-gnu/libyaml-cpp.so.0.6

# setup entrypoint
COPY ./ros_entrypoint.sh /ros_entrypoint.sh
# RUN sed -i 's/$ROS_DISTRO/humble/g' /ros_entrypoint.sh/
RUN echo 'source ${ROS_ROOT}/setup.bash' >> /root/.bashrc 
RUN chmod +x /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]
WORKDIR /
CMD ["bash"]
