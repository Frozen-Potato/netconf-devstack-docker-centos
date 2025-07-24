
# 🐧 Tmux Binary Builder for CentOS 7

This repository provides a Docker-based method for building and extracting a standalone `tmux` binary compatible with CentOS 7 systems. It is especially useful for air-gapped or proxy-restricted environments (such as VDIs) where installing `tmux` via `yum` or `dnf` isn't feasible.

---

## 📦 Docker Image

Prebuilt image is available on Docker Hub:

```
docker pull frozenpotato/tmux-centos7:latest
```

---

## 🔧 What This Image Does

- Uses `centos:7` as the base image
- Installs `epel-release` manually from a known-safe archive URL (included in repo)
- Installs `tmux` from EPEL
- Extracts the `/usr/bin/tmux` binary into `/output/tmux` inside the image

---

## 🧰 How to Extract `tmux` Binary

```bash
# 1. Pull the image
docker pull frozenpotato/tmux-centos7:latest

# 2. Create a container from the image
docker create --name tmuxbox frozenpotato/tmux-centos7:latest

# 3. Copy the tmux binary out of the container
docker cp tmuxbox:/output/tmux ./tmux

# 4. Clean up the container
docker rm -f tmuxbox
```

---

## 🛠️ How to Install tmux on Your System

```bash
# Make it executable
chmod +x ./tmux

# Move to a directory in your PATH
sudo mv ./tmux /usr/local/bin/

# Verify installation
tmux -V
```

---

## 🧱 Included Files

- `Dockerfile` — the build instructions
- `epel-release-7-14.noarch.rpm` — static EPEL installer for CentOS 7 (copied into container)

---

## 🔄 Build It Yourself (Optional)

```bash
# Build the image locally
docker build -t tmux-centos7 .
```

---

## 📝 Notes

- This image uses `vault.centos.org` instead of CentOS mirrorlists to avoid DNS failures in `buildx` environments.
- The `epel-release` RPM is bundled with the repo to eliminate external fetch during CI/CD builds.
- Tested with GitHub Actions and `docker buildx`.

---

## 📜 License

This repository and Dockerfile are licensed under the MIT License.  
Binary software (tmux, epel-release) follows their respective upstream licenses.
