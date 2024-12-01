# download origin ide
FROM alpine as ide-downloader
# https://download.jetbrains.com/idea/ideaIC-2021.2.3.tar.gz
ARG downloadUrl
RUN mkdir -p /download/ide && cd /download/ide && wget -q $downloadUrl -O ide.tar.gz
# find . -maxdepth 1 -type d -name ideaIC -exec mv {}/* $PROJECTOR_DIR/ide \;
# after unzip 894MB -> 3G, too large

# maven download
FROM alpine as maven-downloader
RUN mkdir -p /download && \
    cd /download && \
    wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz && \
    tar -xvzf apache-maven-3.9.9-bin.tar.gz
# projector server
FROM alpine as projector-downloader
ARG projectorServerUrl
RUN mkdir /download && cd /download && \
    wget -q $projectorServerUrl -O /download/projector-server.zip && \
    unzip /download/projector-server.zip && \
    rm /download/projector-server.zip && \
    find . -maxdepth 1 -type d -name projector-server-* -exec mv {} projector-server \;
# workspace
# FROM kasmweb/core-ubuntu-noble:1.16.0 as workspace
FROM kasmweb/core-ubuntu-jammy:1.16.0 as workspace
ENV PROJECTOR_USER_NAME kasm-user
ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

USER root
######### Customize Container Here ###########
# apt source
RUN mv /etc/apt/sources.list /etc/apt/sources_backup.list && \
echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse" >> /etc/apt/sources.list && \
echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
echo "deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list
RUN true \
# Any command which returns non-zero exit code will cause this shell script to exit immediately:
   && set -e \
# Activate debugging to show execution details: all commands will be printed before execution
   && set -x \
# install packages:
    && apt update \
# openjdk-17-jdk 274MB | build-essential 181MB | libsecret-1-dev 55.9MB | others 14MB 
    && apt install --no-install-recommends tzdata supervisor openssh-server gosu iputils-ping telnet jq moreutils lsof strace apt-utils make libxss1 psmisc lrzsz vim git wget curl bash-completion net-tools sudo ca-certificates procps tar zip unzip tmux python3 openjdk-17-jdk -y \
# clean apt to reduce image size:
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* \
    && rm -rf /var/cache/apt
# sudoers
RUN echo "$PROJECTOR_USER_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# sshd
RUN mkdir /var/run/sshd
EXPOSE 22
# TODO find why 777
RUN chmod 777 /var/run && \
    chmod 777 /etc/supervisor
RUN sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
	sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
	sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    sed -i "s/AllowTcpForwarding.*/AllowTcpForwarding yes/g" /etc/ssh/sshd_config && \
    sed -i "1i\export LESSCHARSET=utf-8" /etc/profile && \
    sed -i "1i\export STARTUPDIR=/dockerstartup" /etc/profile && \
    sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/g' /etc/ssh/sshd_config && \
    sed -i 's/#GatewayPorts no/GatewayPorts yes/g' /etc/ssh/sshd_config

#config nvm
ENV NODE_VERSION=v20.17.0
ENV NVM_DIR $HOME/.nvm
# https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh
# https://gitee.com/RubyMetric/nvm-cn/raw/main/install.sh
RUN curl -fsSL https://gitee.com/RubyMetric/chsrc/releases/download/v0.1.9/chsrc-x64-linux -o chsrc \
    && chmod +x ./chsrc
RUN curl -fsSL https://gitee.com/RubyMetric/nvm-cn/raw/main/install.sh | bash \
    && . $NVM_DIR/nvm.sh  \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use $NODE_VERSION \
    && ./chsrc set node \
    && npm install -g yarn node-gyp
# use sudo so that user does not get sudo usage info on (the first) login
RUN echo "Running 'sudo' for $PROJECTOR_USER_NAME: success" && \
    # create .bashrc.d folder and source it in the bashrc
    mkdir -p $HOME/.bashrc.d && \
    (echo; echo "for i in \$(ls -A \$HOME/.bashrc.d/); do source \$HOME/.bashrc.d/\$i; done"; echo) >> $HOME/.bashrc
RUN echo ". ~/.nvm/nvm-lazy.sh"  >> $HOME/.bashrc.d/50-node

# #config java and maven
# RUN wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz && \
#     tar -xvzf apache-maven-3.9.9-bin.tar.gz && \
#     cp -r apache-maven-3.9.9 /opt/maven && \
#     rm -rf apache-maven-*

#config java and maven
RUN cat /root/.bashrc >> ~/.bashrc && \
# mv /root/.bashrc avoid kasm_default_profile.sh skip profile init
    rm -rf /root/.bashrc && \
    echo 'JAVA_HOME=/usr/lib/jvm/java-1.17.0-openjdk-amd64' >> ~/.bashrc && \
    echo 'M2_HOME=/opt/maven' >> ~/.bashrc && \
    echo 'MAVEN_HOME=/opt/maven' >> ~/.bashrc && \
    echo 'PATH=${M2_HOME}/bin:${PATH}' >> ~/.bashrc

