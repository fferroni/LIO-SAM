ARG cuda_version=11.4.2
ARG ubuntu_version=18.04

FROM nvidia/cudagl:${cuda_version}-devel-ubuntu${ubuntu_version}

################################################################################
# Install ROS melodic
RUN apt-get update && apt-get install -y curl

RUN DEBIAN_FRONTEND=noninteractive apt-get install tzdata
ENV TZ="Europe/London"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN sh -c '. /etc/lsb-release && echo "deb http://packages.ros.org.ros.informatik.uni-freiburg.de/ros/ubuntu bionic main" > /etc/apt/sources.list.d/ros-melodic.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

# Install 'ros-melodic-desktop-full' packages (including ROS, Rqt, Rviz, and more).
RUN apt-get update && apt-get install -y --no-install-recommends \
ros-melodic-desktop-full \
&& rm -rf /var/lib/apt/lists/*
# Install ROS bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
python3-catkin-pkg \
python3-rospkg \
python3-rosdep \
python3-rosinstall \
python3-vcstools \
python3-rosinstall-generator \
python3-wstool
#############################################
# Install ROS Noetic 
RUN rosdep init && rosdep update
###################################################################################

RUN apt-get update \
    && apt-get install -y curl \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - \
    && apt-get update \
    && apt-get install -y \
    ros-melodic-cv-bridge \
    ros-melodic-perception-pcl \
    ros-melodic-pcl-msgs \
    ros-melodic-vision-opencv \
    ros-melodic-xacro \
    ros-melodic-navigation \
    ros-melodic-robot-localization \
    ros-melodic-robot-state-publisher \
    ros-melodic-rviz \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt install -y software-properties-common \
    && add-apt-repository -y ppa:borglab/gtsam-release-4.0 \
    && apt-get update \
    && apt install -y libgtsam-dev libgtsam-unstable-dev \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt install -y git

SHELL ["/bin/bash", "-c"]

RUN mkdir -p ~/catkin_ws/src \
    && cd ~/catkin_ws/src \
    && git clone https://github.com/TixiaoShan/LIO-SAM.git \
    && cd .. \
    && source /opt/ros/melodic/setup.bash \
    && catkin_make

RUN echo "source /opt/ros/melodic/setup.bash" >> /root/.bashrc \
    && echo "source /root/catkin_ws/devel/setup.bash" >> /root/.bashrc

WORKDIR /root/catkin_ws
