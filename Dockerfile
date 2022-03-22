# renovate: datasource=github-releases depName=Nothing4You/docker-machine-driver-proxmox-ve
ARG DOCKER_MACHINE_DRIVER_PROXMOX_VE_VERSION=v4.0.1

FROM alpine/git:v2.32.0@sha256:a8a31155488a93a4d8abb834777c7b5f9d7c93db6051defbad8cc066b4e90072 AS builder-git

ARG BUILD_USER_UID=76543
ARG BUILD_USER_GID=76543 

ARG DOCKER_MACHINE_DRIVER_PROXMOX_VE_VERSION

RUN mkdir /build && chown ${BUILD_USER_UID}:${BUILD_USER_GID} /build

USER ${BUILD_USER_UID}:${BUILD_USER_GID}
WORKDIR /build

RUN git clone https://github.com/Nothing4You/docker-machine-driver-proxmox-ve . && git checkout "${DOCKER_MACHINE_DRIVER_PROXMOX_VE_VERSION}" && rm -rf .git


FROM golang:1.17.6-alpine3.15@sha256:519c827ec22e5cf7417c9ff063ec840a446cdd30681700a16cf42eb43823e27c AS builder-go

ARG BUILD_USER_UID=76543
ARG BUILD_USER_GID=76543 

RUN mkdir /build && chown ${BUILD_USER_UID}:${BUILD_USER_GID} /build

COPY --from=builder-git --chown=${BUILD_USER_UID}:${BUILD_USER_GID} /build/ /build/

USER ${BUILD_USER_UID}:${BUILD_USER_GID}
WORKDIR /build

RUN GOCACHE=/build/.gocache CGO_ENABLED=0 GOOS=linux go build -o docker-machine-driver-proxmoxve


FROM gitlab/gitlab-runner:alpine-v14.5.1@sha256:0ad99eb517f778558486ae29bd79a0e55670aefdccee46f768741c4652ac6870

COPY --from=builder-go --chown=0:0 /build/docker-machine-driver-proxmoxve /usr/bin/
