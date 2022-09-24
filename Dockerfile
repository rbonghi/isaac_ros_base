# Copyright (C) 2022, Raffaello Bonghi <raffaello@rnext.it>
# All rights reserved
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright 
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its 
#    contributors may be used to endorse or promote products derived 
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND 
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, 
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# reference
# https://gitlab.com/nvidia/container-images/samples/-/blob/main/deployments/container/Makefile
# https://gitlab.com/nvidia/container-images/samples/-/blob/main/deployments/container/Dockerfile.ubuntu
# https://catalog.ngc.nvidia.com/orgs/nvidia/containers/cuda/tags

ARG BASE_DIST=ubuntu20.04
ARG CUDA_VERSION=11.4.1
FROM nvidia/cuda:${CUDA_VERSION}-devel-${BASE_DIST} AS builder

# Env setup
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV ROS_PYTHON_VERSION=3

# Basics
RUN apt-get update && apt-get install -y \
        curl \
        gnupg \
        lsb-release \
&& rm -rf /var/lib/apt/lists/* \
&& apt-get clean

# Add ROS2 apt repository
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2-testing/ubuntu $(source /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# ROS fundamentals
RUN apt-get update && apt-get install -y \
        build-essential \
        git \
        python3-colcon-common-extensions \
        python3-pip \
        python3-pybind11 \
        python3-pytest-cov \
        python3-rosdep \
        python3-rosinstall-generator \
        python3-setuptools \
        python3-vcstool \
        wget \
&& rm -rf /var/lib/apt/lists/* \
&& apt-get clean

# ROS Python fundamentals
RUN python3 -m pip install -U \
        flake8-blind-except \
        flake8-builtins \
        flake8-class-newline \
        flake8-comprehensions \
        flake8-deprecated \
        flake8-docstrings \
        flake8-import-order \
        flake8-quotes \
        pytest-repeat \
        pytest-rerunfailures \
        pytest \
        setuptools

# Avoid setup.py and easy_install deprecation warnings caused by colcon and setuptools
# https://github.com/colcon/colcon-core/issues/454
ENV PYTHONWARNINGS=ignore:::setuptools.command.install,ignore:::setuptools.command.easy_install,ignore:::pkg_resources
RUN echo "Warning: Using the PYTHONWARNINGS environment variable to silence setup.py and easy_install deprecation warnings caused by colcon"

ENV ROS_DISTRO=humble
ENV ROS_ROOT=/opt/ros/${ROS_DISTRO}

# Build ROS2 core from source
RUN mkdir -p ${ROS_ROOT}/src && \
    cd ${ROS_ROOT} && \
    # https://answers.ros.org/question/325245/minimal-ros2-installation/?answer=325249#post-id-325249
    rosinstall_generator --deps --rosdistro ${ROS_DISTRO} ros_base \
        angles \
        apriltag \
        behaviortree_cpp_v3 \
        bondcpp \
        camera_calibration_parsers \
        camera_info_manager \
        compressed_image_transport \
        compressed_depth_image_transport \
        cv_bridge \
        demo_nodes_cpp \
        demo_nodes_py \
        diagnostic_updater \
        example_interfaces \
        image_geometry \
        image_pipeline \
        image_transport \
        image_transport_plugins \
        launch_xml \
        launch_yaml \
        launch_testing \
        launch_testing_ament_cmake \
        nav2_msgs \
        ompl \
        resource_retriever \
        rosbridge_suite \
        rqt_image_view \
        rviz2 \
        sensor_msgs \
        slam_toolbox \
        v4l2_camera \
        vision_opencv \
        vision_msgs \
	> ros2.${ROS_DISTRO}.ros_base.rosinstall && \
    cat ros2.${ROS_DISTRO}.ros_base.rosinstall && \
    vcs import src < ros2.${ROS_DISTRO}.ros_base.rosinstall && \
    rm ${ROS_ROOT}/*.rosinstall

# Install dependencies using rosdep
RUN cd ${ROS_ROOT} \
    && apt-get update \
    && rosdep init \
    && rosdep update \
    && rosdep install -y \
      --ignore-src \
      --from-paths src \
      --rosdistro ${ROS_DISTRO} \
      --skip-keys "fastcdr rti-connext-dds-6.0.1 rti-connext-dds-5.3.1 urdfdom_headers libopencv-dev libopencv-contrib-dev libopencv-imgproc-dev python-opencv python3-opencv" \
    && rm -Rf /var/lib/apt/lists/* \
    && apt-get clean

# Build ROS2 source
RUN cd ${ROS_ROOT} \
      && colcon build --merge-install --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo --packages-up-to behaviortree_cpp_v3 \
      && colcon build --merge-install --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      && rm -Rf src build log

# Alias setup.bash for consistency with pre-built binary installations of ROS2
RUN echo "source /opt/ros/${ROS_DISTRO}/install/setup.bash ; export ROS_DISTRO=${ROS_DISTRO}" > /opt/ros/${ROS_DISTRO}/setup.bash
    
# Restore using the default Humble DDS middleware: FastRTPS
ENV RMW_IMPLEMENTATION=rmw_fastrtps_cpp

# Install negotiated
RUN apt-get update && mkdir -p ${ROS_ROOT}/src && cd ${ROS_ROOT}/src \
    && git clone https://github.com/osrf/negotiated && cd negotiated && git checkout master && cd .. \            
    && source ${ROS_ROOT}/setup.bash && cd ${ROS_ROOT} \
    && rosdep install -y -r --ignore-src --from-paths src --rosdistro ${ROS_DISTRO} \
    && colcon build --merge-install --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo --packages-up-to-regex negotiated* \
    && rm -Rf src logs build \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
