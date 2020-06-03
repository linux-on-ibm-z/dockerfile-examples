#!/usr/bin/env bash

echo "* Setting up /usr/src links from host"
apt update && apt install -y linux-headers-`uname -r`
for i in "/host/usr/src"/*
do
     base=$(basename "$i")
    ln -s "$i" "/usr/src/$base"
done

/usr/bin/falco-driver-loader

exec "$@"
