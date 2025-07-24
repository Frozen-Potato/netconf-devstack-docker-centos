FROM centos:7

RUN yum -y update && \
    yum -y install \
    https://archives.fedoraproject.org/pub/archive/epel/7/x86_64/Packages/e/epel-release-7-14.noarch.rpm && \
    yum -y install tmux && \
    mkdir -p /output && \
    cp /usr/bin/tmux /output/tmux && \
    chmod +x /output/tmux && \
    yum clean all && \
    rm -rf /var/cache/yum

CMD ["sleep", "60"]

