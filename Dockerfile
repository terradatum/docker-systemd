FROM ubuntu:bionic

LABEL maintainer="G. Richard Bellamy <rbellamy@terradatum.com>" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="terradatum/github-runner" \
  org.label-schema.description="Dockerized GitHub Actions runner." \
  org.label-schema.url="https://github.com/terradatum/github-runner" \
  org.label-schema.vcs-url="https://github.com/terradatum/github-runner" \
  org.label-schema.vendor="Terradatum" \
  org.label-schema.docker.cmd="docker run -it \
    --name=ubuntu-systemd \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    --tmpfs /tmp \
    --tmpfs /run \
    terradatum/ubuntu-systemd:bionic"

ENV container docker
ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's/# deb/deb/g' /etc/apt/sources.list

RUN apt-get update \
    && apt-get install -y systemd systemd-sysv systemd-cron snapd fuse squashfuse locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && locale-gen en_US.UTF-8

RUN cd /lib/systemd/system/sysinit.target.wants/ \
    && ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF

STOPSIGNAL SIGRTMIN+3
CMD ["/usr/lib/systemd/systemd"]
