# docker run --name test --hostname=ubuntu --shm-size=512m -p 6901:6901  -e VNC_PW=password registry.hylstudio.local/skykoma-webide:test

# --shm-size default is 64MB not engough xfdesktop used, showing by ipcs -m --human
docker run --name test1 --hostname=ubuntu --shm-size=512m \
    -e LOCAL_USER_UID=0 -e PERSISTENT_HOME=1 -e PERSISTENT_HOME_DIR=/data/root \
    -e VNC_PW=password \
    -e PROJECTOR_SERVER_TOKEN=123456 \
    -p 6901:6901 \
    -p 2222:22 \
    -p 8887:8887 \
    -p 2333:2333 \
    registry.hylstudio.local/skykoma-webide:2024092801
# TODO 分析 nvm 安装过程，做多阶段DockerFile缓存