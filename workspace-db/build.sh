TAG=2024031605-workspace-db
REGISTRY=registry.cn-hangzhou.aliyuncs.com/hylstudio/workspace
# export BUILDKIT_HOST=tcp://10.110.190.102:1234
# CACHE_OPTS="--no-cache"
# sudo nerdctl --namespace k8s.io build $CACHE_OPTS -f DockerFile --buildkit-host $BUILDKIT_HOST \
	# -t $REGISTRY:$TAG .
doceker build $CACHE_OPTS -f DockerFile -t REGISTRY:$TAG .
