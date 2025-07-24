FROM centos:7

# Install dependencies
RUN yum install -y epel-release && \
    yum install -y tmux && \
    mkdir -p /output && \
    cp /usr/bin/tmux /output/tmux && \
    chmod +x /output/tmux && \
    yum clean all

# Dummy command to keep container alive (optional)
CMD ["sleep", "60"]
