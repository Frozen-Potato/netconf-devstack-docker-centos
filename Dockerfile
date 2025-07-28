FROM centos:7

COPY epel-release-7-14.noarch.rpm /tmp/

# Use vault.centos.org to avoid DNS resolution issues
RUN sed -i \
    -e 's|^mirrorlist=|#mirrorlist=|' \
    -e 's|^#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|' \
    /etc/yum.repos.d/CentOS-Base.repo

# Install base packages and tmux
RUN yum -y update && \
    yum -y install /tmp/epel-release-7-14.noarch.rpm && \
    yum -y install tmux && \
    mkdir -p /output && \
    cp /usr/bin/tmux /output/tmux && \
    chmod +x /output/tmux

# Install development tools and dependencies
RUN yum -y groupinstall "Development Tools" && \
    yum -y install \
        wget \
        cmake3 \
        git \
        gcc \
        gcc-c++ \
        make \
        zlib-devel \
        ncurses-devel \
        openssl-devel \
        pcre-devel \
        pcre2-devel \ 
        curl-devel \
        expat-devel \
        gettext-devel \
        perl-devel \
        && \
    yum clean all && \
    rm -rf /var/cache/yum /tmp/epel-release-7-14.noarch.rpm

# Create cmake3 symlink for compatibility
RUN ln -sf /usr/bin/cmake3 /usr/bin/cmake

# Environment variables for OpenSSL
ENV OPENSSL_PREFIX=/usr/local/openssl-1.1.1
ENV PATH=$OPENSSL_PREFIX/bin:$PATH
ENV LD_LIBRARY_PATH=$OPENSSL_PREFIX/lib:$LD_LIBRARY_PATH
ENV PKG_CONFIG_PATH=$OPENSSL_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH
ENV CFLAGS="-I$OPENSSL_PREFIX/include"
ENV LDFLAGS="-L$OPENSSL_PREFIX/lib"

# Build OpenSSL 1.1.1w
RUN cd /tmp && \
    wget https://www.openssl.org/source/openssl-1.1.1w.tar.gz && \
    tar xf openssl-1.1.1w.tar.gz && \
    cd openssl-1.1.1w && \
    ./config --prefix=$OPENSSL_PREFIX --openssldir=$OPENSSL_PREFIX shared && \
    make -j$(nproc) && \
    make install && \
    echo "$OPENSSL_PREFIX/lib" > /etc/ld.so.conf.d/openssl.conf && \
    ldconfig && \
    cd / && \
    rm -rf /tmp/openssl*
    
# Build libyang (v2.1.148)
RUN cd /tmp && \
    git clone https://github.com/CESNET/libyang.git && \
    cd libyang && git checkout v2.1.148 && \
    echo "libyang commit:" && git log -1 && \
    mkdir build && cd build && \
    /usr/bin/cmake3 .. \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_LYD_PRIV=ON \
        -DENABLE_TESTS=OFF && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    cd / && \
    rm -rf /tmp/libyang


# Build libssh (0.10.6)
RUN cd /tmp && \
    git clone https://git.libssh.org/projects/libssh.git && \
    cd libssh && \
    git checkout libssh-0.10.6 && \
    mkdir build && cd build && \
    /usr/bin/cmake3 .. \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCMAKE_BUILD_TYPE=Release \
        -DOPENSSL_ROOT_DIR=$OPENSSL_PREFIX \
        -DWITH_EXAMPLES=OFF \
        -DWITH_TESTING=OFF && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    cd / && \
    rm -rf /tmp/libssh

# Build libnetconf2 (v2.1.34)
RUN cd /tmp && \
    git clone https://github.com/CESNET/libnetconf2.git && \
    cd libnetconf2 && \
    git checkout v2.1.34 && \
    mkdir build && cd build && \
    /usr/bin/cmake3 .. \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_TESTS=OFF && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    cd / && \
    rm -rf /tmp/libnetconf2

# Set up library environment
RUN echo "/usr/local/lib" >> /etc/ld.so.conf.d/local.conf && \
    echo "/usr/local/lib64" >> /etc/ld.so.conf.d/local.conf && \
    ldconfig

# Verify installations
RUN export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig && \
    pkg-config --exists libyang && \
    pkg-config --exists libssh && \
    pkg-config --exists libnetconf2 && \
    echo "All libraries installed successfully"

# Copy built outputs
RUN mkdir -p /output/include /output/lib /output/pkgconfig && \
    cp -r /usr/local/include/* /output/include/ && \
    cp -P /usr/local/lib/libyang*.so* /output/lib/ && \
    cp -P /usr/local/lib/libnetconf2*.so* /output/lib/ && \
    cp -P /usr/local/lib/libssh*.so* /output/lib/ && \
    cp -r /usr/local/lib/pkgconfig/* /output/pkgconfig/ || true

# Default command - use bash instead of sleep for interactive use
CMD ["/bin/bash"]
