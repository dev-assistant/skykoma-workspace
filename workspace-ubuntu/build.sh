TAG=2024100901-skykoma-workspace
REGISTRY=registry.cn-hangzhou.aliyuncs.com/hylstudio/workspace
downloadUrl=https://download.jetbrains.com/idea/ideaIC-2023.1.5.tar.gz
projectorServerUrl=https://github.com/956237586/projector-server/releases/download/v1.8.1.12/projector-server-v1.8.1.12.zip
# CACHE_OPTS="--no-cache"
# PROGRESS_OPTS="--progress=plain"
docker build $CACHE_OPTS -f Dockerfile --build-arg downloadUrl=$downloadUrl --build-arg projectorServerUrl=$projectorServerUrl -t $REGISTRY:$TAG .
docker push $REGISTRY:$TAG
exit 0
#local mirrors
downloadUrl=http://192.168.0.3:5004/ideaIC-2023.1.5.tar.gz
projectorServerUrl=http://192.168.0.3:5004/projector-server-v1.8.1.12.zip
LOCAL_REGISTRY=registry.hylstudio.local/skykoma-workspace
docker tag $REGISTRY:$TAG $LOCAL_REGISTRY:$TAG
docker push $LOCAL_REGISTRY:$TAG