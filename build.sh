#!/bin/bash

set -euxo pipefail

main() {
    local uvers=$1 mvers=$2
    local gid=$(id -g) uid=$(id -u)

    rm -rf stage
    curl -L https://www.musl-libc.org/releases/musl-$mvers.tar.gz | tar xz
    pushd musl-$mvers

    mkdir stage
    docker run --rm -v $(pwd):/pwd -w /pwd -it ubuntu:$uvers sh -c "
apt-get update
apt-get install -qq gcc make
useradd -m -u $uid bob
su bob -c './configure --disable-shared --prefix=/home/travis/musl'
su bob -c 'make -j$(nproc)'
su bob -c 'DESTDIR=/pwd/stage make install'
"

    popd

    rm -f $uvers.tar.gz
    pushd musl-$mvers/stage/home/travis/
    tar -czvf ../../../../$uvers.tar.gz .
    popd

    rm -rf musl-$mvers
}

main "${@}"
