# syntax=docker/dockerfile:1.4
# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.224.2/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version (use hirsuite or bionic on local arm64/Apple Silicon): hirsute, focal, bionic
ARG VERSION="22.04-1.0.6"
ARG BASE="registry-git.harvest.fr/o2s/o2s-modularisation/templates/terraform-argocd-gitlab/devcontainer"
FROM ${BASE}:${VERSION}

USER vscode

RUN HOMEBREW_NO_AUTO_UPDATE=1 brew install kubectl krew python rancher-cli kubectx fzf \
    && HOMEBREW_NO_AUTO_UPDATE=1 brew cleanup

RUN kubectl krew install neat konfig

RUN pip3 install pre-commit

ARG USERNAME=vscode
RUN mkdir -p /home/$USERNAME/.rancher \
    && chown -R $USERNAME /home/$USERNAME/.rancher \
    && mkdir /home/$USERNAME/.argocd -p \
    && chown -R $USERNAME /home/$USERNAME/.argocd

RUN echo 'source /workspaces/*/.devcontainer/.zshrc_parts' >> /home/vscode/.zshrc
