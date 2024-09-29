# web-workspace
builds a docker image to run idea in a container, which is based on [kasmtech/workspaces-images](https://github.com/kasmtech/workspaces-images).
## Functions
1. 
## Usage

1. Run the container as a daemon.
```bash
docker run --name webide-idea --hostname=ubuntu --shm-size=512m \
    -e LOCAL_USER_UID=0 -e PERSISTENT_HOME=1 -e PERSISTENT_HOME_DIR=/data/root \
    -e VNC_PW=password \
    -e PROJECTOR_SERVER_TOKEN=123456 \
    -p 6901:6901 \
    -p 2222:22 \
    -p 8887:8887 \
    -p 2333:2333 \
    registry.hylstudio.local/skykoma-webide:2024092801
```

2. Configure corplink via a browser: https://localhost:6901.

* User : kasm_user
* Password: $VNC_PW

## Dev
TODO 
## Acknowledgments

* Thanks [kasmtech](https://github.com/kasmtech) for providing some great open source tools.
