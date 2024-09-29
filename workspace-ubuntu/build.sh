# docker build -f DockerfileBase -t registry.hylstudio.local/skykoma-webide:1.16.0-base .
TAG=2024092901
REGISTRY=registry.hylstudio.local/skykoma-webide
downloadUrl=http://192.168.0.3:5004/ideaIC-2023.1.5.tar.gz
projectorServerUrl=http://192.168.0.3:5004/projector-server-v1.8.1.9.zip
#--no-cache --progress=plain 
docker build -f Dockerfile --build-arg downloadUrl=$downloadUrl --build-arg projectorServerUrl=$projectorServerUrl -t $REGISTRY:$TAG .
