FROM python:alpine
ARG TMP_NAME=redrain
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    HOME=/root \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
    NAME=$TMP_NAME \
    DIR="/$TMP_NAME"
COPY redrain/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update -f \
    && apk --no-cache add -f \
        bash \
        coreutils \
        tzdata \
        node \
        yarn \
    && rm -rf /var/cache/apk/* \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    # && pip config set global.index-url https://mirrors.bfsu.edu.cn/pypi/web/simple \
    && python -m pip install --upgrade pip \
    && pip install telethon requests pysocks httpx pyyaml datetime \
    && yarn global add pm2
WORKDIR $DIR
ENTRYPOINT ["docker-entrypoint.sh"]
