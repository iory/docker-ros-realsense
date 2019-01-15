FROM ros:kinetic

LABEL maintainer="iory ab.ioryz@gmail.com"

ENV ROS_DISTRO kinetic

RUN apt update && \
DEBIAN_FRONTEND=noninteractive apt install -y \
software-properties-common \
wget \
python-rosinstall \
python-catkin-tools \
ros-${ROS_DISTRO}-jsk-tools \
ros-${ROS_DISTRO}-rgbd-launch \
ros-${ROS_DISTRO}-image-transport-plugins \
ros-${ROS_DISTRO}-image-transport && \
rm -rf /var/lib/apt/lists/*


RUN apt-key adv --keyserver keys.gnupg.net --recv-key C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C8B3A55A6F3EFCDE
RUN add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo xenial main" -u

RUN mkdir -p /catkin_ws/src && cd /catkin_ws/src && \
  git clone https://github.com/IntelRealSense/librealsense
RUN cd catkin_ws; rosdep install -r -y --from-paths src --ignore-src
RUN DEBIAN_FRONTEND=noninteractive apt install -y \
  libusb-1.0-0 \
  libusb-1.0-0-dev \
  freeglut3-dev \
  libgtk-3-dev \
  libglfw3-dev
RUN mv /bin/sh /bin/sh_tmp && ln -s /bin/bash /bin/sh
RUN source /opt/ros/${ROS_DISTRO}/setup.bash; cd catkin_ws; catkin build
RUN rm /bin/sh && mv /bin/sh_tmp /bin/sh
RUN touch /root/.bashrc && \
    echo "source /catkin_ws/devel/setup.bash\n" >> /root/.bashrc && \
    echo "rossetip\n" >> /root/.bashrc && \
    echo "rossetmaster localhost"

COPY ./ros_entrypoint.sh /
ENTRYPOINT ["/ros_entrypoint.sh"]

CMD ["bash"]
