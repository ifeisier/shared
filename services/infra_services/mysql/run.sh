#!/bin/bash

current_dir=$(pwd)
current_dir_name=$(basename "$current_dir")
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

docker run -d --name IoTCloud-mysql \
    -p 31865:3306 \
    -e TZ=Asia/Shanghai \
    -e MYSQL_DATABASE="iotcloud" \
    -e MYSQL_ROOT_PASSWORD="2BcyTEk2mxo3yGu4Vgs0GNlQ" \
    -v $script_dir/conf:/etc/mysql/conf.d/ \
    -v $script_dir/data:/var/lib/mysql \
    --restart unless-stopped \
    mysql:8.0.40
