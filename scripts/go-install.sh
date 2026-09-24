#!/usr/bin/env bash
set -euo pipefail

echo "[Running go-install.sh]"

GO_VERSION="1.27.1"

case "$(uname -m)" in
  x86_64) arch=amd64 ;;
  aarch64) arch=arm64 ;;
  *) echo "ERROR: unsupported architecture $(uname -m)"; exit 1 ;;
esac

if [ -x /usr/local/go/bin/go ] && [ "$(/usr/local/go/bin/go env GOVERSION)" = "go${GO_VERSION}" ]; then
  echo "go${GO_VERSION} already installed, skipping"
else
  tarball="go${GO_VERSION}.linux-${arch}.tar.gz"
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "${tmpdir}"' EXIT

  curl -fsSL -o "${tmpdir}/${tarball}" "https://dl.google.com/go/${tarball}"
  echo "$(curl -fsSL "https://dl.google.com/go/${tarball}.sha256")  ${tmpdir}/${tarball}" | sha256sum --check

  # Go's install docs require removing any previous tree rather than
  # extracting over it, or stale files from the old version break builds.
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "${tmpdir}/${tarball}"
fi

# Login shells (vagrant ssh) pick this up; $HOME/go/bin is where
# `go install` puts tools.
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' | sudo tee /etc/profile.d/go.sh > /dev/null

/usr/local/go/bin/go version
