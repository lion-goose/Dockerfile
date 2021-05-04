#!/bin/bash

redis-server --daemonize yes

cd $PAGERMAID_DIR

if [ ! -s config.yml ]; then
    cp -f config.gen.yml config.yml
fi

if [ -f pagermaid.session ]; then
    python -m pagermaid
else
    echo "\"pagermaid.session\" 文件还没有生成，可能是首次部署容器，请先在映射目录下修改好 \"config.yml\" 后，进入容器手动运行一次 \"python -m pagermaid\"，并按照提示输入必要的信息，然后重启本容器。"
    while :; do sleep 1; done
fi

exec "$@"
