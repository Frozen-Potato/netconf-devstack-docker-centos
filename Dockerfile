FROM centos:7

RUN yum -y update && \
    yum -y install epel-release && \
    yum -y install tmux && \
    mkdir -p /output && \
    cp /usr/bin/tmux /output/tmux && \
    chmod +x /output/tmux && \
    yum clean all && \
    rm -rf /var/cache/yum

CMD ["sleep", "60"]
