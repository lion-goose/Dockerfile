  
FROM python:alpine
ARG TMP_NAME=redrain
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    HOME=/root \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
    NAME=$TMP_NAME \
    DIR="/$TMP_NAME"
COPY --from=nevinee/s6-overlay-stage:latest / /
COPY s6-overlay /
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update -f \
    && apk --no-cache add -f \
       bash \
       coreutils \
       tzdata \
       nodejs-current \
       npm \
    && rm -rf /var/cache/apk/* \
    && npm install -g pm2 \
    && rm -rf /root/.npm \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && pip config set global.index-url https://mirrors.bfsu.edu.cn/pypi/web/simple \
    && pip install telethon requests pysocks httpx pyyaml datetime
WORKDIR $DIR
ENTRYPOINT ["/init"]
