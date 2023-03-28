# syntax=docker/dockerfile:1.4
# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.224.2/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version (use hirsuite or bionic on local arm64/Apple Silicon): hirsute, focal, bionic
ARG VARIANT="hirsute"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# RUN curl -L -o /var/tmp/graalvm-ce-java17-linux-amd64-22.0.0.2.tar.gz https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-22.0.0.2/graalvm-ce-java17-linux-amd64-22.0.0.2.tar.gz \
# && cd /var/tmp \
# && tar xzvf graalvm-ce-java17-linux-amd64-22.0.0.2.tar.gz \
# && /var/tmp/graalvm-ce-java17-22.0.0.2/bin/gu install native-image

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt -y install --no-install-recommends build-essential libz-dev zlib1g-dev \
    && apt -y install direnv

RUN echo '#!/bin/bash' > /usr/local/bin/xdg-open \
    && echo 'sleep 60' >> /usr/local/bin/xdg-open \
    && chmod +x /usr/local/bin/xdg-open

ARG USERNAME=vscode

# RUN <<EOF
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && mkdir /commandhistory \
    && touch /commandhistory/.bash_history \
    && chown -R $USERNAME /commandhistory \
    && mkdir -p /home/$USERNAME/.local/share/direnv \
    && chown -R $USERNAME /home/$USERNAME/.local/share/direnv \
    && curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 \
    && chmod +x /usr/local/bin/argocd \
    && echo $SNIPPET >> "/home/$USERNAME/.bashrc" \
    && echo 'eval "$(direnv hook bash)"' >> "/home/$USERNAME/.bashrc"
# EOF

# RUN mkdir /home/vscode/.gradle \
#     && chown -R ${USERNAME} /home/vscode/.gradle
