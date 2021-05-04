FROM ubuntu:hirsute
ARG DEBIAN_FRONTEND=noninteractive
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    SHELL=/bin/bash \
    LANG=zh_CN.UTF-8 \
    PS1="\u@\h:\w \$ " \
    PAGERMAID_DIR=/pagermaid
SHELL ["/bin/bash", "-c"]
COPY pagermaid/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
WORKDIR $PAGERMAID_DIR
RUN source ~/.bashrc \
#   自编译建议修改为国内镜像源
#   && sed -i 's/archive.ubuntu.com/mirrors.bfsu.edu.cn/g' /etc/apt/sources.list \
#   && sed -i 's/security.ubuntu.com/mirrors.bfsu.edu.cn/g' /etc/apt/sources.list \
#   && sed -i 's/ports.ubuntu.com/mirrors.bfsu.edu.cn/g' /etc/apt/sources.list \
    && echo "**** install runtime dependencies ****" \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y \
        ## 这是正常运行pagermaid需要用到的包
        python3 \
        python3-pip \
        tesseract-ocr \
        tesseract-ocr-eng \
        tesseract-ocr-chi-sim \
        language-pack-zh-hans \
        git \
        openssl \
        redis-server \
        curl \
        wget \
        neofetch \
        imagemagick \
        ffmpeg \
        fortune-mod \
        figlet \
        libmagic1 \
        libzbar0 \
    && echo "**** install build dependencies ****" \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        ## 这是跨平台交叉编译要用到的包，如果自行构建，有可能不需要
        build-essential \
        python3-dev \
        libxslt1-dev \
        libxml2-dev \
        libssl-dev \
        libffi-dev \
        zlib1g-dev \
        tcl8.6-dev \
        tk8.6-dev \
        libimagequant-dev \
        libraqm-dev \
        libjpeg-dev \
        libtiff5-dev \
        libopenjp2-7-dev \
        libfreetype6-dev \
        liblcms2-dev \
        libwebp-dev \
        python3-tk \
        libharfbuzz-dev \
        libfribidi-dev \
        libxcb1-dev \
        pkg-config \
    && echo "**** setting timezone ****" \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && echo "**** git clone ****" \
    && git clone -b master https://github.com/Xtao-Labs/PagerMaid-Modify.git $PAGERMAID_DIR \
    && git config --global pull.ff only \
    && chmod 777 /usr/bin/docker-entrypoint.sh \
    && echo "**** pip install ****" \
    && ln -sf /usr/bin/python3 /usr/bin/python \
#   自编译建议修改为国内pypi源
#   && pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
    && python -m pip install --upgrade pip \
    && pip install eyed3 pycryptodome \
    && pip install -r requirements.txt \
    && echo "**** clean up ****" \
    && apt-get purge --auto-remove -y \
        ## 将跨平台交叉编译要用到的包完全卸载掉
        build-essential \
        python3-dev \
        libxslt1-dev \
        libxml2-dev \
        libssl-dev \
        libffi-dev \
        zlib1g-dev \
        tcl8.6-dev \
        tk8.6-dev \
        libimagequant-dev \
        libraqm-dev \
        libjpeg-dev \
        libtiff5-dev \
        libopenjp2-7-dev \
        libfreetype6-dev \
        liblcms2-dev \
        libwebp-dev \
        python3-tk \
        libharfbuzz-dev \
        libfribidi-dev \
        libxcb1-dev \
        pkg-config \
    && apt-get clean -y \
    && rm -rf \
        ## 删除apt和pip的安装缓存
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /root/.cache \
    && sed -i 's/archive.ubuntu.com/mirrors.bfsu.edu.cn/g' /etc/apt/sources.list \
    && sed -i 's/security.ubuntu.com/mirrors.bfsu.edu.cn/g' /etc/apt/sources.list \
    && sed -i 's/ports.ubuntu.com/mirrors.bfsu.edu.cn/g' /etc/apt/sources.list \
    && pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
ENTRYPOINT ["docker-entrypoint.sh"]
