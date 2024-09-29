TAG=2024092902
REGISTRY=registry.hylstudio.local/skykoma-workspace
downloadUrl=http://192.168.0.3:5004/ideaIC-2023.1.5.tar.gz
projectorServerUrl=http://192.168.0.3:5004/projector-server-v1.8.1.9.zip
# CACHE_OPTS="--no-cache"
# PROGRESS_OPTS="--progress=plain"
docker build $CACHE_OPTS -f Dockerfile --build-arg downloadUrl=$downloadUrl --build-arg projectorServerUrl=$projectorServerUrl -t $REGISTRY:$TAG .
docker push $REGISTRY:$TAG
exit 0
# ali cloud mirrors
ALI_REGISTRY=registry.cn-hangzhou.aliyuncs.com/hylstudio/workspace
ALI_TAG=$TAG-skykoma-workspace
docker tag $REGISTRY:$TAG $ALI_REGISTRY:$ALI_TAG
docker push $ALI_REGISTRY:$ALI_TAG