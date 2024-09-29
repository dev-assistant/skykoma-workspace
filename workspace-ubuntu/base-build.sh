docker build -f DockerfileBase -t registry.hylstudio.local/skykoma-workspace:1.16.0-base .
docker tag registry.hylstudio.local/skykoma-workspace:1.16.0-base registry.cn-hangzhou.aliyuncs.com/hylstudio/workspace:20240929-skykoma-workspace-1.16.0-base
docker push registry.cn-hangzhou.aliyuncs.com/hylstudio/workspace:20240929-skykoma-workspace-1.16.0-base