# QLY Docker images

## IPC

### Create image

```bash
docker build -t qly-ipc-sim:v2 -f Dockerfile-IPC .
```

### Create container

```bash
docker run -it --rm --net=host qly-ipc-sim:v2 /bin/bash
```

## Qlyclient

### Create image

```bash
docker build -t qly-client:v2 -f Dockerfile-qlyclient .
```

### Create container

- On host machine
```bash
xhost +local:docker
```

#### Ensure `iw` is installed to identify the wireless card's ip address
```bash
sudo apt install iw
```

```bash
ROSMASTER=http://<IPC_IP_Address>:11311
HOSTIP=$(ip -4 addr show $(iw dev | awk '$1=="Interface"{print $2}') | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

docker run -it --rm -e ROS_HOSTNAME=$HOSTIP -e ROS_MASTER_URI=$ROSMASTER -e DISPLAY=$DISPLAY --volume="/tmp/.X11-unix:/tmp/.X11-unit:rw" --volume="/usr/lib/.../libGL.so.1:/usr/lib/.../libGL.so.1:ro" --device=/dev/dri:/dev/dri --net=host qly-client:v4 /bin/bash
```