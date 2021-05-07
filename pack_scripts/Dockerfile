FROM alpine
LABEL AUTHOR="none" \
        
RUN set -ex \
        && apk update && apk upgrade\
        && apk add --no-cache tzdata \
        git \
        nodejs \
        moreutils \
        npm \
        python3-dev \
        py3-pip \
        py3-cryptography \
        jq \
        curl \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone

# 配置镜像仓库配置相关文件夹
# 创建工作目录
RUN mkdir /logs \
        && mkdir /pss \
        && cd  /pss \
        && git init \
        && git remote add -f origin https://github.com/lion-goose/Dockerfile.git \
        && git config core.sparsecheckout true \
        && echo pack_scripts/* >> /pss/.git/info/sparse-checkout \
        && git pull origin master \

# 支持喜马拉雅极速版仓库
RUN git clone https://github.com/leeyiding/get_CCB.git /get_CCB \
        && cd /get_CCB \
        && git checkout master \
        && pip3 install --upgrade pip \
        && pip3 install -r requirements.txt

RUN cp /pss/docker_entrypoint.sh /usr/local/bin \
    && chmod +x /usr/local/bin/docker_entrypoint.sh

ENTRYPOINT ["docker_entrypoint.sh"]
