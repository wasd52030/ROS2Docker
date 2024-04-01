#!/bin/bash
set -e

# setup ros2 environment
source "/opt/ros/$ROS_DISTRO/setup.bash"

# initial for ros2 workspace
filename='/ROS2Docker/install/setup.bash'
if [ -f $filename ]; then
    source $filename
fi

exec $@