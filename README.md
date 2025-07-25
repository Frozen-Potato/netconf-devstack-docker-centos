# tmux-netconf-centos7

This project builds a static `tmux` binary and a NETCONF development stack (libnetconf2, libssh, libyang, OpenSSL) on a CentOS 7 base using Docker — fully offline-compatible.

## Features

- ✅ Builds `tmux` from CentOS 7 with EPEL support
- ✅ Installs and exports `tmux` binary to `/output/tmux`
- ✅ Builds and installs:
  - `OpenSSL 1.1.1w`
  - `libyang v2.1.148`
  - `libssh 0.10.6`
  - `libnetconf2 v2.1.34`
- ✅ Extracts built `.so` libraries and `.h` headers to `/output/libs` and `/output/include`
- ✅ Uses `vault.centos.org` to avoid mirrorlist resolution issues (fully air-gapped friendly)

## Build Instructions

```bash
docker build -t tmux-centos-netconf .
```

## Extract Files from Container

```bash
# Start container
docker run --name tmux-netconf-inst tmux-centos-netconf

# Copy built artifacts
docker cp tmux-netconf-inst:/output ./output

# Cleanup
docker rm tmux-netconf-inst
```

## Contents of `/output/`

- `/output/tmux` — statically built tmux binary
- `/output/libs/` — all required `.so` files:
  - `libnetconf2.so`, `libyang.so`, `libssh.so`, `libssl.so`, `libcrypto.so`
- `/output/include/` — headers for all libraries, ready for development

## Usage

On your CentOS 7 host:

```bash
# Copy libraries
sudo cp output/libs/* /usr/local/lib/
sudo ldconfig

# Copy headers
sudo cp -r output/include/* /usr/local/include/
```

You can now build and run C/C++ applications that depend on libnetconf2, libssh, libyang, and OpenSSL 1.1.1 without needing external internet access.

## License

MIT
