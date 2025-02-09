#!/bin/sh

# 这是一个简单的 rclone mount 脚本.
#
# 启动失败尝试安装依赖:
#    centos: yum install -y fuse3
#    debian: apt install -y fuse3
#
# https://rclone.org/commands/rclone_mount/#options


REMOTE_NAME="远程存储名称"
REMOTE_PATH="远程存储路径"
MOUNT_PATH="挂载的本地路径"


if ! rclone config show | grep -q "\[$REMOTE_NAME\]"; then
    echo "远程存储 '$REMOTE_NAME' 不存在"
    exit 0
fi


rclone mount "${REMOTE_NAME}:${REMOTE_PATH}" "${MOUNT_PATH}" \
    --attr-timeout 10m \
    --vfs-cache-mode full \
    --vfs-cache-max-age 6h \
    --vfs-cache-max-size 10G \
    --vfs-read-chunk-size-limit 200M \
    --vfs-cache-poll-interval 15m \
    --buffer-size 200M \
    --dir-cache-time 6h \
    --poll-interval 5m \
    --bwlimit "08:00,5M 12:00,50M" \
    --config /root/.config/rclone/rclone.conf \
    --cache-dir /root/.cache/rclone \
    --log-level INFO \
    --log-file=/var/log/rclone.log \
    --daemon --allow-other --checksum
