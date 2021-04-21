FROM alpine
LABEL AUTHOR="none" \
        VERSION=0.1.5

ENV DEFAULT_LIST_FILE=crontab_list.sh \
    CUSTOM_LIST_MERGE_TYPE=append \
    COOKIE_LIST=/scripts/logs/cookies.list \
    GEN_CODE_LIST=/scripts/logs/gen_code_conf.list \
    REPO_URL=https://github.com/sensi-ribbed/Secretly.git \
    BOT_DIR=/jds/jd_scripts_bot/bot \
    LOGS_DIR=/scripts/logs


RUN set -ex \
    && apk update && apk upgrade\
    && apk add --no-cache tzdata git openssh-client \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

        
RUN set -ex \
    && git clone ${REPO_URL} /scripts \
    && mkdir -p /scripts/logs \
    && mkdir -p /root/.ssh \
    && cd /scripts \
    && git checkout master \
    && mkdir /jds \
    && cd  /jds \
    && git init \
    && git remote add -f origin https://github.com/lion-goose/Dockerfile.git \
    && git config core.sparsecheckout true \
    && echo jd_scripts_bot/* >> /jds/.git/info/sparse-checkout \
    && git pull origin master        



RUN cp /jds/jd_scripts_bot/docker_entrypoint.sh /usr/local/bin \
    && chmod +x /usr/local/bin/docker_entrypoint.sh

WORKDIR /scripts

ENTRYPOINT ["docker_entrypoint.sh"]

CMD [ "crond" ]
