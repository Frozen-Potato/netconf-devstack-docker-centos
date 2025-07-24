FROM centos:7

COPY epel-release-7-14.noarch.rpm /tmp/

# Replace baseurl to avoid mirrorlist.centos.org resolution
RUN sed -i \
    -e 's|^mirrorlist=|#mirrorlist=|' \
    -e 's|^#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|' \
    /etc/yum.repos.d/CentOS-Base.repo && \
    yum -y update && \
    yum -y install /tmp/epel-release-7-14.noarch.rpm && \
    yum -y install tmux && \
    mkdir -p /output && \
    cp /usr/bin/tmux /output/tmux && \
    chmod +x /output/tmux && \
    yum clean all && \
    rm -rf /var/cache/yum /tmp/epel-release-7-14.noarch.rpm

CMD ["sleep", "60"]



