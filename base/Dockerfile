FROM buildpack-deps:jammy

COPY install-packages upgrade-packages create-overlay runonce /usr/bin/

### base ###
RUN yes | unminimize \
    && install-packages \
        zip \
        unzip \
        bash-completion \
        build-essential \
        ninja-build \
        htop \
        iputils-ping \
        jq \
        less \
        locales \
        man-db \
        nano \
        ripgrep \
        software-properties-common \
        sudo \
        stow \
        time \
        emacs-nox \
        vim \
        multitail \
        lsof \
        ssl-cert \
        fish \
        zsh \
    && curl -o /usr/bin/fuse-overlayfs \
    -L https://github.com/containers/fuse-overlayfs/releases/download/v1.11/fuse-overlayfs-x86_64 \
    && chmod +x /usr/bin/fuse-overlayfs \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8

### Update and upgrade the base image ###
RUN upgrade-packages

### Git ###
RUN add-apt-repository -y ppa:git-core/ppa
RUN install-packages git git-lfs

### Gitpod user ###
# '-l': see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod \
    # Remove `use_pty` option and enable passwordless sudo for users in the 'sudo' group
    && sed -i.bkp -e '/Defaults\tuse_pty/d' -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers \
    # To emulate the workspace-session behavior within dazzle build env
    && mkdir /workspace && chown -hR gitpod:gitpod /workspace

ENV HOME=/home/gitpod
WORKDIR $HOME

# Configure Git
COPY default.gitconfig /etc/gitconfig
COPY default.gitconfig $HOME/.gitconfig
RUN git lfs install --system --skip-repo

### Gitpod user (2) ###
USER gitpod
# use sudo so that user does not get sudo usage info on (the first) login
RUN sudo echo "Running 'sudo' for Gitpod: success" \
    # create .bashrc.d and .runonce dirs
    && mkdir -p $HOME/.bashrc.d $HOME/.runonce \
    # custom Bash prompt
    && printf "PS1='%s'\n"  '\033[1;32m\u\033[0m \033[1;34m\w\033[0m$(__git_ps1 " (%s)") $ ' >> $HOME/.bashrc \
    # startup scripts loader
    && printf '%s\n'        'runonce' \
                            'for i in $(ls -A $HOME/.bashrc.d/); do source $HOME/.bashrc.d/$i; done' >> $HOME/.bashrc \
    # create a completions dir for gitpod user
    && mkdir -p $HOME/.local/share/bash-completion/completions

# Custom PATH additions
ENV PATH=$HOME/.local/bin:/usr/games:$PATH
