export BUILDKIT_HOST=tcp://10.110.190.102:1234
TAG=2024030909
#CACHE_OPTS="--no-cache"
sudo nerdctl --namespace k8s.io build $CACHE_OPTS -f DockerFile --buildkit-host $BUILDKIT_HOST \
	-t registry.cn-hangzhou.aliyuncs.com/hylstudio/workspace:$TAG .
