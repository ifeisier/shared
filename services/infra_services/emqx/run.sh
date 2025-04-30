#!/bin/bash

current_dir=$(pwd)
current_dir_name=$(basename "$current_dir")
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

docker run -d --name IoTCloud-emqx \
    -p 34649:1883 -p 30873:8083 -p 33805:18083 \
    -e TimeZone=Asia/Shanghai \
    -v /etc/localtime:/etc/localtime \
    -v $script_dir/etc/emqx.conf:/opt/emqx/etc/emqx.conf \
    -v $script_dir/etc/acl.conf:/opt/emqx/etc/acl.conf \
    -v $script_dir/log:/opt/emqx/log \
    --restart unless-stopped \
    emqx/emqx:5.8.1
