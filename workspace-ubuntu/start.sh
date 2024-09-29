# docker run --name test --hostname=ubuntu --shm-size=512m -p 6901:6901 -e VNC_PW=password registry.hylstudio.local/skykoma-workspace:1.16.0-base
IMAGE=registry.cn-hangzhou.aliyuncs.com/hylstudio/workspace:2024092901-skykoma-workspace
# IMAGE=registry.hylstudio.local/skykoma-workspace:2024092801
docker run --name skykoma-workspace --hostname=ubuntu --shm-size=512m \
    -e LOCAL_USER_UID=0 -e PERSISTENT_HOME=1 -e PERSISTENT_HOME_DIR=/data/root \
    -e VNC_PW=password \
    -e PROJECTOR_SERVER_TOKEN=123456 \
    -p 6901:6901 \
    -p 2222:22 \
    -p 8887:8887 \
    -p 2333:2333 \
    -p 7171:7171 \
    -v /data:/data \  
    $IMAGE
# TODO 分析 nvm 安装过程，做多阶段DockerFile缓存
