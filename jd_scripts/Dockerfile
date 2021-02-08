FROM alpine:3.12
LABEL AUTHOR="none" \
        VERSION=0.1.3

ENV DEFAULT_LIST_FILE=crontab_list.sh \
        CUSTOM_LIST_MERGE_TYPE=append \
        REPO_URL=https://github.com/lion-goose/JD_Scripts.git

RUN set -ex \
        && apk update && apk upgrade\
        && apk add --no-cache tzdata  git  nodejs  moreutils  npm curl jq \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone

RUN git clone ${REPO_URL} /scripts \
        && cd /scripts \
        && git checkout master \
        && mkdir logs \
        && npm install
        
RUN mkdir /jds \
        && cd  /jds \
        && git init \
        && git remote add -f origin https://github.com/lion-goose/Dockerfile.git \
        && git config core.sparsecheckout true \
        && echo jd_scripts/* >> /jds/.git/info/sparse-checkout \
        && git pull origin master

RUN cp /jds/jd_scripts/docker_entrypoint.sh /usr/local/bin \
        && chmod +x /usr/local/bin/docker_entrypoint.sh

WORKDIR /scripts

ENTRYPOINT ["docker_entrypoint.sh"]

CMD [ "crond" ]