# Install Edge
# COPY ./src/ubuntu/install/edge $INST_SCRIPTS/edge/
# COPY edge.deb $INST_SCRIPTS/edge/
# RUN bash $INST_SCRIPTS/edge/install_edge.sh  && rm -rf $INST_SCRIPTS/edge/

# static files
ENV PROJECTOR_DIR /projector
RUN mkdir -p $PROJECTOR_DIR
COPY static $PROJECTOR_DIR
# above, we are adding the lazy nvm init to .bashrc, because one is executed on interactive shells, the other for non-interactive shells (e.g. plugin-host)
RUN chmod +x $PROJECTOR_DIR/*.sh \
    && mv $PROJECTOR_DIR/nvm-lazy.sh $HOME/.nvm/nvm-lazy.sh \
    && chown $PROJECTOR_USER_NAME:$PROJECTOR_USER_NAME $HOME/.nvm/nvm-lazy.sh
COPY --from=ide-downloader /download/ide $PROJECTOR_DIR/ide
COPY --from=projector-downloader /download/projector-server $PROJECTOR_DIR/ide/projector-server
RUN chmod 644 $PROJECTOR_DIR/ide/projector-server/lib/*
RUN true \
# Any command which returns non-zero exit code will cause this shell script to exit immediately:
    && set -e \
# Activate debugging to show execution details: all commands will be printed before execution
    && set -x \
# change user to non-root (http://pjdietz.com/2016/08/28/nginx-in-docker-without-root.html):
    # && mv $PROJECTOR_DIR/$PROJECTOR_USER_NAME /home \
    && chmod g+rw /home && mkdir -p /home/$PROJECTOR_USER_NAME && mkdir -p /home/project \
    # && useradd -d /home/$PROJECTOR_USER_NAME -s /bin/bash -G sudo $PROJECTOR_USER_NAME \
    && chown -R $PROJECTOR_USER_NAME.$PROJECTOR_USER_NAME /home/$PROJECTOR_USER_NAME \
    && chown -R $PROJECTOR_USER_NAME.$PROJECTOR_USER_NAME /home/project \
    && ln -s $PROJECTOR_DIR/ide/bin/idea.sh /usr/local/bin/idea \
    && chmod +x $PROJECTOR_DIR/run.sh

# add desktop icon
RUN cp /usr/share/applications/xfce4-terminal-emulator.desktop $HOME/Desktop && \
    cp /usr/share/applications/xfce-settings-manager.desktop $HOME/Desktop && \
    cp /usr/share/applications/xfce4-terminal-emulator.desktop $HOME/Desktop
RUN cat <<EOF > $HOME/Desktop/idea.desktop
[Desktop Entry]
Encoding=UTF-8
Name=IntelliJ IDEA
Comment=IntelliJ IDEA
Exec=$PROJECTOR_DIR/normal_idea_entrypoint.sh
Icon=$PROJECTOR_DIR/ide/bin/idea.svg
Terminal=false
Type=Application
Categories=Application;Development;
EOF
RUN cat <<EOF >$HOME/Desktop/idea-projector.desktop
[Desktop Entry]
Encoding=UTF-8
Name=IntelliJ IDEA Projector
Comment=IntelliJ IDEA Projector
Exec=$PROJECTOR_DIR/projector_entrypoint.sh projector
Icon=$PROJECTOR_DIR/ide/bin/idea.svg
Terminal=false
Type=Application
Categories=Application;Development;
EOF
EXPOSE 8887
# config kasm
RUN sed -i "/openssl req/i if [ ! -f \${HOME}/.vnc/self.pem ]; then" $STARTUPDIR/vnc_startup.sh 
RUN sed -i "/openssl req/a fi" $STARTUPDIR/vnc_startup.sh
RUN mv $PROJECTOR_DIR/custom_startup.sh $STARTUPDIR/custom_startup.sh && chmod +x $STARTUPDIR/custom_startup.sh
RUN chmod +x $HOME/Desktop/*.desktop && \
    chmod 750 $HOME && \
    echo "export LC_ALL=C.UTF-8">> ~/.bashrc && \
    echo "export LANG=C.UTF-8">> ~/.bashrc && \
    echo "set -g mouse on">> ~/.tmux.conf && \
    touch /tmp/FdGdNndyS8H5aqv41BwUep1OprV4mWGH
######### End Customizations ###########
USER root
# avoid using /root, getPwd will error cause kasm_entrypoint.sh will mv $HOME dynamic
WORKDIR /
ENTRYPOINT ["/projector/kasm_entrypoint.sh", "/projector/init_services.sh", "/dockerstartup/kasm_default_profile.sh", "/dockerstartup/vnc_startup.sh"]
# ENTRYPOINT ["/bin/bash"]
