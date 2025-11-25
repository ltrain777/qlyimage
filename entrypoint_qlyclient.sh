#!/bin/bash
set -e

# 1. Source standard ROS Noetic environment
source /opt/ros/noetic/setup.bash

# 2. Source QLY proprietary debug environment
# This step is critical as it sets paths needed for 'qly_debug_rviz' [4-6].
 if [ -f "/opt/qlydbg/setup.bash" ]; then
     source /opt/qlydbg/setup.bash
     echo "QLY debug environment sourced."
 else
     echo "Warning: /opt/qlydbg/setup.bash not found. Cannot guarantee launch functionality."
 fi

# 3. ROS_HOSTNAME must be dynamically set at runtime via the 'docker run' command
# The user must provide the laptop's IP address on the QLY network (e.g., 192.168.254.100).
if [ -z "$ROS_HOSTNAME" ]; then
    echo "FATAL: ROS_HOSTNAME environment variable is not set. Cannot establish communication."
    exit 1
fi

# 4. ROS_MASTER_URI needs to point to the QLY robot's ROS master.
# The user must provide the robot's IP address on the QLY network (e.g.,
if [ -z "$ROS_MASTER_URI" ]; then
    echo "FATAL: ROS_MASTER_URI environment variable is not set. Cannot establish communication."
    exit 1
fi  

# Execute the command passed to the container (e.g., roslaunch qly_debug_rviz nav_rviz.launch)
exec "$@"