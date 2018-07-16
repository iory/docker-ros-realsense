FROM ubuntu:16.04

MAINTAINER iory ab.ioryz@gmail.com

RUN apt update
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116

ENV ROS_DISTRO kinetic

# Install ROS base and rosinstall
RUN apt update && \
DEBIAN_FRONTEND=noninteractive apt install -y \
wget \
python-pip \
python-rosinstall \
python-catkin-tools \
ros-${ROS_DISTRO}-ros-base \
ros-${ROS_DISTRO}-jsk-tools \
ros-${ROS_DISTRO}-rgbd-launch \
ros-${ROS_DISTRO}-image-transport-plugins \
ros-${ROS_DISTRO}-image-transport && \
rm -rf /var/lib/apt/lists/*
RUN rosdep init \
    &&  rosdep update

# Setup ROS environment variables globally
RUN echo 'source /opt/ros/${ROS_DISTRO}/setup.bash' >> /etc/bash.bashrc

ENV LIBREALSENSE_VERSION 2.10.2
RUN wget https://github.com/IntelRealSense/librealsense/archive/v${LIBREALSENSE_VERSION}.tar.gz
RUN tar xvzf v${LIBREALSENSE_VERSION}.tar.gz
RUN mkdir -p librealsense-${LIBREALSENSE_VERSION}/build
RUN apt update && \
    apt install -y \
        libusb-1.0-0 \
        libusb-1.0-0-dev \
        freeglut3-dev \
        libgtk-3-dev \
        libglfw3-dev && \
        rm -rf /var/lib/apt/lists/*
RUN cd librealsense-${LIBREALSENSE_VERSION}/build; cmake ..
RUN cd librealsense-${LIBREALSENSE_VERSION}/build; make -j; make install

ENV LIBREALSENSE_ROS_VERSION 2.0.3
RUN mkdir -p catkin_ws/src
RUN wget https://github.com/intel-ros/realsense/archive/${LIBREALSENSE_ROS_VERSION}.tar.gz
RUN tar xvzf ${LIBREALSENSE_ROS_VERSION}.tar.gz
RUN mv realsense-${LIBREALSENSE_ROS_VERSION} catkin_ws/src/realsense
RUN cd catkin_ws; rosdep install -r -y --from-paths src --ignore-src
RUN mv /bin/sh /bin/sh_tmp && ln -s /bin/bash /bin/sh
RUN source /opt/ros/${ROS_DISTRO}/setup.bash; cd catkin_ws; catkin build
RUN rm /bin/sh && mv /bin/sh_tmp /bin/sh
RUN touch /root/.bashrc && \
    echo "source /catkin_ws/devel/setup.bash\n" >> /root/.bashrc && \
    echo "rossetip\n" >> /root/.bashrc && \
    echo "rossetmaster localhost"
RUN useradd -ms /bin/bash ros && \
    groupadd gpio && \
    groupadd realtime-control && \
    addgroup ros realtime-control

COPY ./ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
