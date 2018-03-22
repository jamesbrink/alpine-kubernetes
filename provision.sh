#!/bin/bash
echo "Provisioning Alpine with Kubernets"

export SRC_DIR=/root/src

install_go ()
{
  echo "Building Go"
  export BUILD_DIR="$SRC_DIR"/go-go1.9.4
  export GOOS="linux"
  export GOPATH="$SRC_DIR"
  export GOROOT="$BUILD_DIR"
  export GOBIN="$GOROOT"/bin
  export GOROOT_FINAL=/usr/local/lib/go
  export GOARCH="amd64"
  export GOROOT_BOOTSTRAP=/usr/lib/go
  export CC="${HOSTLD:-gcc}"
  export CC_FOR_TARGET="$CC"
  export CXX="${HOSTLD:-g++}"
  export LD="${HOSTLD:-ld}"

  # Download Go source.
  cd "$SRC_DIR"
  curl -s -L -O https://github.com/golang/go/archive/go1.9.4.tar.gz
  tar xfz go1.9.4.tar.gz
  rm go1.9.4.tar.gz
  # Build Go
  cd "$BUILD_DIR/src"
  ./make.bash
  # Install our new go runtime.
  mkdir -p "$GOROOT_FINAL"
  cp -r "$BUILD_DIR"/* "$GOROOT_FINAL"
  ln -s "$GOROOT_FINAL"/bin/go /usr/local/bin/
  ln -s "$GOROOT_FINAL"/bin/gofmt /usr/local/bin/
  # Remove source
  cd "$SRC_DIR"
  rm -rf "$SRC_DIR"/go-go1.9.4
  # Cleanup
  unset GOROOT
  unset GOPATH
  unset GOBIN
}

install_kubernetes ()
{
  echo "Building Kubernets"
  export BUILD_DIR="$SRC_DIR"/kubernetes-1.9.6
  export CC="${HOSTLD:-gcc}"
  export CC_FOR_TARGET="$CC"
  export CXX="${HOSTLD:-g++}"
  export LD="${HOSTLD:-ld}"
  # Download Kubernets source
  cd "$SRC_DIR"
  curl -s -L -O https://github.com/kubernetes/kubernetes/archive/v1.9.6.tar.gz
  tar xfz v1.9.6.tar.gz
  rm v1.9.6.tar.gz
  cd $BUILD_DIR
  # Build Kubernets
  make -j2
  # Install Kubernets
  mkdir -p /usr/local/bin
  cp -r _output/local/bin/linux/amd64/* /usr/local/bin/
  # Remove source
  cd "$SRC_DIR"
  rm -rf "$SRC_DIR"/kubernetes-1.9.6
  # Install init scripts
  mv /home/vagrant/kubelet /etc/init.d/kubelet
  chown root:root /etc/init.d/kubelet
  chmod 755 /etc/init.d/kubelet
  # Remove go
  rm -rf /usr/local/lib/go
  rm /usr/local/bin/go
  rm /usr/local/bin/gofmt
}

# Enable swap for builds
dd if=/dev/zero of=/swapfile bs=1G count=4
mkswap /swapfile
swapon /swapfile

# Set hostname.
echo "alpine-k8s-master" > /etc/hostname
hostname -F /etc/hostname

# Install Kubernetes dependencies.
apk --no-cache --update add --virtual kubernetes-deps \
  ebtables \
  ethtool \
  socat \
  iproute2 \
  findutils \
  iptables \
  docker \
  bash

# Install build dependencies.
apk --no-cache --update add --virtual build-deps \
  alpine-sdk \
  go-bootstrap \
  rsync \
  linux-headers \
  git \
  grep \
  findutils \
  coreutils

# Start build and installation of Go and Kubernets
mkdir -p "$SRC_DIR"
install_go
install_kubernetes

# Remove build dependencies.
apk del build-deps

# Disable swap
swapoff -a
rm /swapfile
rc-update del swap boot
rc-service swap stop

# Enable services
/etc/init.d/iptables save
rc-update add docker
rc-update add virtualbox-guest-additions
rc-service docker start
rc-service virtualbox-guest-additions start
rc-update add iptables
rc-service iptables start
rc-update add kubelet
rc-service kubelet start

