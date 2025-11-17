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

```bash
docker run -it --rm -e ROS_HOSTNAME="192.168.68.70" -e DISPLAY=$DISPLAY --volume="/tmp/.X11-unix:/tmp/.X11-unit:rw" --volume="/usr/lib/.../libGL.so.1:/usr/lib/.../libGL.so.1:ro" --device=/dev/dri:/dev/dri --net=host qly-client:v2 /bin/bash
```