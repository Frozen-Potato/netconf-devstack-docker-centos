FROM centos:7

COPY epel-release-7-14.noarch.rpm /tmp/

RUN yum -y update && \
    yum -y install /tmp/epel-release-7-14.noarch.rpm && \
    yum -y install tmux && \
    mkdir -p /output && \
    cp /usr/bin/tmux /output/tmux && \
    chmod +x /output/tmux && \
    yum clean all && \
    rm -rf /var/cache/yum /tmp/epel-release-7-14.noarch.rpm

CMD ["sleep", "60"]


