#!/bin/sh
set -e

mergedListFile="/scripts/docker/merged_list_file.sh"

echo "附加功能1，使用jds仓库的gen_code_conf.list文件"
cp /jds/jd_scripts_bot/gen_code_conf.list "$GEN_CODE_LIST"

echo "附加功能2，自定义仓库和任务"
#@shylocks仓库脚本
function initLiongoose() {
    git clone https://github.com/lion-goose/BackUp.git /lion-goose
}

 if [ ! -d "/lion-goose/" ]; then
    echo "未检查到lion-goose仓库脚本，初始化下载相关脚本"
    initLiongoose
else
    echo "更新lion-goose脚本相关文件"
    git -C /lion-goose reset --hard
    git -C /lion-goose pull --rebase
    #npm install --loglevel error
fi

##复制两个文件
cp -f /lion-goose/jd*.js /scripts/

# #### monk-coder https://github.com/monk-coder/dust
# function monkcoder(){
#     # https://github.com/monk-coder/dust
# #     rm -rf /monkcoder /scripts/monkcoder_*
# #     git clone https://github.com/sensi-ribbed/temple.git /monkcoder
#     # 拷贝脚本
#     for jsname in $(find /monkcoder -name "*.js" | grep -vE "\/backup\/"); do cp ${jsname} /scripts/monkcoder_${jsname##*/}; done
#     # 匹配js脚本中的cron设置定时任务
#     for jsname in $(find /monkcoder -name "*.js" | grep -vE "\/backup\/"); do
#         jsnamecron="$(cat $jsname | grep -oE "/?/?cron \".*\"" | cut -d\" -f2)"
#         test -z "$jsnamecron" || echo "$jsnamecron node /scripts/monkcoder_${jsname##*/} >> /scripts/logs/monkcoder_${jsname##*/}.log 2>&1" >> /scripts/docker/merged_list_file.sh
#     done
# }


function monkcoder(){
    # https://share.r2ray.com/dust/
    apk add --no-cache --upgrade grep
    i=1
    while [ "$i" -le 5 ]; do
        folders="$(curl -sX POST "https://share.r2ray.com/dust/" | grep -oP "name.*?\.folder" | cut -d, -f1 | cut -d\" -f3 | grep -vE "backup|pics|rewrite" | tr "\n" " ")"
        test -n "$folders" && { for jsname in /scripts/dust_*.js; do mv -f $jsname $(echo $jsname | sed "s/\/scripts\/dust_/\/scripts\/temp_dust_/"); done; break; }
        test -z "$folders" && { echo 第 $i/5 次目录列表获取失败; i=$(( i + 1 )); }
    done
    for folder in $folders; do
        i=1
        while [ "$i" -le 5 ]; do
            jsnames="$(curl -sX POST "https://share.r2ray.com/dust/${folder}/" | grep -oP "name.*?\.js\"" | grep -oE "[^\"]*\.js\"" | cut -d\" -f1 | tr "\n" " ")"
            test -n "$jsnames" && break || { echo 第 $i/5 次 $folder 目录下文件列表获取失败; i=$(( i + 1 )); }
        done
        for jsname in $jsnames; do 
            i=1
            while [ "$i" -le 5 ]; do
                [ "$i" -lt 5 ] && curl -so /scripts/dust_${jsname} "https://share.r2ray.com/dust/${folder}/${jsname}"
                test "$(wc -c <"/scripts/dust_${jsname}")" -ge 1000 && break || { echo 第 $i/5 次 $folder 目录下 $jsname 文件下载失败; i=$(( i + 1 )); }
                [ "$i" -eq 5 ] && [ -f "/scripts/temp_dust_${jsname}" ] && mv -f /scripts/temp_dust_${jsname} /scripts/dust_${jsname}
            done
        done
    done
    rm -rf /scripts/temp_dust_*.js
}

function diycron(){
    # monkcoder whyour 定时任务
    for jsname in /scripts/dust_*.js; do
        jsnamecron="$(cat $jsname | grep -oE "/?/?cron \".*\"" | cut -d\" -f2)"
        test -z "$jsnamecron" || echo "$jsnamecron node $jsname >> /scripts/logs/$(echo $jsname | cut -d/ -f3).log 2>&1" >> /scripts/docker/merged_list_file.sh
    done
    #### yangtingxiao https://github.com/yangtingxiao/QuantumultX
    wget --no-check-certificate -O /scripts/jd_lottery_machine.js https://raw.githubusercontent.com/yangtingxiao/QuantumultX/master/scripts/jd/jd_lotteryMachine.js
    echo "12 0,16,22 * * * node /scripts/jd_lottery_machine.js |ts >> /scripts/logs/jd_lottery_machine.log 2>&1" >> /scripts/docker/merged_list_file.sh
    #### whyour https://github.com/whyour/hundun
    wget --no-check-certificate -O /scripts/jd_zjd_tuan.js https://raw.githubusercontent.com/whyour/hundun/master/quanx/jd_zjd_tuan.js
    echo "4 * * * * node /scripts/jd_zjd_tuan.js |ts >> /scripts/logs/jd_zjd_tuan.log 2>&1" >> /scripts/docker/merged_list_file.sh
}

function main(){
    # 首次运行时拷贝docker目录下文件
    [[ ! -d /jd_diy ]] && mkdir /jd_diy && cp -rf /scripts/docker/* /jd_diy
    # DIY脚本执行前后信息
    a_jsnum=$(ls -l /scripts | grep -oE "^-.*js$" | wc -l)
    a_jsname=$(ls -l /scripts | grep -oE "^-.*js$" | grep -oE "[^ ]*js$")
    monkcoder
    b_jsnum=$(ls -l /scripts | grep -oE "^-.*js$" | wc -l)
    b_jsname=$(ls -l /scripts | grep -oE "^-.*js$" | grep -oE "[^ ]*js$")
    # DIY任务
    diycron
    # DIY脚本更新TG通知
    info_more=$(echo $a_jsname  $b_jsname | tr " " "\n" | sort | uniq -c | grep -oE "1 .*$" | grep -oE "[^ ]*js$" | tr "\n" " ")
    [[ "$a_jsnum" == "0" || "$a_jsnum" == "$b_jsnum" ]] || curl -sX POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" -d "chat_id=$TG_USER_ID&text=DIY脚本更新完成：$a_jsnum $b_jsnum $info_more" >/dev/null
    # LXK脚本更新TG通知
    lxktext="$(diff /jd_diy/crontab_list.sh /scripts/docker/crontab_list.sh | grep -E "^[+-]{1}[^+-]+" | grep -oE "node.*\.js" | cut -d/ -f3 | tr "\n" " ")"
    test -z "$lxktext" || curl -sX POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" -d "chat_id=$TG_USER_ID&text=LXK脚本更新完成：$(cat /jd_diy/crontab_list.sh | grep -vE "^#" | wc -l) $(cat /scripts/docker/crontab_list.sh | grep -vE "^#" | wc -l) $lxktext" >/dev/null
    # 拷贝docker目录下文件供下次更新时对比
    cp -rf /scripts/docker/* /jd_diy
}

main
