#! /usr/bin/env bash
set -euo pipefail

export NGINX_VERSION=1.26.2
export NJS_VERSION=0.8.4
export PKG_RELEASE=1~bookworm

mkdir -p /var/log/nginx

# --- Add nginx signing key (MODERN WAY) ---
curl -fsSL https://nginx.org/keys/nginx_signing.key \
  | gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg

# --- Add repo ---
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://nginx.org/packages/mainline/debian bookworm nginx" \
  > /etc/apt/sources.list.d/nginx.list

# --- Install ---
apt-get update

dpkgArch="$(dpkg --print-architecture)"

nginxPackages="
  nginx=${NGINX_VERSION}-${PKG_RELEASE}
  nginx-module-njs=${NGINX_VERSION}.${NJS_VERSION}-${PKG_RELEASE}
"

apt-get install --no-install-recommends --no-install-suggests -y \
  $nginxPackages \
  gettext-base

rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nginx.list

# --- logs ---
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log
