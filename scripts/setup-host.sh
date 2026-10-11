#!/usr/bin/env bash
set -euo pipefail

echo "== Ubuntu release =="
. /etc/os-release
echo "${PRETTY_NAME:-unknown}"

echo
echo "== Installing base tools and Mono =="
sudo apt update
sudo apt install -y ca-certificates curl git unzip mono-devel

if command -v docker >/dev/null 2>&1; then
  echo
  echo "Docker is already installed:"
  docker --version || true
else
  echo
  echo "== Installing Docker Engine from Docker's official Ubuntu repository =="
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

sudo systemctl enable --now docker

if ! groups "$USER" | grep -q '\bdocker\b'; then
  sudo usermod -aG docker "$USER"
  echo
  echo "Added $USER to the docker group."
  echo "Log out and back in later for non-sudo Docker access."
fi

echo
echo "Setup finished."
