#!/bin/bash

docker run -d --name general-redis \
    -p 36573:6379 \
    --restart unless-stopped \
    redis:7.4.3 \
    --requirepass "2BcyTEk2mxo3yGu4Vgs0GNlQ" \
    --databases 100 \
    --maxmemory 10gb \
    --maxmemory-policy "allkeys-lfu"
