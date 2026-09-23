#!/usr/bin/env bash
set -euo pipefail

echo "[Running kubebuilder-install.sh]"

KUBEBUILDER_VERSION="4.16.0"

case "$(uname -m)" in
  x86_64) arch=amd64 ;;
  aarch64) arch=arm64 ;;
  *) echo "ERROR: unsupported architecture $(uname -m)"; exit 1 ;;
esac

# Earlier installs unpacked the old v1 tarball here; its binaries shadow
# nothing on PATH anymore but are dead weight and confusing.
sudo rm -rf /usr/local/kubebuilder

binary="kubebuilder_linux_${arch}"
base_url="https://github.com/kubernetes-sigs/kubebuilder/releases/download/v${KUBEBUILDER_VERSION}"
tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

curl -fsSL -o "${tmpdir}/${binary}" "${base_url}/${binary}"
curl -fsSL -o "${tmpdir}/checksums.txt" "${base_url}/checksums.txt"
(cd "${tmpdir}" && sha256sum --check --ignore-missing checksums.txt)

sudo install -m 0755 "${tmpdir}/${binary}" /usr/local/bin/kubebuilder

kubebuilder version
