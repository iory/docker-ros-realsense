# Docker for d415/d435 using ROS

Connect d415 or d435 to your pc and enter following command in your terminal.

```
docker run --rm --net=host --privileged --volume=/dev:/dev -it iory/realsense-ros-docker:kinetic /bin/bash -i -c 'roslaunch realsense2_camera rs_rgbd.launch enable_pointcloud:=true align_depth:=false depth_registered_processing:=true align_depth:=true'
```

If you would like to change ```ROS_MASTER_URI```,

```
docker run --rm --net=host --privileged --volume=/dev:/dev -it iory/realsense-ros-docker:kinetic /bin/bash -i -c 'rossetmaster TARGET_IP; roslaunch realsense2_camera rs_rgbd.launch enable_pointcloud:=true align_depth:=false depth_registered_processing:=true align_depth:=true'
```
