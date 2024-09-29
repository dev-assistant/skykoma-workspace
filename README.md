# web-workspace
builds a docker image to run idea in a container, which is based on [kasmtech/workspaces-images](https://github.com/kasmtech/workspaces-images).
## Features
1. prepared dev envs: python3、maven-3.9、jdk17、nvm
2. bundle jetbrains idea community, support projector server and windowed mode
3. postponed ide.tar.gz decompression to `init_services.sh` reduce image size
4. change ubuntu tsinghua mirrors、nvm mirrors using `chsrc`
## Usage

1. Run the container as a daemon.
`--shm-size` default is 64MB not engough xfdesktop used, can be listed by `ipcs -m --human`
```bash
docker run --name skykoma-workspace --hostname=ubuntu --shm-size=512m \
    -e LOCAL_USER_UID=0 -e PERSISTENT_HOME=1 -e PERSISTENT_HOME_DIR=/data/root \
    -e VNC_PW=password \
    -e PROJECTOR_SERVER_TOKEN=123456 \
    -p 6901:6901 \
    -p 2222:22 \
    -p 8887:8887 \
    -p 2333:2333 \
    registry.hylstudio.local/skykoma-workspace:2024092801
```

1. Configure corplink via a browser: https://localhost:6901.

* User : kasm_user
* Password: $VNC_PW

## Dev info
see `build.sh` and `DockefFile` for all details
1. `kasm_entrypoint.sh` 
   - persist home dir if env `PERSISTENT_HOME` and `PERSISTENT_HOME_DIR` has been set
2. `init_services.sh` 
   - unzip idea package if `$PROJECTOR_DIR/ide/ide.tar.gz` exists
   - init idea `idea.properties` and `idea64.vmoptions`
   - disable tips of the day
   - disable auto update and new version check
   - open idea internal actions menu
3. `kasm_default_profile.sh` and `vnc_startup.sh` is kasm official file
   - skip openssl self sign req in `vnc_startup.sh` if cert file already exists
4. `custom_startup.sh` will be executed by `vnc_startup.sh` on kasm starup seq
   - init `/tmp/autorestart` with value `1`
   - kasm_startup will be execute
   - check process using `pgrep -f com.intellij.idea.Main`, autorestart if process not exists
   - if `/tmp/autorestart` not been disabled, execute `/projector/ide/bin/idea.sh` and idea.sh subprocess will not exit
5. `projector_entrypoint.sh` and `normal_idea_entrypoint.sh`
   - switch projector mode and windowed mode by changing /tmp/autorestart
   - TODO replace START_COMMAND depends on env settings on startup
## Acknowledgments

* Thanks [kasmtech](https://github.com/kasmtech) for providing some great open source tools.
