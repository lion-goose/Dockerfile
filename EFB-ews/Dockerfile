FROM alpine
MAINTAINER None

ENV LANG C.UTF-8

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache udns \
        && apk add --no-cache --virtual .run-deps \
                ca-certificates \
                ffmpeg \
                libmagic \
                tiff \
                libwebp \
                freetype \
                lcms2 \
                openjpeg \
                py3-olefile \
                openblas \
                py3-numpy \
                py3-pillow \
                py3-requests \
                python3-dev \
                py3-pip \
                py3-cryptography \
                py3-decorator \
                git \
                jpeg-dev \
                zlib-dev \
                tzdata \
                iproute2 \
                cairo-dev \
                cairo \
                cairo-tools \
                jpeg-dev \
                freetype-dev \
                lcms2-dev \
                openjpeg-dev \
                tiff-dev \
                tk-dev \
                tcl-dev \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone

RUN set -ex \
        && pip3 install --upgrade pip \
        && pip3 install git+https://github.com/ehForwarderBot/ehForwarderBot.git \
        && pip3 install git+https://github.com/ehForwarderBot/efb-telegram-master.git \
        && pip3 install git+https://github.com/ehForwarderBot/efb-wechat-slave.git \
        && pip3 install efb-link-preview-middleware \
        && pip3 install lottie \
        && pip3 install cairosvg \
        && pip3 install python-telegram-bot --upgrade

CMD ["ehforwarderbot"]
