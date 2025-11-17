#!/bin/bash
set -e

# Source standard ROS Melodic environment
source /opt/ros/melodic/setup.bash

# Attempt to source QLY environment (assuming qlybot.deb sets up /opt/qlybot)
if [ -f "/opt/qlybot/setup.bash" ]; then
    source /opt/qlybot/setup.bash
    echo "QLY proprietary environment sourced from /opt/qlybot."
fi

# Set ROS IP to 0.0.0.0 to bind to all available interfaces (necessary for --net=host)
export ROS_IP=0.0.0.0

# Start ROS Master
roscore &
MASTER_PID=$!
echo "ROS Master started on port 11311"
sleep 5

# --- Step 1: Publish Static Map (Simulating map_server node) ---
rosrun map_server map_server /home/qlybot/.qlybot_map/test_map.yaml &
echo "Map Server started."

# --- Step 2: Publish TF Transforms (Simulating IMU/Odometry/AMCL) ---
# TF is essential for visualization [9]. AMCL publishes the map->odom transform [10, 11].

# A. map -> odom (Simulating AMCL/Localization output)
rosrun tf static_transform_publisher 0 0 0 0 0 0 map odom 100 &
echo "Published transform: map -> odom"

# B. odom -> base_link (Simulating Odometry data, likely provided by Chassis Control Board [12, 13])
# Note: The QLY logs refer to /odom_unfused [13, 14], but the navigation stack ultimately requires odom -> base_link.
rosrun tf static_transform_publisher 0 0 0 0 0 0 odom base_link 100 &
echo "Published transform: odom -> base_link"

# C. base_link -> laser (Simulating Lidar sensor frame)
rosrun tf static_transform_publisher 0.1 0 0.2 0 0 0 base_link laser 100 &
echo "Published transform: base_link -> laser"


# --- Step 3: Simulate Sensor Data (Topics referenced in QLY logs) ---
# Simulate Lidar Scan topic, used for localization and costmaps [10, 15, 16].
rostopic pub -r 10 /scan sensor_msgs/LaserScan "header: 
  stamp: now
  frame_id: laser
angle_min: -3.14
angle_max: 3.14
angle_increment: 0.0174
time_increment: 0.0
scan_time: 0.1
range_min: 0.0
range_max: 10.0
ranges: [2.0, 2.0, 2.0, 2.0, 2.0]" &

# Simulate mandatory chassis topics referenced in troubleshooting guides [13, 14]:
rostopic pub -r 5 /battery sensor_msgs/BatteryState {} &
rostopic pub -r 10 /imu sensor_msgs/Imu {} &
rostopic pub -r 10 /odom_unfused nav_msgs/Odometry {} &

echo "Simulated QLY IPC Master environment fully operational."

# Wait for the roscore process to finish
wait $MASTER_PID
